CREATE TABLE stocks (
    stock_id INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol TEXT NOT NULL UNIQUE,
    company_name TEXT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    stock_id INTEGER NOT NULL,
    transaction_type TEXT NOT NULL CHECK(transaction_type IN ('BUY', 'SELL')),
    quantity INTEGER NOT NULL,
    price_per_share REAL NOT NULL,
    transaction_date DATE NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

CREATE TABLE portfolio_holdings (
    holding_id INTEGER PRIMARY KEY AUTOINCREMENT,
    stock_id INTEGER NOT NULL,
    quantity_held INTEGER NOT NULL,
    average_buy_price REAL NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

-- Optional: If you want to track users (for a multi-user system)
-- CREATE TABLE users (
--     user_id INTEGER PRIMARY KEY AUTOINCREMENT,
--     username TEXT NOT NULL UNIQUE,
--     email TEXT UNIQUE,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- If using users, portfolio_holdings and transactions would need a user_id FOREIGN KEY 