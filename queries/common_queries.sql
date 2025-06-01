-- Calculate total value of a specific stock holding
-- SELECT s.symbol, ph.quantity_held * current_market_price_api_or_table.price AS current_value
-- FROM portfolio_holdings ph
-- JOIN stocks s ON ph.stock_id = s.stock_id
-- JOIN current_market_price_api_or_table cmp ON s.stock_id = cmp.stock_id -- This table/API would need to be populated with live prices
-- WHERE ph.stock_id = YOUR_STOCK_ID;

-- Calculate total portfolio value (requires current prices for all stocks held)
-- SELECT SUM(ph.quantity_held * cmp.price) AS total_portfolio_value
-- FROM portfolio_holdings ph
-- JOIN stocks s ON ph.stock_id = s.stock_id
-- JOIN current_market_price_api_or_table cmp ON s.stock_id = cmp.stock_id;

-- View all transactions for a specific stock
SELECT t.transaction_date, s.symbol, t.transaction_type, t.quantity, t.price_per_share
FROM transactions t
JOIN stocks s ON t.stock_id = s.stock_id
WHERE t.stock_id = 1 -- Replace 1 with actual stock_id
ORDER BY t.transaction_date DESC;

-- View all current holdings
SELECT s.symbol, s.company_name, ph.quantity_held, ph.average_buy_price
FROM portfolio_holdings ph
JOIN stocks s ON ph.stock_id = s.stock_id;

-- Calculate profit/loss for a sold stock (Simplified - does not account for partial sales or FIFO/LIFO)
-- This example assumes you have a record of the sale in transactions and know the average buy price
-- SELECT 
--    (sell_transaction.price_per_share - holding.average_buy_price) * sell_transaction.quantity AS profit_loss
-- FROM transactions sell_transaction
-- JOIN portfolio_holdings holding ON sell_transaction.stock_id = holding.stock_id 
-- WHERE sell_transaction.transaction_id = YOUR_SELL_TRANSACTION_ID AND sell_transaction.transaction_type = 'SELL';

-- Add a new stock to the stocks table
INSERT INTO stocks (symbol, company_name) VALUES ('AAPL', 'Apple Inc.');

-- Record a BUY transaction
-- Assuming 'AAPL' has stock_id = 1 after insertion
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (1, 'BUY', 10, 150.00, '2023-10-26');

-- (After a BUY, you would typically update or insert into portfolio_holdings. This logic can be complex and might be handled by application code or more advanced SQL procedures/triggers)

-- Example: Update portfolio_holdings after a BUY (simple case, new stock)
-- INSERT INTO portfolio_holdings (stock_id, quantity_held, average_buy_price)
-- VALUES (1, 10, 150.00);

-- Example: Update portfolio_holdings after a BUY (existing stock)
-- UPDATE portfolio_holdings
-- SET quantity_held = quantity_held + NEW_PURCHASE_QUANTITY,
--     average_buy_price = ((average_buy_price * quantity_held) + (NEW_PURCHASE_PRICE * NEW_PURCHASE_QUANTITY)) / (quantity_held + NEW_PURCHASE_QUANTITY)
-- WHERE stock_id = EXISTING_STOCK_ID; 