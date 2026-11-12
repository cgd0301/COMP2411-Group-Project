-- File:          stage2/scratch/verify_seed.sql (working file, not submitted)
-- Purpose:       Check that sql/01_schema.sql + sql/02_data.sql build the seed baseline
--                described in stage2/notes/seed_cast.md and seed_timelines.md.
-- Prerequisites: run in the scratch database, in the mysql command-line client:
--
--   mysql -u <your account> -p comp2411_g085_scratch
--   source D:/programs/COMP2411/comp2411-project/stage2/COMP2411_2026_G085_Stage2/sql/01_schema.sql
--   source D:/programs/COMP2411/comp2411-project/stage2/COMP2411_2026_G085_Stage2/sql/02_data.sql
--   SHOW WARNINGS;          -- expected: Empty set
--   source D:/programs/COMP2411/comp2411-project/stage2/scratch/verify_seed.sql
--
-- Every query below lists its expected result. Any difference, error or warning means
-- the workbook or 02_data.sql must be fixed (then run export_seed_sql.ps1 again).

-- V1 Row count per table.
-- Expected: season 4, product 40, customer 15, subscription 25, chosen_products 64,
--           delivery 198, add_on 11, refund 15.
SELECT 'season' AS table_name, COUNT(*) AS row_count FROM season
UNION ALL SELECT 'product', COUNT(*) FROM product
UNION ALL SELECT 'customer', COUNT(*) FROM customer
UNION ALL SELECT 'subscription', COUNT(*) FROM subscription
UNION ALL SELECT 'chosen_products', COUNT(*) FROM chosen_products
UNION ALL SELECT 'delivery', COUNT(*) FROM delivery
UNION ALL SELECT 'add_on', COUNT(*) FROM add_on
UNION ALL SELECT 'refund', COUNT(*) FROM refund;

-- V2 Delivery status distribution.
-- Expected: cancelled 26, failed 2, planned 27, skipped 10, success 133.
SELECT status, COUNT(*) AS deliveries
FROM delivery
GROUP BY status
ORDER BY status;

-- V3 Subscription status distribution.
-- Expected: active 5, cancelled 5, finished 12, planned 3.
SELECT status, COUNT(*) AS subscriptions
FROM subscription
GROUP BY status
ORDER BY status;

-- V4 Refunds per type.
-- Expected: cancelled 4 / 2526.00, failed 2 / 470.00, skipped 9 / 1726.00.
SELECT type, COUNT(*) AS refunds, SUM(amount) AS total_amount
FROM refund
GROUP BY type
ORDER BY type;

-- V5 Add-on lines and total add-on fee.
-- Expected: 11 lines, 608.50 (Spring 2026 510.50 + Summer 2026 98.00).
SELECT COUNT(*) AS add_on_lines, SUM(a.weight * p.price_per_kg) AS total_fee
FROM add_on AS a
JOIN product AS p ON p.product_id = a.product_id;

-- V6 Refunds without a delivery are exactly the cancellation refunds (legitimate NULLs).
-- Expected: 4 rows, refund_id 1, 2, 13, 15, all of type 'cancelled'.
SELECT refund_id, subscription_id, type
FROM refund
WHERE week_no IS NULL
ORDER BY refund_id;
