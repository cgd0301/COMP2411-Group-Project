-- File:          stage2/scratch/seed_checks.sql (working file, not submitted)
-- Purpose:       check the validity of the seed data
-- Related IDs:   CHK-01 - CHK-15, I01 - I15
-- Prerequisites: sql/01_schema.sql and sql/02_data.sql have been run
-- Note:          Every check returns only the rows that break its invariant, so an
--                empty result means the check passes. The helper views below are
--                DDL: create them before START TRANSACTION when testing a check by
--                mutation, because DDL commits the open transaction.

-- find the season id with season id of previous subscription season
CREATE OR REPLACE VIEW season_with_pre AS
SELECT 
    se.season_id   AS  current_season_id,
    prev.season_id AS  previous_season_id
FROM season AS se 
LEFT JOIN season AS prev
    ON prev.season_name = CASE se.season_name
                            WHEN 'spring' THEN 'autumn'
                            WHEN 'summer' THEN 'spring'
                            ELSE 'summer'
                        END
    AND prev.year = IF(se.season_name = 'spring', se.year - 1, se.year);

-- calculate the start date and end date of a season
CREATE OR REPLACE VIEW season_range AS
SELECT
    se.season_id,
    DATE_SUB(se.first_planning_day, INTERVAL 6 DAY)   AS  start_date,
    DATE_ADD(se.first_planning_day, INTERVAL 77 DAY)  AS  end_date
FROM season AS se;


CREATE OR REPLACE VIEW is_renewal_subscription AS
SELECT
    cur_subs.subscription_id AS cur_subs_id,
    pre_subs.subscription_id AS pre_subs_id,
    CASE WHEN pre_subs.subscription_id IS NOT NULL AND (pre_subs.cancellation_date IS NULL OR pre_subs.cancellation_date > cur_subs.submission_date)
        THEN 1 ELSE 0 
    END AS is_renewal
FROM subscription AS cur_subs
LEFT JOIN subscription AS pre_subs 
    ON cur_subs.customer_id = pre_subs.customer_id
    AND pre_subs.season_id = (
        SELECT previous_season_id 
        FROM season_with_pre 
        WHERE season_with_pre.current_season_id = cur_subs.season_id
    );

CREATE OR REPLACE VIEW date_of_delivery AS
SELECT
    del.subscription_id AS subscription_id,
    del.week_no AS week_no,
    DATE_ADD(se.first_planning_day, INTERVAL del.week_no - 1 WEEK) AS delivery_date,
    GREATEST(DATE_SUB(
        DATE_ADD(se.first_planning_day, INTERVAL del.week_no - 1 WEEK), 
        INTERVAL IF(subs.frequency = 'weekly', 6, 13) DAY),
        DATE_SUB(se.first_planning_day, INTERVAL 6 DAY)) AS start_window,
    DATE_SUB(DATE_ADD(se.first_planning_day, INTERVAL del.week_no - 1 WEEK),
        INTERVAL 1 DAY) AS end_window
FROM delivery AS del
LEFT JOIN subscription AS subs ON del.subscription_id = subs.subscription_id
LEFT JOIN season AS se ON subs.season_id = se.season_id;



-- CHK-01 (I01)
SELECT season_id, COUNT(product_id) AS cnt FROM (
    SELECT 
        se.season_id AS season_id,
        pro.product_id AS product_id
    FROM season AS se
    LEFT JOIN product AS pro
    ON se.season_id = pro.season_id) AS t
GROUP BY season_id HAVING cnt != 10;

SELECT season_id, COUNT(product_id) AS cnt FROM (
    SELECT
        se.season_id AS season_id,
        pro.product_id AS product_id
    FROM season AS se
    LEFT JOIN product AS pro
    ON se.season_id = pro.season_id AND pro.is_farmers_choice = 1) AS t
GROUP BY season_id HAVING cnt != 6;

