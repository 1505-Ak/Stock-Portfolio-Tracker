# Stock Portfolio Tracker

This project is a SQL-based stock portfolio tracker. It allows users to manage their stock portfolios, track transactions, and analyze performance.

## Features (Planned)

*   Track stock purchases and sales.
*   View current portfolio holdings.
*   Calculate the current market value of the portfolio.
*   Analyze profit/loss for individual stocks and the overall portfolio.
*   View transaction history.

## Database Schema

The database will consist of the following tables:

*   `stocks`: Information about different stocks (e.g., symbol, company name).
*   `transactions`: Records of stock buy/sell transactions.
*   `portfolio_holdings`: Current snapshot of stocks held.
    *(Potentially `users` if we decide to make it multi-user)*

## Setup

1.  Clone the repository.
2.  Set up your preferred SQL database (e.g., PostgreSQL, MySQL, SQLite).
3.  Execute the `database/schema.sql` file to create the tables.
4.  (Optional) Execute `database/sample_data.sql` to populate the database with some initial data for testing.

## Queries

Example queries can be found in the `queries/` directory. These will help in retrieving and analyzing portfolio data. 