-- Run one statement at a time on an empty database after sql/01_schema.sql.
-- A failed statement leaves the earlier rows in place. A later section deletes child tables and inserts the setup it shows.
-- Valid: normally insert a customer
INSERT INTO customer (customer_id, name, email, street, building, room)
    VALUES (1, 'Probe Customer_1', 'probe@example_1.com', 'Probe street', 'Block A', '101');

-- Invalid: same customer_id
-- Expected error: 1062
INSERT INTO customer (customer_id, name, email, street, building, room)
    VALUES (1, 'Probe Customer_2', 'probe@example_2.com', 'Probe Street', 'Block A', '101');

-- Invalid: same email address
-- Expected error: 1062
INSERT INTO customer (customer_id, name, email, street, building, room)
    VALUES (2, 'Probe Customer_2', 'probe@example_1.com', 'Probe Street', 'Block A', '101');





-- Valid: normally insert a season
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (1, 'summer', 2026, '2026-06-01');

-- Invalid: same season_id
-- Expected error: 1062
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (1, 'autumn', 2026, '2026-11-02');

-- Invalid: same season_name, year combination
-- Expected error: 1062
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'summer', 2026, '2026-06-08');


-- Invalid: same first_planning_day
-- Expected error: 1062
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'autumn', 2026, '2026-06-01');

-- Invalid: season_name invalid
-- Expected error: 3819
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'winter', 2026, '2026-11-02');

-- Invalid: day of a week of first_planning_day
-- Expected error: 3819
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'spring', 2027, '2027-03-02');

-- CL09: Monday, but the date's year is not the season's year. Expected: 3819 ck_season_year
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'spring', 2027, '2026-06-08');

-- D17: uppercase is not the stored value. Expected: 3819 ck_season_season_name
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'Summer', 2027, '2026-06-08');



DELETE FROM add_on;
DELETE FROM refund;
DELETE FROM chosen_products;
DELETE FROM delivery;
DELETE FROM product;
DELETE FROM subscription;
DELETE FROM customer;
DELETE FROM season;

INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (1, 'summer', 2026, '2026-06-01');
-- Valid: normally insert a product
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (1, 1, 'Probe Product_1', TRUE, 1.00);

-- Invalid: same product_id
-- Expected error: 1062
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (1, 1, 'Probe Product_2', TRUE, 1.00);

-- Invalid: foriegn key season_id not exists
-- Expected error: 1452
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (2, 9999, 'Probe Product_2', TRUE, 1.00);

-- Invalid: season_id col is null
-- Expected error: 1048
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (2, NULL, 'Probe Product_2', TRUE, 1.00);

-- Invalid: same season_id, name combination
-- Expected error: 1062
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (2, 1, 'Probe Product_1', TRUE, 1.00);

-- Invalid: price_per_kg smaller than 0
-- Expected error: 3819
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (2, 1, 'Probe Product_2', TRUE, -1.00);

-- CL08. Expected: 3819 ck_product_is_farmers_choice
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg)
    VALUES (2, 1, 'Probe Product_2', 2, 1.00);


DELETE FROM add_on;
DELETE FROM refund;
DELETE FROM chosen_products;
DELETE FROM delivery;
DELETE FROM product;
DELETE FROM subscription;
DELETE FROM customer;
DELETE FROM season;

INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (1, 'summer', 2026, '2026-06-01');

INSERT INTO customer (customer_id, name, email, street, building, room)
    VALUES (1, 'Probe Name', 'probe@example_1.com', 'Probe Street', 'Block A', '101');
INSERT INTO subscription (
    subscription_id, customer_id, season_id,
    plan_type, frequency, allocated_cost, submission_date)
    VALUES (1, 1, 1, 'farmer''s choice', 'weekly', 200.00, '2026-04-01');
INSERT INTO delivery (subscription_id, week_no, status)
    VALUES (1, 1, 'success');
INSERT INTO delivery (subscription_id, week_no, status)
    VALUES (1, 2, 'skipped');
INSERT INTO delivery (subscription_id, week_no, status)
    VALUES (1, 3, 'planned');

