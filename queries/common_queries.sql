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

-- COMMON QUERIES FOR STOCK PORTFOLIO TRACKER

-- 1. Add a new stock to the master list of stocks
INSERT INTO stocks (symbol, company_name) VALUES ('NVDA', 'NVIDIA Corporation');
-- Note: After this, NVDA would get a new stock_id (e.g., 5 if following sample_data.sql)

-- 2. Record a BUY transaction
-- Assuming 'NVDA' now has stock_id = 5
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (5, 'BUY', 10, 300.00, '2023-06-01');

-- 3. Record a SELL transaction
-- Assuming 'AAPL' (stock_id = 1) is already held
INSERT INTO transactions (stock_id, transaction_type, quantity, price_per_share, transaction_date)
VALUES (1, 'SELL', 5, 180.00, '2023-06-05');

-- 4. Update portfolio_holdings after a BUY transaction (Important!)
-- This needs to be done carefully, handling new vs. existing holdings.

-- Example: For the NVDA BUY transaction above (assuming it's a new holding)
-- INSERT INTO portfolio_holdings (stock_id, quantity_held, average_buy_price)
-- VALUES (5, 10, 300.00);

-- Example: For a subsequent BUY of an *existing* holding (e.g., buying 5 more AAPL at $170 after initial buys)
-- First, get current holding details for AAPL (stock_id = 1):
-- SELECT quantity_held, average_buy_price FROM portfolio_holdings WHERE stock_id = 1;
-- (Let's assume it returned quantity_held = 25, average_buy_price = 156.67 from sample_data)
-- New quantity = 25 (old_qty) + 5 (bought_qty) = 30
-- New average_buy_price = ((156.67 * 25) + (170.00 * 5)) / (25 + 5) 
--                       = (3916.75 + 850) / 30 = 4766.75 / 30 = 158.89 (approx)
-- UPDATE portfolio_holdings
-- SET quantity_held = 30,
--     average_buy_price = 158.89
-- WHERE stock_id = 1;

-- 5. Update portfolio_holdings after a SELL transaction (Important!)
-- Example: For the AAPL SELL transaction above (selling 5 shares)
-- First, get current holding details for AAPL (stock_id = 1):
-- SELECT quantity_held FROM portfolio_holdings WHERE stock_id = 1;
-- (Let's assume it returned quantity_held = 25 from sample_data before this sell)
-- New quantity = 25 (old_qty) - 5 (sold_qty) = 20
-- (Average buy price usually doesn't change on a sell for this simple model)
-- UPDATE portfolio_holdings
-- SET quantity_held = 20
-- WHERE stock_id = 1;
-- (If quantity_held becomes 0, you might choose to DELETE the row from portfolio_holdings)

-- 6. View all current portfolio holdings with their current market value
SELECT 
    s.symbol,
    s.company_name,
    ph.quantity_held,
    ph.average_buy_price,
    cp.current_price AS current_market_price,
    (ph.quantity_held * cp.current_price) AS current_total_value
FROM portfolio_holdings ph
JOIN stocks s ON ph.stock_id = s.stock_id
JOIN current_prices cp ON ph.stock_id = cp.stock_id;

-- 7. Calculate the total current market value of the entire portfolio
SELECT 
    SUM(ph.quantity_held * cp.current_price) AS total_portfolio_market_value
FROM portfolio_holdings ph
JOIN current_prices cp ON ph.stock_id = cp.stock_id;

-- 8. View all transactions for a specific stock (e.g., AAPL, stock_id = 1)
SELECT t.transaction_date, s.symbol, t.transaction_type, t.quantity, t.price_per_share, (t.quantity * t.price_per_share) AS total_transaction_cost
FROM transactions t
JOIN stocks s ON t.stock_id = s.stock_id
WHERE s.symbol = 'AAPL' -- Or use t.stock_id = 1
ORDER BY t.transaction_date DESC;

-- 9. Calculate Unrealized Profit/Loss for each holding
SELECT 
    s.symbol,
    s.company_name,
    ph.quantity_held,
    ph.average_buy_price,
    cp.current_price AS current_market_price,
    (cp.current_price - ph.average_buy_price) * ph.quantity_held AS unrealized_profit_loss
FROM portfolio_holdings ph
JOIN stocks s ON ph.stock_id = s.stock_id
JOIN current_prices cp ON ph.stock_id = cp.stock_id;

-- 10. Calculate Total Unrealized Profit/Loss for the entire portfolio
SELECT 
    SUM((cp.current_price - ph.average_buy_price) * ph.quantity_held) AS total_unrealized_profit_loss
FROM portfolio_holdings ph
JOIN current_prices cp ON ph.stock_id = cp.stock_id;

-- 11. Calculate Realized Profit/Loss from a specific SELL transaction
-- This requires knowing the average buy price *at the time of sale* for the shares sold.
-- For simplicity, using the average_buy_price from portfolio_holdings. More complex accounting (FIFO/LIFO) is not shown here.
-- Example for a specific SELL transaction (e.g., transaction_id for a sell of AAPL, let's assume it was transaction_id = 4 from original sample data idea which was a SELL of 5 AAPL @ $170)
-- We need the average_buy_price of AAPL *before* this sale. From portfolio_holdings, it was 156.67 for AAPL (stock_id=1)
-- SELECT 
--     (sold_transaction.price_per_share - relevant_avg_buy_price.avg_price_at_sale) * sold_transaction.quantity AS realized_profit_loss
-- FROM transactions sold_transaction
-- -- This part is tricky: you need to join or subquery the avg_buy_price for stock_id=1 around the transaction_date
-- -- JOIN (SELECT average_buy_price FROM portfolio_history WHERE stock_id = 1 AND date < '2023-03-05' ORDER BY date DESC LIMIT 1) relevant_avg_buy_price_at_sale
-- WHERE sold_transaction.transaction_id = 4 AND sold_transaction.transaction_type = 'SELL';
-- For the sample data: (170 - 156.67) * 5 = 13.33 * 5 = $66.65 profit

-- A simpler way to show realized P/L is by looking at all SELL transactions and their corresponding avg_buy_price from holdings (snapshot)
-- This is an approximation as avg_buy_price in portfolio_holdings changes over time.
SELECT 
    s.symbol,
    t.transaction_date,
    t.quantity AS quantity_sold,
    t.price_per_share AS sell_price,
    ph.average_buy_price AS avg_buy_price_at_time_of_record, -- Note: This is the *current* avg_buy_price in holdings, not necessarily at the exact sale moment for historical sales.
    (t.price_per_share - ph.average_buy_price) * t.quantity AS estimated_realized_profit_loss
FROM transactions t
JOIN stocks s ON t.stock_id = s.stock_id
JOIN portfolio_holdings ph ON t.stock_id = ph.stock_id -- This links to current holding state
WHERE t.transaction_type = 'SELL';

-- To improve realized P/L, one might need a `portfolio_history` table that snapshots holdings and avg_buy_price daily, or implement logic to fetch avg_buy_price before the sale.

-- Note on portfolio_holdings maintenance:
-- The `portfolio_holdings` table represents the current state. It should be updated after every BUY or SELL.
-- BUY: 
--   If stock not in holdings: INSERT new row.
--   If stock exists in holdings: UPDATE quantity_held and average_buy_price.
--      new_avg_price = ((old_avg_price * old_quantity) + (buy_price * buy_quantity)) / (old_quantity + buy_quantity)
-- SELL:
--   UPDATE quantity_held.
--   If quantity_held becomes 0, consider DELETING the row from portfolio_holdings.
--   Average_buy_price typically doesn't change on a sell for average cost basis accounting. 