-- CHK-02 (I02)
-- check whether the submission date is between the corresponding window
-- (the windows are written as literals for the four seed seasons, D01 and D22)
SELECT subscription_id FROM subscription 
    WHERE ((SELECT season_name FROM season WHERE season.season_id = subscription.season_id) = 'summer'
    AND submission_date 
        NOT BETWEEN "2026-02-24" AND "2026-05-18")
    OR ((SELECT season_name FROM season WHERE season.season_id = subscription.season_id) = 'spring'
        AND submission_date 
        NOT BETWEEN "2025-11-25" AND "2026-02-23")
    OR ((SELECT season_name FROM season WHERE season.season_id = subscription.season_id) = 'autumn'
        AND 
        ((2025, 'autumn') = (SELECT year, season_name FROM season WHERE season.season_id = subscription.season_id)
                AND submission_date NOT BETWEEN "2025-05-27" AND "2025-08-18")
            OR ((2026, 'autumn') = (SELECT year, season_name FROM season WHERE season.season_id = subscription.season_id)
                AND submission_date NOT BETWEEN "2026-05-26" AND "2026-08-17"))
    -- the seed is the state at the start of 2026-07-07, so no later submission exists
    OR submission_date > "2026-07-06";

-- CHK-03 (I03)
-- check the discount price is correct
SELECT subscription_id FROM subscription
    WHERE allocated_cost != CASE
        WHEN (SELECT is_renewal FROM is_renewal_subscription WHERE cur_subs_id = subscription_id) = 1
            THEN CASE
                WHEN plan_type = 'farmer''s choice' THEN 160
                ELSE 192 END
            ELSE CASE
                WHEN plan_type = 'farmer''s choice' THEN 200
                ELSE 240 END
        END;


-- CHK-04 (I04)
-- check the status of each subscription is correct
SELECT subscription_id FROM subscription
    WHERE status != 'cancelled' AND status != (
        CASE 
            WHEN (2026, 'summer') = (SELECT year, season_name FROM season WHERE season.season_id = subscription.season_id)
                THEN 'active'
            WHEN ((2025, 'autumn') = (SELECT year, season_name FROM season WHERE season.season_id = subscription.season_id)
            OR (2026, 'spring') = (SELECT year, season_name FROM season WHERE season.season_id = subscription.season_id))
                THEN 'finished'
            WHEN (2026, 'autumn') = (SELECT year, season_name FROM season WHERE season.season_id = subscription.season_id)
                THEN 'planned'
        END
    );

-- CHK-05 (I05)
-- check the correctness of cancellation date
SELECT subscription_id, cancellation_date FROM subscription
    WHERE cancellation_date IS NOT NULL
        AND (cancellation_date > (SELECT end_date FROM season_range WHERE season_range.season_id = subscription.season_id)
            OR cancellation_date < submission_date
            OR cancellation_date > "2026-07-06");

-- CHK-06 (I06)
-- check the correctness of refundable skipping time
SELECT subscription_id FROM subscription
    WHERE (
        remaining_refundable_skip != 0 
        AND status = 'cancelled'
    ) OR (
        status != 'cancelled'
        AND (SELECT COUNT(*) 
        FROM refund 
        WHERE refund.subscription_id = subscription.subscription_id
            AND refund.type = 'skipped') + subscription.remaining_refundable_skip != 2
    );

-- CHK-07 (I07)
-- check the number of delivery rows is in 0, 6, 12
SELECT 
    subs.subscription_id, 
    COUNT(del.week_no) 
FROM subscription AS subs
LEFT JOIN delivery AS del
    ON subs.subscription_id = del.subscription_id
-- HAVING may only name grouped columns; these three depend on subscription_id, so the
-- groups do not change
GROUP BY subs.subscription_id, subs.cancellation_date, subs.season_id, subs.frequency
HAVING COUNT(del.week_no) != 
    CASE
        WHEN subs.cancellation_date IS NULL
        THEN CASE
            WHEN (2026, 'autumn') = (SELECT year, season_name FROM season WHERE season.season_id = subs.season_id)
            THEN 0
            ELSE CASE
                WHEN subs.frequency = 'weekly'
                THEN 12
                WHEN subs.frequency = 'biweekly'
                THEN 6 END
            END
        WHEN subs.cancellation_date BETWEEN 
            (SELECT start_date FROM season_range WHERE season_range.season_id = subs.season_id)
            AND (SELECT end_date FROM season_range WHERE season_range.season_id = subs.season_id)
        THEN CASE
            WHEN subs.frequency = 'weekly'
            THEN 12
            WHEN subs.frequency = 'biweekly'
            THEN 6 END
        ELSE 0 END;