INSERT INTO customer (customer_id, name, email, street, building, room)
    VALUES (2, 'Probe Name', 'probe@example_2.com', 'Probe Street', 'Block A', '101');
INSERT INTO subscription (
    subscription_id, customer_id, season_id, status,
    plan_type, frequency, allocated_cost, submission_date, cancellation_date)
    VALUES (2, 2, 1, 'cancelled', 'farmer''s choice', 'weekly', 200.00, '2026-04-01', '2026-04-02');
INSERT INTO delivery (subscription_id, week_no, status)
    VALUES (2, 1, 'cancelled');

-- Valid: normally insert a refund
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (1, 1, 2, 200.00, 'skipped', '2026-06-05');

-- Valid: cancellation refund with no delivery (NULL week_no is not checked by fk_refund_delivery)
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (3, 2, NULL, 2400.00, 'cancelled', '2026-04-02');

-- Invalid: same refund_id
-- Expected error: 1062
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (1, 2, NULL, 2400.00, 'cancelled', '2026-04-02');

-- Invalid: foreign key subscription_id not exists
-- Expected error: 1452
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 9999, NULL, 2400.00, 'cancelled', '2026-04-02');

-- Invalid: foreign key subscription_id, week_no combination in delivery not exist
-- Expected error: 1452
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 1, 4, 2400.00, 'skipped', '2026-04-02');
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 2, 2, 2400.00, 'skipped', '2026-04-02');

-- Invalid: subscription_id col should not be null
-- Expected error: 1048
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, NULL, NULL, 2400.00, 'cancelled', '2026-04-02');

-- Invalid: a second refund for the same delivery (subscription_id, week_no) not UNIQUE
-- Expected error: 1062
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 1, 2, 200.00, 'skipped', '2026-06-05');

-- Invalid: refund amount <= 0
-- Expected error: 3819
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 2, NULL, 0.00, 'cancelled', '2026-04-02');
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 2, NULL, -1.00, 'cancelled', '2026-04-02');

-- Invalid: refund type invalid
-- Expected error: 3819
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 2, NULL, 2400.00, 'Pending', '2026-04-02');

-- D17: type differs only by case. Expected: 3819 ck_refund_type
INSERT INTO refund (refund_id, subscription_id, week_no, amount, type, refund_date)
    VALUES (2, 1, 1, 200.00, 'Skipped', '2026-06-05');

-- subscription

DELETE FROM add_on;
DELETE FROM refund;
DELETE FROM chosen_products;
DELETE FROM delivery;
DELETE FROM subscription;
-- customer 1, customer 2 and season 1 remain from the refund section.
-- These three inserts are reused by the chosen_products, delivery and add_on sections.
-- product 1 costs 32.00, so 1.50 kg in PROBE-A01 costs 48.00.
INSERT INTO customer (customer_id, name, email, street, building, room)
    VALUES (3, 'Probe Name', 'probe@example_3.com', 'Probe Street', 'Block A', '101');
INSERT INTO season (season_id, season_name, year, first_planning_day)
    VALUES (2, 'autumn', 2026, '2026-09-07');
INSERT INTO product (product_id, season_id, name, is_farmers_choice, price_per_kg) VALUES
    (1, 1, 'Probe Product_1', TRUE, 32.00),
    (2, 1, 'Probe Product_2', TRUE,  1.00),
    (3, 1, 'Probe Product_3', TRUE,  1.00),
    (4, 1, 'Probe Product_4', TRUE,  1.00),
    (5, 1, 'Probe Product_5', TRUE,  1.00),
    (6, 1, 'Probe Product_6', TRUE,  1.00),
    (7, 1, 'Probe Product_7', TRUE,  1.00),
    (8, 1, 'Probe Product_8', TRUE,  1.00),
    (9, 1, 'Probe Product_9', TRUE,  1.00),
    (10, 1, 'Probe Product_10', TRUE, 1.00);
INSERT INTO subscription (subscription_id, customer_id, season_id, plan_type,
                          frequency, allocated_cost, submission_date) VALUES
    (1, 1, 1, 'farmer''s choice', 'weekly',   200.00, '2026-01-10'),
    (2, 2, 1, 'customizable',     'biweekly', 240.00, '2026-01-15'),
    (3, 1, 2, 'farmer''s choice', 'weekly',   160.00, '2026-04-01');
