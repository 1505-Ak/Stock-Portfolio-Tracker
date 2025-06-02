import sqlite3
import os

# Adjust paths to be relative to the script's location if needed
# or ensure this script is run from the Stock-Portfolio-Tracker directory.
SCHEMA_FILE = 'database/schema.sql'
SAMPLE_DATA_FILE = 'database/sample_data.sql'

QUERIES_TO_RUN = [
    ("--- Query 6: View all current portfolio holdings with their current market value ---",
     """
     SELECT 
         s.symbol,
         s.company_name,
         ph.quantity_held,
         ph.average_buy_price,
         cp.current_price AS current_market_price,
         ROUND(ph.quantity_held * cp.current_price, 2) AS current_total_value
     FROM portfolio_holdings ph
     JOIN stocks s ON ph.stock_id = s.stock_id
     JOIN current_prices cp ON ph.stock_id = cp.stock_id;
     """),

    ("--- Query 7: Calculate the total current market value of the entire portfolio ---",
     """
     SELECT 
         ROUND(SUM(ph.quantity_held * cp.current_price), 2) AS total_portfolio_market_value
     FROM portfolio_holdings ph
     JOIN current_prices cp ON ph.stock_id = cp.stock_id;
     """),

    ("--- Query 8: View all transactions for AAPL ---",
     """
     SELECT t.transaction_date, s.symbol, t.transaction_type, t.quantity, t.price_per_share, 
            ROUND(t.quantity * t.price_per_share, 2) AS total_transaction_cost
     FROM transactions t
     JOIN stocks s ON t.stock_id = s.stock_id
     WHERE s.symbol = 'AAPL'
     ORDER BY t.transaction_date DESC;
     """),

    ("--- Query 9: Calculate Unrealized Profit/Loss for each holding ---",
     """
     SELECT 
         s.symbol,
         s.company_name,
         ph.quantity_held,
         ph.average_buy_price,
         cp.current_price AS current_market_price,
         ROUND((cp.current_price - ph.average_buy_price) * ph.quantity_held, 2) AS unrealized_profit_loss
     FROM portfolio_holdings ph
     JOIN stocks s ON ph.stock_id = s.stock_id
     JOIN current_prices cp ON ph.stock_id = cp.stock_id;
     """),

    ("--- Query 10: Calculate Total Unrealized Profit/Loss for the entire portfolio ---",
     """
     SELECT 
         ROUND(SUM((cp.current_price - ph.average_buy_price) * ph.quantity_held), 2) AS total_unrealized_profit_loss
     FROM portfolio_holdings ph
     JOIN current_prices cp ON ph.stock_id = cp.stock_id;
     """),

    ("--- Query 11 (Simpler): Estimated Realized Profit/Loss from Sales ---",
     """
     SELECT 
         s.symbol,
         t.transaction_date,
         t.quantity AS quantity_sold,
         t.price_per_share AS sell_price,
         ph.average_buy_price AS avg_buy_price_at_time_of_record,
         ROUND((t.price_per_share - ph.average_buy_price) * t.quantity, 2) AS estimated_realized_profit_loss
     FROM transactions t
     JOIN stocks s ON t.stock_id = s.stock_id
     JOIN portfolio_holdings ph ON t.stock_id = ph.stock_id
     WHERE t.transaction_type = 'SELL';
     """)
]

def main():
    # Create an in-memory SQLite database
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()

    try:
        # Execute schema SQL
        with open(SCHEMA_FILE, 'r') as f:
            schema_sql = f.read()
        cursor.executescript(schema_sql)
        conn.commit()
        print(f"Successfully loaded schema from {SCHEMA_FILE}")

        # Execute sample data SQL
        with open(SAMPLE_DATA_FILE, 'r') as f:
            sample_data_sql = f.read()
        cursor.executescript(sample_data_sql)
        conn.commit()
        print(f"Successfully loaded sample data from {SAMPLE_DATA_FILE}")

        # Run demonstration queries
        for label, query in QUERIES_TO_RUN:
            print(f"\n{label}")
            cursor.execute(query)
            
            col_names = [description[0] for description in cursor.description]
            print(col_names)
            
            rows = cursor.fetchall()
            if rows:
                for row in rows:
                    print(row)
            else:
                print("No results found.")

    except sqlite3.Error as e:
        print(f"SQLite error: {e}")
    except FileNotFoundError as e:
        print(f"Error: {e}. Make sure the script is in the Stock-Portfolio-Tracker directory, or adjust paths.")
    finally:
        # Close the connection
        conn.close()

if __name__ == "__main__":
    main() 