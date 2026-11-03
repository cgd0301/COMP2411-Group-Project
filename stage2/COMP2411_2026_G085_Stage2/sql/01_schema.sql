-- File:          comp2411-project/stage2/
--                COMP2411_2026_G085_Stage2/sql/01_schema.sql
-- Purpose:       Set up the schema of each table in the database system
-- Related IDs:   BR1-BR11
-- Prerequisites: An empty database is already selected. This script does not
--                create or select a database, and it is safe to run again:
--                it drops the tables first, children before parents.

DROP TABLE IF EXISTS add_on;
DROP TABLE IF EXISTS refund;
DROP TABLE IF EXISTS chosen_products;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS season;

CREATE TABLE IF NOT EXISTS customer (
    customer_id   INT UNSIGNED PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    building VARCHAR(50) NOT NULL,
    room VARCHAR(25) NOT NULL,

    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS season (
    season_id SMALLINT UNSIGNED PRIMARY KEY,
    season_name VARCHAR(10) NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    first_planning_day DATE NOT NULL,

    CONSTRAINT uq_season_name_year UNIQUE (season_name, year),
    CONSTRAINT uq_season_first_planning_day UNIQUE (first_planning_day),
    CONSTRAINT ck_season_season_name CHECK (season_name IN ('spring', 'summer', 'autumn')),
    CONSTRAINT ck_season_planning_day_monday CHECK (DAYOFWEEK(first_planning_day) = 2)
);

CREATE TABLE IF NOT EXISTS subscription (
    subscription_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    season_id SMALLINT UNSIGNED NOT NULL,
    status VARCHAR(10) NOT NULL,
    plan_type VARCHAR(20) NOT NULL,
    frequency VARCHAR(20) NOT NULL,
    allocated_cost DECIMAL(8,2) NOT NULL,
    submission_date DATE NOT NULL,
    cancellation_date DATE NULL DEFAULT NULL,
    remaining_refundable_skip TINYINT NOT NULL DEFAULT 2,

    CONSTRAINT fk_subscription_customer 
        FOREIGN KEY (customer_id) REFERENCES customer.customer_id,
    CONSTRAINT fk_subscription_season
        FOREIGN KEY (season_id) REFERENCES season.season_id,
    CONSTRAINT uq_subscription_customer_season
        UNIQUE (customer_id, season_id),
    CONSTRAINT ck_subscription_status
        CHECK (status IN ('planned', 'active', 'finished', 'cancelled')),
    CONSTRAINT ck_subscription_plan_type
        CHECK (plan_type IN ('farmer''s choice', 'customizable')),
    CONSTRAINT ck_subscription_frequency
        CHECK (frequency IN ('weekly', 'biweekly')),
    CONSTRAINT ck_subscription_allocated_cost 
        CHECK ((plan_type = 'farmer''s choice' AND allocated_cost IN (200.00, 160.00))
            OR (plan_type = 'customizable' AND allocated_cost IN (240, 192))),
    CONSTRAINT ck_subscription_remaining_skip
        CHECK (remaining_refundable_skip BETWEEN 0 AND 2)
);

CREATE TABLE IF NOT EXISTS product (
    product_id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
    season_id SMALLINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_farmers_choic BOOLEAN NOT NULL DEFAULT FALSE,
    price_per_kg DECIMAL(6,2) NOT NULL,

    CONSTRAINT fk_product_season
        FOREIGN KEY (season_id) REFERENCES season.season_id,
    CONSTRAINT uq_product_season_name
        UNIQUE (season_id, name),
    CONSTRAINT ck_product_price_per_kg
        CHECK (price_per_kg > 0)
);

CREATE TABLE IF NOT EXISTS delivery (
    subscription_id INT UNSIGNED NOT NULL,
    week_no TINYINT NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'planned',

    CONSTRAINT fk_delivery_subscription
        FOREIGN KEY (subscription_id) REFERENCES subscription.subscription_id,
    CONSTRAINT ck_delivery_week_no
        CHECK (week_no BETWEEN 0 AND 12),
    CONSTRAINT ck_delivery_status
        
);