-- CHK-08 (I08)
-- check whether the byweekly subscription has even week delivery
SELECT
    subs.subscription_id,
    del.week_no
FROM subscription AS subs
LEFT JOIN delivery AS del
    ON subs.subscription_id = del.subscription_id
    AND subs.frequency = 'biweekly'
WHERE del.week_no % 2 != 1;

-- CHK-09 (I09)
-- check the status of delivery
-- A window that opens on 2026-07-07 has had no operation yet, because the seed is the
-- state at the start of that day; only a window opened by 2026-07-06 allows 'skipped'.
SELECT 
    del.subscription_id,
    del.week_no
FROM delivery AS del
LEFT JOIN date_of_delivery AS dod ON del.subscription_id = dod.subscription_id AND del.week_no = dod.week_no
WHERE
    (dod.delivery_date <= "2026-07-05" AND status NOT IN ('success', 'failed', 'skipped', 'cancelled'))
    OR (dod.delivery_date > "2026-07-05" AND dod.start_window > "2026-07-06" AND status NOT IN ('planned', 'cancelled'))
    OR (dod.delivery_date > "2026-07-05" AND dod.start_window <= "2026-07-06" AND status NOT IN ('planned', 'skipped', 'cancelled'));

-- check 'cancelled' deliveries: a delivery is cancelled exactly when its subscription is
-- cancelled and its delivery day is after the cancellation date (a delivery skipped
-- before the cancellation stays skipped)
SELECT
    del.subscription_id,
    del.week_no,
    del.status,
    subs.cancellation_date
FROM delivery AS del
JOIN subscription AS subs ON del.subscription_id = subs.subscription_id
JOIN date_of_delivery AS dod ON del.subscription_id = dod.subscription_id AND del.week_no = dod.week_no
WHERE
    (del.status = 'cancelled'
     AND (subs.cancellation_date IS NULL OR dod.delivery_date <= subs.cancellation_date))
    OR (subs.cancellation_date IS NOT NULL
     AND dod.delivery_date > subs.cancellation_date
     AND del.status NOT IN ('cancelled', 'skipped'));


-- CHK-10 (I10)
-- check the refund dates are correct
SELECT 
    ref.refund_id,
    ref.subscription_id,
    ref.week_no
FROM refund AS ref
LEFT JOIN date_of_delivery AS dod
    ON dod.subscription_id = ref.subscription_id
   AND dod.week_no = ref.week_no
WHERE 
    (ref.type = 'skipped' 
     AND ref.refund_date NOT BETWEEN dod.start_window AND dod.end_window)
    OR
    (ref.type = 'failed' 
     AND ref.refund_date != DATE_ADD(dod.delivery_date, INTERVAL 1 DAY))
    OR
    (ref.type = 'cancelled'
     AND (ref.refund_date != (SELECT cancellation_date FROM subscription WHERE ref.subscription_id = subscription.subscription_id)
        OR ref.week_no iS NOT NULL));

-- CHK-11 (I11)
-- check the refund amount, type, and order seperately
-- amount of a skipped or failed refund (the cancelled refund amount is checked in CHK-13)
SELECT
    ref.refund_id
FROM refund AS ref
LEFT JOIN subscription AS subs ON ref.subscription_id = subs.subscription_id
LEFT JOIN (
    SELECT 
        ao.subscription_id AS subscription_id,
        ao.week_no AS week_no,
        SUM(pro.price_per_kg * ao.weight) AS add_on_price
    FROM add_on AS ao
    LEFT JOIN product AS pro ON pro.product_id = ao.product_id
    GROUP BY ao.subscription_id, week_no
) AS t ON subs.subscription_id = t.subscription_id AND ref.week_no = t.week_no
WHERE ref.type IN ('skipped', 'failed') AND ref.amount != subs.allocated_cost + COALESCE(t.add_on_price, 0);

