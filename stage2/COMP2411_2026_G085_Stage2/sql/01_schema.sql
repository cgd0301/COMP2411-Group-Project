-- File:          sql/01_schema.sql
-- Purpose:       Set up the schema of each table in the database system
-- Related IDs:   BR1-BR11
-- Prerequisites: An empty database is already selected. This script does not
--                create or select a database, and it is safe to run again:
--                it drops the tables first, children before parents.

SET sql_notes = 0;
DROP TABLE IF EXISTS add_on;
DROP TABLE IF EXISTS refund;
DROP TABLE IF EXISTS chosen_products;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS season;
SET sql_notes = 1;


CREATE TABLE customer (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    building VARCHAR(50) NOT NULL,
    room VARCHAR(20) NOT NULL,

    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE TABLE season (
    season_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    season_name VARCHAR(10) NOT NULL COLLATE utf8mb4_bin,
    year SMALLINT UNSIGNED NOT NULL,
    first_planning_day DATE NOT NULL,

    CONSTRAINT uq_season_name_year UNIQUE (season_name, year),
    CONSTRAINT uq_season_first_planning_day UNIQUE (first_planning_day),
    CONSTRAINT ck_season_season_name CHECK (season_name IN ('spring', 'summer', 'autumn')),
    -- DAYOFWEEK() numbers Sunday as 1, so Monday is 2.
    CONSTRAINT ck_season_planning_day_monday CHECK (DAYOFWEEK(first_planning_day) = 2),
    CONSTRAINT ck_season_year CHECK (YEAR(first_planning_day) = year)
);

CREATE TABLE subscription (
    subscription_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    season_id SMALLINT UNSIGNED NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'planned' COLLATE utf8mb4_bin,
    plan_type VARCHAR(20) NOT NULL COLLATE utf8mb4_bin,
    frequency VARCHAR(10) NOT NULL COLLATE utf8mb4_bin,
    allocated_cost DECIMAL(8,2) NOT NULL,
    submission_date DATE NOT NULL,
    cancellation_date DATE NULL DEFAULT NULL,
    remaining_refundable_skip TINYINT NOT NULL DEFAULT 2,

    CONSTRAINT fk_subscription_customer 
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_subscription_season
        FOREIGN KEY (season_id) REFERENCES season(season_id),
    CONSTRAINT uq_subscription_customer_season
        UNIQUE (customer_id, season_id),
    CONSTRAINT ck_subscription_status
        CHECK (status IN ('planned', 'active', 'finished', 'cancelled')),
    CONSTRAINT ck_subscription_plan_type
        CHECK (plan_type IN ('farmer''s choice', 'customizable')),
    CONSTRAINT ck_subscription_frequency
        CHECK (frequency IN ('weekly', 'biweekly')),
    -- 160 and 192 are the renewal prices. Whether the customer actually
    -- renewed is checked by the enrolment statement (BR4), not here.
    CONSTRAINT ck_subscription_allocated_cost 
        CHECK ((plan_type = 'farmer''s choice' AND allocated_cost IN (200.00, 160.00))
            OR (plan_type = 'customizable' AND allocated_cost IN (240, 192))),
    CONSTRAINT ck_subscription_remaining_skip
        CHECK (remaining_refundable_skip BETWEEN 0 AND 2),
    CONSTRAINT ck_subscription_cancellation
        CHECK ((status = 'cancelled' AND cancellation_date IS NOT NULL) OR (status <> 'cancelled' AND cancellation_date IS NULL)),
    CONSTRAINT ck_subscription_cancellation_date
        CHECK (cancellation_date IS NULL OR cancellation_date >= submission_date)
);

CREATE TABLE product (
    product_id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
    season_id SMALLINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_farmers_choice BOOLEAN NOT NULL DEFAULT FALSE,
    price_per_kg DECIMAL(6,2) NOT NULL,

    CONSTRAINT fk_product_season
        FOREIGN KEY (season_id) REFERENCES season(season_id),
    CONSTRAINT uq_product_season_name
        UNIQUE (season_id, name),
    CONSTRAINT ck_product_price_per_kg
        CHECK (price_per_kg >= 0),
    CONSTRAINT ck_product_is_farmers_choice CHECK (is_farmers_choice IN (0, 1))
);

CREATE TABLE delivery (
    subscription_id INT UNSIGNED NOT NULL,
    week_no TINYINT NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'planned' COLLATE utf8mb4_bin,

    PRIMARY KEY (subscription_id, week_no),
    CONSTRAINT fk_delivery_subscription
        FOREIGN KEY (subscription_id) REFERENCES subscription(subscription_id),
    CONSTRAINT ck_delivery_week_no
        CHECK (week_no BETWEEN 1 AND 12),
    CONSTRAINT ck_delivery_status
        CHECK (status IN ('planned', 'skipped', 'success', 'failed', 'cancelled'))
        
);

-- Exactly 8 types, all from the subscription's own season, is checked
-- in the enrolment transaction (BR6), not by a constraint on this table.
CREATE TABLE chosen_products (
    subscription_id INT UNSIGNED,
    product_id INT UNSIGNED,

    PRIMARY KEY (subscription_id, product_id),
    CONSTRAINT fk_chosen_products_subscription
        FOREIGN KEY (subscription_id) REFERENCES subscription(subscription_id),
    CONSTRAINT fk_chosen_products_product
        FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE refund (
    refund_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT UNSIGNED NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    type VARCHAR(12) NOT NULL COLLATE utf8mb4_bin,
    refund_date DATE NOT NULL,
    week_no TINYINT NULL DEFAULT NULL,

    CONSTRAINT fk_refund_subscription
        FOREIGN KEY (subscription_id) REFERENCES subscription(subscription_id),
    -- No ON DELETE clause: week_no is also used in ck_refund_type, and MySQL
    -- rejects a referential action on a column used in a CHECK. A NULL week_no
    -- is not checked by this foreign key, so a cancellation refund names no delivery.
    -- UNIQUE allows several NULL week_no values, so a second cancellation refund
    -- is stopped by the cancellation transaction (BR10), not by this key.
    CONSTRAINT fk_refund_delivery
        FOREIGN KEY (subscription_id, week_no) REFERENCES delivery(subscription_id, week_no),
    CONSTRAINT uq_refund_subscription_week_no
        UNIQUE (subscription_id, week_no),
    CONSTRAINT ck_refund_amount
        CHECK (amount > 0),
    CONSTRAINT ck_refund_type
        CHECK ((type IN ('skipped', 'failed') AND week_no IS NOT NULL)
            OR (type = 'cancelled' AND week_no IS NULL)) 
);

CREATE TABLE add_on (
    subscription_id INT UNSIGNED NOT NULL,
    week_no TINYINT NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    weight DECIMAL(5,2) NOT NULL,

    PRIMARY KEY (subscription_id, week_no, product_id),
    CONSTRAINT ck_add_on_weight CHECK (weight >= 0.10),
    CONSTRAINT fk_add_on_delivery
        FOREIGN KEY (subscription_id, week_no) REFERENCES delivery(subscription_id, week_no),
    CONSTRAINT fk_add_on_product
        FOREIGN KEY (product_id) REFERENCES product(product_id)
);
