from flask import Flask, render_template, g, redirect, url_for, flash
import sqlite3
import os
import requests # For API calls
import time     # For rate limiting

app = Flask(__name__)
app.secret_key = os.urandom(24) # Needed for flash messages

# Configuration
DATABASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'database/stock_portfolio.db')
SCHEMA_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'database/schema.sql')
SAMPLE_DATA_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'database/sample_data.sql')

# Alpha Vantage API Configuration
ALPHA_VANTAGE_API_KEY = os.environ.get('ALPHA_VANTAGE_API_KEY') # Get from environment variable
ALPHA_VANTAGE_BASE_URL = 'https://www.alphavantage.co/query'
# Basic rate limiting: store the time of the last API call
last_api_call_time = 0
API_CALL_INTERVAL = 15  # seconds (Alpha Vantage free tier is 5 calls/min)

# --- Database Helper Functions ---
def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        # Tell sqlite3 to parse declared types and recognize column names for type conversion
        db = g._database = sqlite3.connect(DATABASE, detect_types=sqlite3.PARSE_DECLTYPES | sqlite3.PARSE_COLNAMES)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def init_db(force_load_sample_data=False):
    if not os.path.exists(DATABASE) or force_load_sample_data:
        print(f"Initializing database at {DATABASE}...")
        with app.app_context():
            db = get_db()
            with open(SCHEMA_FILE, 'r') as f:
                db.executescript(f.read())
            print(f"Schema loaded from {SCHEMA_FILE}.")
            # Sample data might still be useful for stocks, transactions, holdings
            if force_load_sample_data or not os.path.exists(DATABASE):
                with open(SAMPLE_DATA_FILE, 'r') as f:
                    # We might want to modify sample_data.sql to NOT insert into current_prices
                    # as this will now be handled by the API.
                    # For now, it will insert, and API updates will overwrite.
                    db.executescript(f.read())
                print(f"Sample data loaded from {SAMPLE_DATA_FILE}.")
            db.commit()
    else:
        print(f"Database {DATABASE} already exists.")

# --- Alpha Vantage API Function ---
def fetch_current_price(symbol):
    global last_api_call_time
    current_time = time.time()

    if not ALPHA_VANTAGE_API_KEY:
        print("Alpha Vantage API key not set.")
        return None

    # Basic rate limiting
    if current_time - last_api_call_time < API_CALL_INTERVAL:
        wait_time = API_CALL_INTERVAL - (current_time - last_api_call_time)
        print(f"Rate limiting: waiting {wait_time:.2f} seconds before next API call.")
        time.sleep(wait_time)
    
    params = {
        'function': 'GLOBAL_QUOTE',
        'symbol': symbol,
        'apikey': ALPHA_VANTAGE_API_KEY
    }
    try:
        response = requests.get(ALPHA_VANTAGE_BASE_URL, params=params)
        response.raise_for_status() # Raise an exception for HTTP errors
        last_api_call_time = time.time()
        data = response.json()
        if "Global Quote" in data and "05. price" in data["Global Quote"]:
            return float(data["Global Quote"]["05. price"])
        elif "Note" in data: # API limit reached or other note
            print(f"API Note for {symbol}: {data['Note']}")
            flash(f"API limit likely reached while fetching {symbol}. Please try again later.", "warning")
            return None
        else:
            print(f"Unexpected API response for {symbol}: {data}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching price for {symbol}: {e}")
        return None
    except ValueError as e: # For JSON decoding errors
        print(f"Error decoding JSON for {symbol}: {e}")
        return None

# --- Routes ---
@app.route('/')
def index():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT 
            s.symbol,
            s.company_name,
            ph.quantity_held,
            ph.average_buy_price,
            cp.current_price AS current_market_price,
            cp.last_updated AS price_last_updated,
            ROUND(ph.quantity_held * cp.current_price, 2) AS current_total_value
        FROM portfolio_holdings ph
        JOIN stocks s ON ph.stock_id = s.stock_id
        LEFT JOIN current_prices cp ON ph.stock_id = cp.stock_id;
    """) # LEFT JOIN in case a price is missing
    holdings = cursor.fetchall()

    cursor.execute("""
        SELECT 
            ROUND(SUM(ph.quantity_held * cp.current_price), 2) AS total_portfolio_market_value
        FROM portfolio_holdings ph
        JOIN current_prices cp ON ph.stock_id = cp.stock_id WHERE cp.current_price IS NOT NULL;
    """)
    total_value_row = cursor.fetchone()
    total_portfolio_value = total_value_row['total_portfolio_market_value'] if total_value_row and total_value_row['total_portfolio_market_value'] is not None else 0

    cursor.execute("""
        SELECT 
            ROUND(SUM((cp.current_price - ph.average_buy_price) * ph.quantity_held), 2) AS total_unrealized_profit_loss
        FROM portfolio_holdings ph
        JOIN current_prices cp ON ph.stock_id = cp.stock_id WHERE cp.current_price IS NOT NULL;
    """)
    total_pnl_row = cursor.fetchone()
    total_unrealized_pnl = total_pnl_row['total_unrealized_profit_loss'] if total_pnl_row and total_pnl_row['total_unrealized_profit_loss'] is not None else 0

    return render_template('index.html', 
                           holdings=holdings, 
                           total_portfolio_value=total_portfolio_value,
                           total_unrealized_pnl=total_unrealized_pnl,
                           api_key_set = bool(ALPHA_VANTAGE_API_KEY))

@app.route('/transactions')
def transactions_history():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT 
            t.transaction_date,
            s.symbol,
            s.company_name,
            t.transaction_type,
            t.quantity,
            t.price_per_share,
            ROUND(t.quantity * t.price_per_share, 2) AS total_cost
        FROM transactions t
        JOIN stocks s ON t.stock_id = s.stock_id
        ORDER BY t.transaction_date DESC, t.transaction_id DESC;
    """)
    transactions = cursor.fetchall()
    return render_template('transactions.html', transactions=transactions)

@app.route('/update_prices', methods=['POST'])
def update_prices():
    if not ALPHA_VANTAGE_API_KEY:
        flash("Alpha Vantage API key is not configured. Please set the ALPHA_VANTAGE_API_KEY environment variable.", "error")
        return redirect(url_for('index'))

    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT stock_id, symbol FROM stocks")
    stocks_to_update = cursor.fetchall()
    
    updated_count = 0
    failed_count = 0

    for stock in stocks_to_update:
        print(f"Fetching price for {stock['symbol']}...")
        current_price = fetch_current_price(stock['symbol'])
        if current_price is not None:
            cursor.execute("""
                INSERT OR REPLACE INTO current_prices (stock_id, current_price, last_updated)
                VALUES (?, ?, CURRENT_TIMESTAMP)
            """, (stock['stock_id'], current_price))
            db.commit()
            updated_count += 1
            print(f"Updated {stock['symbol']} to {current_price}")
        else:
            failed_count += 1
            print(f"Failed to fetch price for {stock['symbol']}")
        # The fetch_current_price function handles rate limiting internally

    if updated_count > 0:
        flash(f"Successfully updated prices for {updated_count} stock(s).", "success")
    if failed_count > 0:
        flash(f"Failed to update prices for {failed_count} stock(s). Check console for details.", "warning")
    if updated_count == 0 and failed_count == 0:
        flash("No stocks found to update or all failed. If you have stocks, check API key and console logs.", "info")

    return redirect(url_for('index'))

if __name__ == '__main__':
    db_exists = os.path.exists(DATABASE)
    init_db(force_load_sample_data=not db_exists)
    app.run(debug=True) 