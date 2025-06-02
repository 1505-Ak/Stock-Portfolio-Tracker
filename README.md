# Stock Portfolio Tracker

This project is a SQL-based stock portfolio tracker with a Flask web interface. It allows users to manage their stock portfolios, track transactions, calculate current valuations with live price updates, and analyze performance.

## Features

*   Web interface built with Flask, styled with a dark theme.
*   Portfolio Overview page displaying current holdings, total value, and unrealized P/L.
*   Transaction History page.
*   **Automated Current Price Updates:** Integrates with the Alpha Vantage API to fetch and update stock prices.
*   Track stock purchases and sales via a `transactions` table.
*   Maintain a list of unique `stocks` with their company names.
*   Keep a `portfolio_holdings` table reflecting the current quantity and average buy price of owned stocks.
*   Calculate the current market value of individual holdings and the overall portfolio.
*   Analyze unrealized profit/loss for current holdings.
*   Estimate realized profit/loss from sales (using simplified average cost basis).
*   View detailed transaction history for specific stocks or the entire portfolio.

## Database Schema

The database consists of the following tables. See `database/schema.sql` for full DDL statements.

*   `stocks`: Stores stock symbols and company names (e.g., AAPL, Apple Inc.).
    *   `stock_id` (PK), `symbol`, `company_name`, `last_updated`
*   `transactions`: Records every stock buy or sell transaction.
    *   `transaction_id` (PK), `stock_id` (FK), `transaction_type` (BUY/SELL), `quantity`, `price_per_share`, `transaction_date`
*   `portfolio_holdings`: A snapshot of currently owned stocks, their quantities, and average buy prices.
    *   `holding_id` (PK), `stock_id` (FK), `quantity_held`, `average_buy_price`, `last_updated`
*   `current_prices`: Stores current market prices for stocks, updated via API.
    *   `price_id` (PK), `stock_id` (FK), `current_price`, `last_updated`

## Setup & Usage

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:1505-Ak/Stock-Portfolio-Tracker.git
    cd Stock-Portfolio-Tracker
    ```

2.  **Get an Alpha Vantage API Key:**
    *   This project uses the Alpha Vantage API to fetch real-time stock prices.
    *   Go to [https://www.alphavantage.co/support/#api-key](https://www.alphavantage.co/support/#api-key) and claim your free API key.

3.  **Set Environment Variable for API Key:**
    *   The application expects your Alpha Vantage API key to be set as an environment variable named `ALPHA_VANTAGE_API_KEY`.
    *   **For Linux/macOS (in your terminal for the current session):**
        ```bash
        export ALPHA_VANTAGE_API_KEY='YOUR_ACTUAL_API_KEY'
        ```
    *   **For Windows (Command Prompt for the current session):**
        ```bash
        set ALPHA_VANTAGE_API_KEY=YOUR_ACTUAL_API_KEY
        ```
    *   For persistent storage, you would add this to your shell's configuration file (e.g., `.bashrc`, `.zshrc`, or system environment variables).
    *   **Important:** Do not commit your API key directly into the code or your Git repository.

4.  **Install Dependencies:**
    *   Make sure you have Python 3 and pip installed.
    *   Navigate to the project directory in your terminal and run:
        ```bash
        pip install -r requirements.txt 
        # or pip3 install -r requirements.txt
        ```

5.  **Database Setup:**
    *   The application uses a SQLite database file (`database/stock_portfolio.db`).
    *   This database will be automatically created and initialized with schema (from `database/schema.sql`) and sample data (from `database/sample_data.sql`) the first time you run the Flask app.
    *   The sample data for `current_prices` might be initially populated but will be overwritten by the API updates.

6.  **Run the Flask Application:**
    *   In your terminal, from the project directory (`Stock-Portfolio-Tracker`), run:
        ```bash
        python app.py
        # or python3 app.py
        ```
    *   The terminal will show the application running, usually on `http://127.0.0.1:5000/`.

7.  **Access in Browser:**
    *   Open your web browser and go to `http://127.0.0.1:5000/`.
    *   You should see the portfolio overview. You can navigate to "Transaction History".
    *   If your API key is correctly set, you can use the "Update All Stock Prices" button on the Portfolio Overview page to fetch the latest prices.

## Example Workflow (Manual Updates shown in `common_queries.sql`)

1.  **Add a new stock:** Insert into `stocks`.
2.  **Record a BUY transaction:** Insert into `transactions`.
3.  **Update `portfolio_holdings`:** 
    *   If it's a new stock holding: `INSERT` into `portfolio_holdings`.
    *   If it's an existing stock holding: `UPDATE` `quantity_held` and recalculate `average_buy_price`.
4.  **Record a SELL transaction:** Insert into `transactions`.
5.  **Update `portfolio_holdings`:**
    *   `UPDATE` `quantity_held`. If `quantity_held` becomes zero, you might `DELETE` the row.
6.  **Update `current_prices`:** Periodically update this table with the latest market prices for your stocks (manual or via a script if using an API).
7.  **Run analysis queries:** Use the SELECT statements in `common_queries.sql` to view portfolio status, value, P/L, etc.

This project provides a solid SQL foundation for a stock portfolio tracker. Further enhancements could include a front-end interface, automated price updates via APIs, and more sophisticated financial calculations. 