# Stock Portfolio Tracker

This project is a SQL-based stock portfolio tracker. It allows users to manage their stock portfolios, track transactions, calculate current valuations, and analyze performance. This project is designed to showcase SQL skills including database schema design, data manipulation (DML), and complex querying for financial analysis.

## Features

*   Track stock purchases and sales via a `transactions` table.
*   Maintain a list of unique `stocks` with their company names.
*   Keep a `portfolio_holdings` table reflecting the current quantity and average buy price of owned stocks.
*   Simulate `current_prices` for stocks to enable market valuation.
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
*   `current_prices`: Stores (simulated) current market prices for stocks to value the portfolio.
    *   `price_id` (PK), `stock_id` (FK), `current_price`, `last_updated`

## Setup & Usage

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:1505-Ak/Stock-Portfolio-Tracker.git
    cd Stock-Portfolio-Tracker
    ```

2.  **Database Setup:**
    *   Choose your preferred SQL database system (e.g., PostgreSQL, MySQL, SQLite).
    *   Connect to your database server/instance.
    *   Execute the `database/schema.sql` script to create all necessary tables:
        ```sql
        -- Example for psql (PostgreSQL)
        -- \i path/to/Stock-Portfolio-Tracker/database/schema.sql 
        -- Example for SQLite CLI
        -- .read path/to/Stock-Portfolio-Tracker/database/schema.sql
        ```

3.  **Populate with Sample Data (Recommended for Testing):**
    *   Execute the `database/sample_data.sql` script to populate the tables with a set of stocks, transactions, holdings, and current prices.
        ```sql
        -- Example for psql (PostgreSQL)
        -- \i path/to/Stock-Portfolio-Tracker/database/sample_data.sql
        -- Example for SQLite CLI
        -- .read path/to/Stock-Portfolio-Tracker/database/sample_data.sql
        ```

4.  **Explore Queries:**
    *   The `queries/common_queries.sql` file contains a variety of useful SQL queries to interact with the database. You can run these in your SQL client to:
        *   Add new stocks and transactions.
        *   View current holdings and their market values.
        *   Calculate total portfolio value.
        *   Analyze profit and loss.
    *   **Important Note on `portfolio_holdings`:** The `sample_data.sql` script pre-calculates the `portfolio_holdings` based on its transactions. In a real application, you would need application logic or database triggers/procedures to automatically update `portfolio_holdings` after each BUY or SELL transaction. The `common_queries.sql` file includes commented-out examples and notes on how to perform these updates manually.

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