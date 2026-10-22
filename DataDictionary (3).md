# Data Dictionary — G7 / D17-W04 (Farmlander Farm CSA)

Conventions: money -> DECIMAL (never FLOAT); dates -> DATE, timestamps -> DATETIME;
status/type columns -> VARCHAR + CHECK (ANSI-standard, easier to extend than ENUM);
every FK column has exactly the same type and signedness as the referenced PK.
All foreign keys are declared ON DELETE RESTRICT (child rows must be removed first).
Derived attributes from the ER diagram (marked with ()) are NOT stored: subscription.fee(),
delivery.delivery_date(), delivery.add_on_fee(), delivery.price(); they are computed in SQL/application code.

## 1. customer
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| customer_id | INT UNSIGNED AUTO_INCREMENT | PK | NO | — | — | Surrogate identifier |
| name | VARCHAR(100) | — | NO | — | — | Full name |
| email | VARCHAR(255) | UNIQUE (CK1) | NO | — | — | Login/contact; candidate key |
| street | VARCHAR(255) | — | NO | — | — | Address part 1 (composite attr) |
| building | VARCHAR(50) | — | NO | — | — | Address part 2 |
| room | VARCHAR(20) | — | NO | — | — | Address part 3 |

## 2. season
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| season_id | SMALLINT UNSIGNED AUTO_INCREMENT | PK | NO | — | — | Surrogate identifier |
| season_name | VARCHAR(10) | part of CK1 | NO | — | IN ('spring','summer','autumn') | Season within a year |
| year | SMALLINT UNSIGNED | part of CK1 | NO | — | — | Calendar year |
| first_planning_day | DATE | UNIQUE (CK2) | NO | — | — | Anchor date; start_day() = +6, end_day() = +84 (derived, not stored) |

## 3. subscription
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| subscription_id | INT UNSIGNED AUTO_INCREMENT | PK | NO | — | — | Surrogate identifier |
| customer_id | INT UNSIGNED | FK→customer; part of CK | NO | — | UNIQUE(customer_id, season_id) | Holder (BR1: at most 1 per customer per season; cancelled still occupies the slot) |
| season_id | SMALLINT UNSIGNED | FK→season; part of CK | NO | — | — | Season subscribed |
| status | VARCHAR(10) | — | NO | 'PENDING' | CHECK IN ('PENDING','ACTIVE','FINISHED','CANCELLED') | Lifecycle state |
| plan_type | VARCHAR(20) | — | NO | — | CHECK IN ('farmer''s choice','customizable') | Chosen at enrolment, immutable afterwards |
| frequency | VARCHAR(10) | — | NO | — | CHECK IN ('weekly','biweekly') | Chosen at enrolment, immutable afterwards |
| allocated_cost | DECIMAL(8,2) | — | NO | — | CHECK (>= 0) | Single-delivery price snapshot incl. 20% renewal discount (stored to lock price) |
| submission_date | DATE | — | NO | — | — | Enrolment/renewal date |
| cancellation_date | DATE | — | YES | NULL | — | NULL = not cancelled (legitimate missing value) |
| remaining_refundable_skip | TINYINT UNSIGNED | — | NO | 2 | CHECK (<= 2) | Refundable skip quota, consumed by skip refunds |

**Derived (not stored):** fee() = delivery count x allocated_cost; see Conventions above.

## 4. delivery (weak entity)
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| subscription_id | INT UNSIGNED | PK part 1; FK→subscription | NO | — | — | Owner entity PK (identifying relationship) |
| week_no | TINYINT UNSIGNED | PK part 2 (partial key) | NO | — | CHECK (BETWEEN 1 AND 12) | Week within the season |
| status | VARCHAR(10) | — | NO | 'planned' | CHECK IN ('planned','skipped','success','failed','cancelled') | Delivery state machine; transitions guarded by UPDATE in transactions |
| refund_id | INT UNSIGNED | FK→refund; UNIQUE | YES | NULL | — | 1:1 compensate (partial both sides); NULL = no refund for this delivery. Same-subscription rule is cross-table -> in-transaction check |

**Derived (not stored):** delivery_date() = season start + (week_no-1) x 7 (x14 for biweekly); add_on_fee() = SUM(weight x price_per_kg); price() is computed on the fly. See Conventions above.

**ER cardinality (refunded via):** a subscription has **at most 12 refunds** (0..12 on the ER diagram); this is a cross-row rule and cannot be a CHECK -> in-transaction check.

## 5. refund
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| refund_id | INT UNSIGNED AUTO_INCREMENT | PK | NO | — | — | Surrogate identifier |
| subscription_id | INT UNSIGNED | FK→subscription | NO | — | — | The subscription refunded |
| amount | DECIMAL(8,2) | — | NO | — | CHECK (> 0) | Computed at discounted allocated cost (anti-arbitrage) |
| type | VARCHAR(12) | — | NO | — | CHECK IN ('skip','failed','cancellation') | 'skip' consumes quota; 'failed' does not; 'cancellation' ties to no delivery |
| refund_date | DATETIME | — | NO | — | — | When the refund was issued |

## 6. product
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| product_id | INT UNSIGNED AUTO_INCREMENT | PK | NO | — | — | Surrogate identifier |
| season_id | SMALLINT UNSIGNED | FK→season | NO | — | — | The season it is grown in (exactly 10 products per season; cross-row rule -> in-transaction check) |
| name | VARCHAR(100) | — | NO | — | — | Product name |
| is_farmers_choice | TINYINT(1) | — | NO | 0 | — | 1 = one of the 6 fixed farmer's-choice items |
| price_per_kg | DECIMAL(6,2) | — | NO | — | CHECK (>= 0) | Unit price for add-on charging |

## 7. chosen_products (M:N junction)
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| subscription_id | INT UNSIGNED | PK part 1; FK→subscription | NO | — | — | Customizable plan's picks |
| product_id | INT UNSIGNED | PK part 2; FK→product | NO | — | — | Picked product (must be grown in the same season; cross-table -> in-transaction check) |

Note: "0..8 picks" is a cross-row rule and cannot be a CHECK; enforced by in-transaction COUNT(*) check.

## 8. add_on (M:N junction with relationship attribute)
| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| subscription_id | INT UNSIGNED | PK part 1; composite FK→delivery | NO | — | — | Delivery the add-on belongs to |
| week_no | TINYINT UNSIGNED | PK part 2; composite FK→delivery | NO | — | — | Same window as refundable skip |
| product_id | INT UNSIGNED | PK part 3; FK→product | NO | — | — | Product added (limited to the plan's types) |
| weight | DECIMAL(5,2) | — | NO | — | CHECK (>= 0.10) | Relationship attribute from ER diagram; fee = SUM(weight x price_per_kg) |

Note: (subscription_id, week_no) together form ONE composite foreign key referencing delivery(subscription_id, week_no).