-- Invalid: same subscription_id
-- Expected error: 1062
INSERT INTO subscription (subscription_id, customer_id, season_id, plan_type,
                          frequency, allocated_cost, submission_date)
    VALUES (1, 3, 1, 'farmer''s choice', 'weekly', 200.00, '2026-03-01');
INSERT INTO chosen_products (subscription_id, product_id) VALUES
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 7), (2, 8), (2, 9), (2, 10);
INSERT INTO delivery (subscription_id, week_no) VALUES
    (1, 1), (1, 2), (1, 3), (2, 1), (2, 3), (2, 5);

-- PROBE-S01  VALID      -- Expected error: none
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (2, 2, 'customizable', 'weekly', 192.00, '2026-04-02');
SELECT status, remaining_refundable_skip, cancellation_date
FROM subscription WHERE customer_id = 2 AND season_id = 2;        -- Expected: 'planned', 2, NULL

-- PROBE-S06a VALID      -- Expected error: none
UPDATE subscription SET status = 'cancelled', cancellation_date = '2026-02-01'
WHERE subscription_id = 1;

-- PROBE-S13a VALID      -- Expected error: none
UPDATE subscription SET remaining_refundable_skip = 0 WHERE subscription_id = 1;

-- PROBE-S02  INVALID    -- Expected error: 1452
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (9999, 1, 'farmer''s choice', 'weekly', 200.00, '2026-01-20');

-- PROBE-S03  INVALID    -- Expected error: 1452
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (3, 999, 'farmer''s choice', 'weekly', 200.00, '2026-01-20');

-- PROBE-S04  INVALID    -- Expected error: 1048
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (NULL, 1, 'farmer''s choice', 'weekly', 200.00, '2026-01-20');

-- PROBE-S05  INVALID    -- Expected error: 1048
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (3, NULL, 'farmer''s choice', 'weekly', 200.00, '2026-01-20');

-- PROBE-S06b INVALID    -- Expected error: 1062
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (1, 1, 'customizable', 'weekly', 240.00, '2026-02-02');

-- PROBE-S07  INVALID    -- Expected error: 3819
UPDATE subscription SET status = 'paused' WHERE subscription_id = 2;

-- PROBE-S08  INVALID    -- Expected error: 3819
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (3, 1, 'farmer''s choice', 'monthly', 200.00, '2026-01-20');

-- PROBE-S09  INVALID    -- Expected error: 3819
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (3, 1, 'premium', 'weekly', 200.00, '2026-01-20');

-- PROBE-S10  INVALID    -- Expected error: 3819
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (3, 1, 'farmer''s choice', 'weekly', 240.00, '2026-01-20');

-- PROBE-S11  INVALID    -- Expected error: 3819
INSERT INTO subscription (customer_id, season_id, plan_type, frequency, allocated_cost, submission_date)
VALUES (3, 1, 'customizable', 'weekly', 180.00, '2026-01-20');

-- PROBE-S12  INVALID    -- Expected error: 3819
UPDATE subscription SET remaining_refundable_skip = 3 WHERE subscription_id = 1;

-- PROBE-S13b INVALID    -- Expected error: 3819
UPDATE subscription SET remaining_refundable_skip = remaining_refundable_skip - 1
WHERE subscription_id = 1;

-- PROBE-S14  INVALID    -- Expected error: 1406
UPDATE subscription SET status = 'cancelled_x' WHERE subscription_id = 2;

-- CL06: cancelled without a date. Expected: 3819 ck_subscription_cancellation
UPDATE subscription SET status = 'cancelled', cancellation_date = NULL WHERE subscription_id = 2;

-- CL06: date set while status is not cancelled. Expected: 3819 ck_subscription_cancellation
UPDATE subscription SET cancellation_date = '2026-02-01' WHERE subscription_id = 2;

