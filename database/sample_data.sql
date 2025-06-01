-- Sample Data for Stock Portfolio Tracker

-- STOCKS
INSERT INTO stocks (symbol, company_name) VALUES ('AAPL', 'Apple Inc.');       -- stock_id will be 1
INSERT INTO stocks (symbol, company_name) VALUES ('MSFT', 'Microsoft Corp.');  -- stock_id will be 2
INSERT INTO stocks (symbol, company_name) VALUES ('GOOGL', 'Alphabet Inc.'); -- stock_id will be 3
INSERT INTO stocks (symbol, company_name) VALUES ('TSLA', 'Tesla, Inc.');      -- stock_id will be 4

-- TRANSACTIONS
-- User buys 10 AAPL at $150 on 2023-01-10
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (1, 'BUY', 10, 150.00, '2023-01-10');

-- User buys 5 MSFT at $250 on 2023-01-15
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (2, 'BUY', 5, 250.00, '2023-01-15');

-- User buys 20 AAPL at $160 on 2023-02-01
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (1, 'BUY', 20, 160.00, '2023-02-01');

-- User sells 5 AAPL at $170 on 2023-03-05
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (1, 'SELL', 5, 170.00, '2023-03-05');

-- User buys 10 GOOGL at $100 on 2023-03-10
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (3, 'BUY', 10, 100.00, '2023-03-10');

-- User buys 5 TSLA at $200 on 2023-04-01
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (4, 'BUY', 5, 200.00, '2023-04-01');

-- User sells 2 MSFT at $280 on 2023-05-10
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (2, 'SELL', 2, 280.00, '2023-05-10');


-- PORTFOLIO HOLDINGS
-- Reflects the state *after* all the above transactions.
-- This table would typically be updated by application logic or triggers based on transactions.

-- AAPL: Bought 10, Bought 20, Sold 5. Current holding: 25 shares.
-- Avg Buy Price for AAPL: ((10 * 150) + (20 * 160)) / (10 + 20) = (1500 + 3200) / 30 = 4700 / 30 = 156.67 (approx)
INSERT INTO portfolio_holdings (stock_id, quantity_held, average_buy_price)
VALUES (1, 25, 156.67);

-- MSFT: Bought 5, Sold 2. Current holding: 3 shares.
-- Avg Buy Price for MSFT: (5 * 250) / 5 = 250.00
INSERT INTO portfolio_holdings (stock_id, quantity_held, average_buy_price)
VALUES (2, 3, 250.00);

-- GOOGL: Bought 10. Current holding: 10 shares.
-- Avg Buy Price for GOOGL: (10 * 100) / 10 = 100.00
INSERT INTO portfolio_holdings (stock_id, quantity_held, average_buy_price)
VALUES (3, 10, 100.00);

-- TSLA: Bought 5. Current holding: 5 shares.
-- Avg Buy Price for TSLA: (5 * 200) / 5 = 200.00
INSERT INTO portfolio_holdings (stock_id, quantity_held, average_buy_price)
VALUES (4, 5, 200.00);


-- CURRENT PRICES (Simulated as of a certain date, e.g., today)
INSERT INTO current_prices (stock_id, current_price)
VALUES (1, 175.50); -- AAPL current price

INSERT INTO current_prices (stock_id, current_price)
VALUES (2, 285.20); -- MSFT current price

INSERT INTO current_prices (stock_id, current_price)
VALUES (3, 105.80); -- GOOGL current price

INSERT INTO current_prices (stock_id, current_price)
VALUES (4, 190.75); -- TSLA current price 