-- type: a skipped or failed refund names a delivery with the same status (CL03)
SELECT
    ref.refund_id,
    ref.type,
    del.status
FROM refund AS ref
JOIN delivery AS del
    ON del.subscription_id = ref.subscription_id
   AND del.week_no = ref.week_no
WHERE ref.type != del.status;

-- order: a skipped delivery has a refund exactly when fewer than 2 deliveries of the same
-- subscription were skipped before it. Change windows follow week order and never
-- overlap, so week order is skip order.
SELECT
    del.subscription_id,
    del.week_no,
    ref.refund_id
FROM delivery AS del
LEFT JOIN refund AS ref
    ON ref.subscription_id = del.subscription_id
   AND ref.week_no = del.week_no
WHERE del.status = 'skipped'
  AND (ref.refund_id IS NOT NULL) != (
        (SELECT COUNT(*)
         FROM delivery AS earlier
         WHERE earlier.subscription_id = del.subscription_id
           AND earlier.status = 'skipped'
           AND earlier.week_no < del.week_no) < 2);

-- CHK-12 (I12)
-- every failed delivery has its failed refund (its amount is checked in CHK-11)
SELECT
    del.subscription_id,
    del.week_no
FROM delivery AS del
LEFT JOIN refund AS ref
    ON ref.subscription_id = del.subscription_id
   AND ref.week_no = del.week_no
WHERE del.status = 'failed' AND ref.refund_id IS NULL;

-- CHK-13 (I13)
-- amount of the cancellation refund of every cancelled subscription. A zero refund has
-- no row (D20), so a missing row is compared as 0.
-- Case A (cancelled before the range): the whole fee.
-- Case B: min(refundable skips left, deliveries cancelled) x allocated cost + add-on fees
-- on those deliveries. No skip can happen after a cancellation, so the skips left at
-- the cancellation are 2 minus the skip refunds, and the deliveries the cancellation
-- changed are exactly the 'cancelled' ones.
SELECT
    e.subscription_id,
    e.expected_amount,
    COALESCE(a.actual_amount, 0) AS actual_amount
FROM (
    SELECT
        subs.subscription_id,
        CASE 
            WHEN subs.cancellation_date < (SELECT start_date FROM season_range WHERE season_range.season_id = subs.season_id)
            THEN subs.allocated_cost * IF(subs.frequency = 'weekly', 12, 6)
            ELSE LEAST(2 - (SELECT COUNT(*)
                            FROM refund
                            WHERE refund.subscription_id = subs.subscription_id
                              AND refund.type = 'skipped'),
                       (SELECT COUNT(*)
                        FROM delivery AS del
                        WHERE del.subscription_id = subs.subscription_id
                          AND del.status = 'cancelled')) * subs.allocated_cost
                + (SELECT COALESCE(SUM(pro.price_per_kg * ao.weight), 0)
                   FROM add_on AS ao
                   JOIN delivery AS del
                       ON del.subscription_id = ao.subscription_id
                      AND del.week_no = ao.week_no
                   JOIN product AS pro ON pro.product_id = ao.product_id
                   WHERE ao.subscription_id = subs.subscription_id
                     AND del.status = 'cancelled')
        END AS expected_amount
    FROM subscription AS subs
    WHERE subs.status = 'cancelled'
) AS e
LEFT JOIN (
    SELECT subscription_id, SUM(amount) AS actual_amount
    FROM refund
    WHERE type = 'cancelled'
    GROUP BY subscription_id
) AS a ON a.subscription_id = e.subscription_id
WHERE e.expected_amount != COALESCE(a.actual_amount, 0);

-- at most one cancellation refund per subscription, and only for a cancelled one
SELECT
    ref.subscription_id,
    subs.status,
    COUNT(*) AS cancellation_refunds