-- CL07: cancelled before submission. Expected: 3819 ck_subscription_cancellation_date
UPDATE subscription SET status = 'cancelled', cancellation_date = '2026-01-01' WHERE subscription_id = 2;

-- D17. Expected: 3819 and the matching ck_ name
UPDATE subscription SET status = 'PLANNED' WHERE subscription_id = 2;
UPDATE subscription SET plan_type = 'Customizable' WHERE subscription_id = 2;
UPDATE subscription SET frequency = 'Weekly' WHERE subscription_id = 2;
UPDATE delivery SET status = 'SUCCESS' WHERE subscription_id = 1 AND week_no = 1;

-- PROBE-X05  INVALID    -- Expected error: 1451
DELETE FROM customer WHERE customer_id = 1;-- chosen_products

DELETE FROM add_on;
DELETE FROM refund;
DELETE FROM chosen_products;
DELETE FROM delivery;
DELETE FROM subscription;
INSERT INTO subscription (subscription_id, customer_id, season_id, plan_type,
                          frequency, allocated_cost, submission_date) VALUES
    (1, 1, 1, 'farmer''s choice', 'weekly',   200.00, '2026-01-10'),
    (2, 2, 1, 'customizable',     'biweekly', 240.00, '2026-01-15'),
    (3, 1, 2, 'farmer''s choice', 'weekly',   160.00, '2026-04-01');
INSERT INTO chosen_products (subscription_id, product_id) VALUES
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 7), (2, 8), (2, 9), (2, 10);
INSERT INTO delivery (subscription_id, week_no) VALUES
    (1, 1), (1, 2), (1, 3), (2, 1), (2, 3), (2, 5);

-- PROBE-C01  VALID      -- Expected error: none
INSERT INTO chosen_products (subscription_id, product_id) VALUES (2, 5);
DELETE FROM chosen_products WHERE subscription_id = 2 AND product_id = 5;
SELECT COUNT(*) FROM chosen_products WHERE subscription_id = 2;   -- Expected: 8

-- PROBE-C02  INVALID    -- Expected error: 1062
INSERT INTO chosen_products (subscription_id, product_id) VALUES (2, 1);

-- PROBE-C03  INVALID    -- Expected error: 1452
INSERT INTO chosen_products (subscription_id, product_id) VALUES (9999, 1);

-- PROBE-C04  INVALID    -- Expected error: 1452
INSERT INTO chosen_products (subscription_id, product_id) VALUES (2, 9999);

-- PROBE-C05  INVALID    -- Expected error: 1048
INSERT INTO chosen_products (subscription_id, product_id) VALUES (2, NULL);

-- PROBE-X04  INVALID    -- Expected error: 1451
DELETE FROM product WHERE product_id = 1;

-- delivery

DELETE FROM add_on;
DELETE FROM refund;
DELETE FROM chosen_products;
DELETE FROM delivery;
DELETE FROM subscription;
INSERT INTO subscription (subscription_id, customer_id, season_id, plan_type,
                          frequency, allocated_cost, submission_date) VALUES
    (1, 1, 1, 'farmer''s choice', 'weekly',   200.00, '2026-01-10'),
    (2, 2, 1, 'customizable',     'biweekly', 240.00, '2026-01-15'),
    (3, 1, 2, 'farmer''s choice', 'weekly',   160.00, '2026-04-01');
INSERT INTO chosen_products (subscription_id, product_id) VALUES
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 7), (2, 8), (2, 9), (2, 10);
INSERT INTO delivery (subscription_id, week_no) VALUES
    (1, 1), (1, 2), (1, 3), (2, 1), (2, 3), (2, 5);

-- PROBE-D01  VALID      -- Expected error: none
INSERT INTO delivery (subscription_id, week_no) VALUES (1, 12);
SELECT status FROM delivery WHERE subscription_id = 1 AND week_no = 12;   -- Expected: 'planned'

-- PROBE-X06  VALID      -- Expected error: none
DELETE FROM delivery WHERE subscription_id = 1 AND week_no = 12;

-- PROBE-D02  INVALID    -- Expected error: 1062
INSERT INTO delivery (subscription_id, week_no) VALUES (1, 1);