FROM refund AS ref
JOIN subscription AS subs ON subs.subscription_id = ref.subscription_id
WHERE ref.type = 'cancelled'
GROUP BY ref.subscription_id, subs.status
HAVING COUNT(*) > 1 OR subs.status != 'cancelled';

-- CHK-14 (I14)
-- an add-on is a product of the plan: one of the season's 6 farmer's choice types, or one
-- of the 8 chosen types; its delivery's change window opened before the baseline (D27:
-- the purchase date itself is not stored)
SELECT
    ao.subscription_id,
    ao.week_no,
    ao.product_id
FROM add_on AS ao
JOIN subscription AS subs ON subs.subscription_id = ao.subscription_id
JOIN product AS pro ON pro.product_id = ao.product_id
JOIN date_of_delivery AS dod
    ON dod.subscription_id = ao.subscription_id
   AND dod.week_no = ao.week_no
WHERE pro.season_id != subs.season_id
   OR (subs.plan_type = 'farmer''s choice' AND pro.is_farmers_choice != 1)
   OR (subs.plan_type = 'customizable' AND NOT EXISTS (
           SELECT 1
           FROM chosen_products AS cp
           WHERE cp.subscription_id = ao.subscription_id
             AND cp.product_id = ao.product_id))
   OR dod.start_window > "2026-07-06";

-- CHK-15 (I15)
-- a customizable subscription chooses exactly 8 products of its own season; a farmer's
-- choice subscription chooses none
SELECT
    subs.subscription_id,
    subs.plan_type,
    COUNT(cp.product_id) AS chosen,
    COALESCE(SUM(pro.season_id != subs.season_id), 0) AS from_other_season
FROM subscription AS subs
LEFT JOIN chosen_products AS cp ON cp.subscription_id = subs.subscription_id
LEFT JOIN product AS pro ON pro.product_id = cp.product_id
GROUP BY subs.subscription_id
HAVING COUNT(cp.product_id) != IF(subs.plan_type = 'customizable', 8, 0)
    OR COALESCE(SUM(pro.season_id != subs.season_id), 0) > 0;


-- Mutation test, MySQL 8.4.11, 2026-11-12. On fresh seed data every check above returns
-- 0 rows. Each change below was applied alone to fresh seed data, and the named checks
-- then returned rows, so every check can detect a broken row.
--
--   Change                                                       Checks that returned rows
--   product 16: is_farmers_choice = 0                            CHK-01, CHK-14
--   subscription 201: submission_date = '2026-02-24'             CHK-02
--   subscription 303: allocated_cost = 160.00                    CHK-03
--   subscription 301: status = 'finished'                        CHK-04
--   subscription 307: cancellation_date = '2026-07-08'           CHK-05, CHK-09, CHK-10
--   subscription 201: remaining_refundable_skip = 2              CHK-06
--   delete delivery (209, 11)                                    CHK-07
--   insert delivery (209, 12, 'success')                         CHK-07, CHK-08
--   delivery (201, 1): status = 'planned'                        CHK-09
--   delivery (306, 3): status = 'cancelled'                      CHK-09 (cancelled check)
--   delivery (303, 7): status = 'skipped'                        CHK-09, CHK-11 (order)
--   refund 10: refund_date = '2026-04-27'                        CHK-10
--   refund 9: amount = 200.00                                    CHK-11 (amount)
--   refund 4: type = 'failed'                                    CHK-06, CHK-10, CHK-11 (type)
--   delete refund 14, and 302 remaining_refundable_skip = 1      CHK-11 (order)
--   delete refund 3                                              CHK-12
--   refund 2: amount = 400.00                                    CHK-13
--   delete refund 13                                             CHK-13
--   insert a 'cancelled' refund for subscription 301             CHK-13 (one per cancelled)
--   add_on (207, 2): product_id = 13                             CHK-14
--   add_on (301, 6): product_id = 11                             CHK-14
--   delete chosen_products (210, 11)                             CHK-15
--   insert chosen_products (201, 11)                             CHK-15