-- PROBE-D03  INVALID    -- Expected error: 1452
INSERT INTO delivery (subscription_id, week_no) VALUES (9999, 1);

-- PROBE-D04  INVALID    -- Expected error: 3819
INSERT INTO delivery (subscription_id, week_no) VALUES (1, 13);

-- PROBE-D05  INVALID    -- Expected error: 3819
INSERT INTO delivery (subscription_id, week_no) VALUES (1, 0);

-- PROBE-D06  INVALID    -- Expected error: 3819
INSERT INTO delivery (subscription_id, week_no) VALUES (1, -1);

-- PROBE-D07  INVALID    -- Expected error: 1264
INSERT INTO delivery (subscription_id, week_no) VALUES (1, 128);

-- PROBE-D08  INVALID    -- Expected error: 1048
INSERT INTO delivery (subscription_id, week_no) VALUES (1, NULL);

-- PROBE-D09  INVALID    -- Expected error: 3819
UPDATE delivery SET status = 'delivered' WHERE subscription_id = 1 AND week_no = 1;

-- PROBE-X01  INVALID    -- Expected error: 1451
DELETE FROM subscription WHERE subscription_id = 1;

-- PROBE-X07  INVALID    -- Expected error: 3819
INSERT INTO delivery (subscription_id, week_no) VALUES (1, 4), (1, 13);

--add_on
DELETE FROM add_on;
DELETE FROM refund;
DELETE FROM chosen_products;
DELETE FROM delivery;
DELETE FROM subscription;
INSERT INTO subscription (subscription_id, customer_id, season_id, plan_type,
                          frequency, allocated_cost, submission_date) VALUES
    (1, 1, 1, 'farmer''s choice', 'weekly',   200.00, '2026-01-10'),
    (2, 2, 1, 'customizable',     'biweekly', 240.00, '2026-01-15'),
    (3, 1, 2, 'farmer''s choice', 'weekly',   160.00, '2026-04-01');
INSERT INTO chosen_products (subscription_id, product_id) VALUES
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 7), (2, 8), (2, 9), (2, 10);
INSERT INTO delivery (subscription_id, week_no) VALUES
    (1, 1), (1, 2), (1, 3), (2, 1), (2, 3), (2, 5);-- PROBE-A01  VALID      -- Expected error: none
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 1, 1, 1.50);
SELECT a.weight * p.price_per_kg AS add_on_fee
FROM add_on a JOIN product p ON p.product_id = a.product_id
WHERE a.subscription_id = 1 AND a.week_no = 1;                     -- Expected: 48.00

-- PROBE-A07  VALID      -- Expected error: none
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 2, 2, 0.10);

-- PROBE-A08a VALID      -- Expected error: none
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 2, 3, 0.095);
SHOW WARNINGS;                                                     -- Expected: Note 1265

-- PROBE-A02  INVALID    -- Expected error: 1062
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 1, 1, 2.00);

-- PROBE-A03  INVALID    -- Expected error: 1452
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (2, 2, 1, 1.00);

-- PROBE-A04  INVALID    -- Expected error: 1452
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 13, 1, 1.00);

-- PROBE-A05  INVALID    -- Expected error: 1452
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 2, 9999, 1.00);

-- PROBE-A06  INVALID    -- Expected error: 3819
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 2, 4, 0.05);

-- PROBE-A08b INVALID    -- Expected error: 3819
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 2, 4, 0.094);

-- PROBE-A09  INVALID    -- Expected error: 3819
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 3, 1, -1.00);

-- PROBE-A10  INVALID    -- Expected error: 1264
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 3, 1, 1000.00);

-- PROBE-A11  INVALID    -- Expected error: 1048
INSERT INTO add_on (subscription_id, week_no, product_id, weight) VALUES (1, 3, 1, NULL);

-- PROBE-X02  INVALID    -- Expected error: 1451
DELETE FROM delivery WHERE subscription_id = 1 AND week_no = 1;

-- PROBE-X03  INVALID    -- Expected error: 1451 (week 4 is valid; add_on still references this delivery)
UPDATE delivery SET week_no = 4 WHERE subscription_id = 1 AND week_no = 1;