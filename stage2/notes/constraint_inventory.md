# Constraint Inventory

This file lists every constraint that goes into `sql/01_schema.sql`. The sources are the Key and Constraint columns of `DataDictionary.md` and the parts of each Enforcement field in `businessRules.md` labelled "DB constraint". Rules enforced by an SQL check or recorded as a limitation are not listed here. This is an internal working file: do not put it in the submission ZIP.

The inventory has three uses:

- **Schema:** `sql/01_schema.sql` is written from this table. A constraint that is not in the table does not go into the DDL, and every constraint in the DDL must be in the table.
- **Negative tests (Phase 7):** each violation example is a candidate for one `tests/negative/Nxx.sql` file.
- **Traceability matrix:** the matrix takes its constraint names from this table.

## Conventions

- Constraint names follow D09: `ck_<table>_<meaning>`, `uq_<table>_<columns>` and `fk_<child>_<parent>`. In UNIQUE names, foreign-key columns drop their `_id` suffix (for example `uq_subscription_customer_season`). Primary keys are not named, because MySQL always names them `PRIMARY`.
- Table and column names match the data dictionary exactly (D08). A single quote inside a string literal is written as two single quotes, for example `'farmer''s choice'` (D19).
- Each violation example uses a value that triggers the intended error. For CHECK constraints it triggers 3819, not the out-of-range error 1264 (D18). Examples marked "to be probed" must be confirmed in the schema probe.
- Case variants such as `'PLANNED'` pass the CHECK constraints under the default collation, so they are not used as violation examples (D17, see Pending candidates).
- Expected error codes: 1048 = NULL in a NOT NULL column; 1062 = duplicate key (PRIMARY KEY or UNIQUE); 1452 = foreign key without a parent row; 3819 = CHECK constraint violated.
- The Actual error column is filled in during the schema probe (§1.6).
- The table lists NOT NULL only where an Enforcement field names it explicitly. Every other NOT NULL and DEFAULT follows the data dictionary. Primary-key columns are NOT NULL automatically.

## Constraints

Rows are grouped by table in creation order: customer, season, product, subscription, chosen_products, delivery, add_on, refund.

| Constraint name | Table | Type | Columns or expression | BR | Violation example | Expected error | Actual error |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `PRIMARY` | customer | PRIMARY KEY | `(customer_id)` | — (surrogate key) | Insert a row with an existing `customer_id` | 1062 | (fill in §1.6) |
| `uq_customer_email` | customer | UNIQUE | `(email)` | BR1 | Two customers with the same email | 1062 | (fill in §1.6) |
| `PRIMARY` | season | PRIMARY KEY | `(season_id)` | — (surrogate key) | Insert a row with an existing `season_id` | 1062 | (fill in §1.6) |
| `uq_season_name_year` | season | UNIQUE | `(season_name, year)` | BR3 | A second `('summer', 2026)` row with a different Monday as `first_planning_day` | 1062 | (fill in §1.6) |
| `uq_season_first_planning_day` | season | UNIQUE | `(first_planning_day)` | BR3 | A second season with `first_planning_day = '2026-06-01'` | 1062 | (fill in §1.6) |
| `ck_season_season_name` | season | CHECK | `season_name IN ('spring', 'summer', 'autumn')` | BR3 | `season_name = 'winter'` | 3819 | (fill in §1.6) |
| `ck_season_planning_day_monday` | season | CHECK | `DAYOFWEEK(first_planning_day) = 2` | BR3 | `('spring', 2027, '2027-03-02')`, where 2027-03-02 is a Tuesday | 3819 | (fill in §1.6) |
| `PRIMARY` | product | PRIMARY KEY | `(product_id)` | — (surrogate key) | Insert a row with an existing `product_id` | 1062 | (fill in §1.6) |
| `fk_product_season` | product | FOREIGN KEY | `(season_id)` references `season(season_id)` ON DELETE RESTRICT | BR6 | `season_id = 9999` (no such season) | 1452 | (fill in §1.6) |
| Column NOT NULL (unnamed) | product | NOT NULL | `season_id` | BR6 | `season_id = NULL` | 1048 | (fill in §1.6) |
| `uq_product_season_name` | product | UNIQUE | `(season_id, name)` | BR6 (data dictionary only) | A second product with the same name in the same season | 1062 | (fill in §1.6) |
| `ck_product_price_per_kg` | product | CHECK | `price_per_kg >= 0` | BR9 (data dictionary only) | `price_per_kg = -1.00` | 3819 | (fill in §1.6) |
| `PRIMARY` | subscription | PRIMARY KEY | `(subscription_id)` | — (surrogate key) | Insert a row with an existing `subscription_id` | 1062 | (fill in §1.6) |
| `fk_subscription_customer` | subscription | FOREIGN KEY | `(customer_id)` references `customer(customer_id)` ON DELETE RESTRICT | BR1 | `customer_id = 9999` (no such customer) | 1452 | (fill in §1.6) |
| `fk_subscription_season` | subscription | FOREIGN KEY | `(season_id)` references `season(season_id)` ON DELETE RESTRICT | BR1 | `season_id = 9999` (no such season) | 1452 | (fill in §1.6) |
| Column NOT NULL (unnamed) | subscription | NOT NULL | `customer_id` | BR1 | `customer_id = NULL` | 1048 | (fill in §1.6) |
| Column NOT NULL (unnamed) | subscription | NOT NULL | `season_id` | BR1 | `season_id = NULL` | 1048 | (fill in §1.6) |
| `uq_subscription_customer_season` | subscription | UNIQUE | `(customer_id, season_id)` | BR2 | A second subscription for the same customer and season, even if the first one is cancelled | 1062 | (fill in §1.6) |
| `ck_subscription_status` | subscription | CHECK | `status IN ('planned', 'active', 'finished', 'cancelled')` | BR3 | `status = 'paused'` | 3819 | (fill in §1.6) |
| `ck_subscription_plan_type` | subscription | CHECK | `plan_type IN ('farmer''s choice', 'customizable')` | BR5 | `plan_type = 'premium'` | 3819 | (fill in §1.6) |
| `ck_subscription_frequency` | subscription | CHECK | `frequency IN ('weekly', 'biweekly')` | BR5 | `frequency = 'monthly'` | 3819 | (fill in §1.6) |
| `ck_subscription_allocated_cost` | subscription | CHECK | `(plan_type = 'farmer''s choice' AND allocated_cost IN (200.00, 160.00)) OR (plan_type = 'customizable' AND allocated_cost IN (240.00, 192.00))` | BR4, BR5 | A farmer's choice subscription with `allocated_cost = 240.00`; any plan with `allocated_cost = 180.00` | 3819 | (fill in §1.6) |
| `ck_subscription_remaining_skip` | subscription | CHECK | `remaining_refundable_skip BETWEEN 0 AND 2` | BR8 | `remaining_refundable_skip = 3`; lowering 0 by 1 to -1 (signed TINYINT, to be probed) | 3819 | (fill in §1.6) |
| `PRIMARY` | chosen_products | PRIMARY KEY | `(subscription_id, product_id)` | BR6 | The same subscription chooses the same product twice | 1062 | (fill in §1.6) |
| `fk_chosen_products_subscription` | chosen_products | FOREIGN KEY | `(subscription_id)` references `subscription(subscription_id)` ON DELETE RESTRICT | BR6 | `subscription_id = 9999` (no such subscription) | 1452 | (fill in §1.6) |
| `fk_chosen_products_product` | chosen_products | FOREIGN KEY | `(product_id)` references `product(product_id)` ON DELETE RESTRICT | BR6 | `product_id = 9999` (no such product) | 1452 | (fill in §1.6) |
| `PRIMARY` | delivery | PRIMARY KEY | `(subscription_id, week_no)` | BR7 | A second delivery for the same subscription and `week_no` | 1062 | (fill in §1.6) |
| `fk_delivery_subscription` | delivery | FOREIGN KEY | `(subscription_id)` references `subscription(subscription_id)` ON DELETE RESTRICT | BR7 | `subscription_id = 9999` (no such subscription) | 1452 | (fill in §1.6) |
| `ck_delivery_week_no` | delivery | CHECK | `week_no BETWEEN 1 AND 12` | BR7 | `week_no = 13`. `0` also gives 3819; `-1` gives 1264 and is not used (D18, to be probed) | 3819 | (fill in §1.6) |
| `ck_delivery_status` | delivery | CHECK | `status IN ('planned', 'skipped', 'success', 'failed', 'cancelled')` | BR7 | `status = 'delivered'` | 3819 | (fill in §1.6) |
| `PRIMARY` | add_on | PRIMARY KEY | `(subscription_id, week_no, product_id)` | BR9 | A second line for the same product on the same delivery | 1062 | (fill in §1.6) |
| `fk_add_on_delivery` | add_on | FOREIGN KEY (composite) | `(subscription_id, week_no)` references `delivery(subscription_id, week_no)` ON DELETE RESTRICT | BR9 | `week_no = 2` for a biweekly subscription, which has no week-2 delivery | 1452 | (fill in §1.6) |
| `fk_add_on_product` | add_on | FOREIGN KEY | `(product_id)` references `product(product_id)` ON DELETE RESTRICT | BR9 | `product_id = 9999` (no such product) | 1452 | (fill in §1.6) |
| `ck_add_on_weight` | add_on | CHECK | `weight >= 0.10` | BR9 | `weight = 0.05` | 3819 | (fill in §1.6) |
| `PRIMARY` | refund | PRIMARY KEY | `(refund_id)` | — (surrogate key) | Insert a row with an existing `refund_id` | 1062 | (fill in §1.6) |
| `fk_refund_subscription` | refund | FOREIGN KEY | `(subscription_id)` references `subscription(subscription_id)` ON DELETE RESTRICT | BR11 | `subscription_id = 9999` (no such subscription) | 1452 | (fill in §1.6) |
| `fk_refund_delivery` | refund | FOREIGN KEY (composite) | `(subscription_id, week_no)` references `delivery(subscription_id, week_no)`, with no ON DELETE clause (D16; the InnoDB default is RESTRICT) | BR11 | A skip refund with `week_no = 5` for a subscription that has no week-5 delivery | 1452 | (fill in §1.6) |
| Column NOT NULL (unnamed) | refund | NOT NULL | `subscription_id` | BR11 | `subscription_id = NULL` | 1048 | (fill in §1.6) |
| `uq_refund_subscription_week_no` | refund | UNIQUE | `(subscription_id, week_no)` | BR11 | A second refund for the same delivery | 1062 | (fill in §1.6) |
| `ck_refund_amount` | refund | CHECK | `amount > 0` | BR11 (data dictionary only) | `amount = 0.00` | 3819 | (fill in §1.6) |
| `ck_refund_type` | refund | CHECK | `type IN ('skip', 'failed', 'cancellation')` | BR11 | `type = 'bonus'` | 3819 | (fill in §1.6) |
| `ck_refund_link` | refund | CHECK | `(type IN ('skip', 'failed') AND week_no IS NOT NULL) OR (type = 'cancellation' AND week_no IS NULL)` | BR11 | `type = 'skip'` with `week_no = NULL`; `type = 'cancellation'` with `week_no = 3` | 3819 | (fill in §1.6) |

## Count check

| Type | Count | Breakdown |
| --- | --- | --- |
| PRIMARY KEY | 8 | One per table; 3 are composite (chosen_products, delivery, add_on) |
| FOREIGN KEY | 10 | Checked one by one below; 2 are composite |
| UNIQUE | 6 | customer 1, season 2, product 1, subscription 1, refund 1 |
| CHECK | 14 | season 2, product 1, subscription 5, delivery 2, add_on 1, refund 3 |
| NOT NULL (named in an Enforcement field) | 4 | subscription 2, product 1, refund 1 |
| Total | 42 | 30 of them are named constraints (FOREIGN KEY, UNIQUE and CHECK) |

Foreign keys checked against the ER mapping:

| # | Relationship | Constraint name | Check |
| --- | --- | --- | --- |
| 1 | product → season | `fk_product_season` | ✅ |
| 2 | subscription → customer | `fk_subscription_customer` | ✅ |
| 3 | subscription → season | `fk_subscription_season` | ✅ |
| 4 | chosen_products → subscription | `fk_chosen_products_subscription` | ✅ |
| 5 | chosen_products → product | `fk_chosen_products_product` | ✅ |
| 6 | delivery → subscription | `fk_delivery_subscription` | ✅ |
| 7 | add_on → delivery (composite) | `fk_add_on_delivery` | ✅ |
| 8 | add_on → product | `fk_add_on_product` | ✅ |
| 9 | refund → subscription | `fk_refund_subscription` | ✅ |
| 10 | refund → delivery (composite) | `fk_refund_delivery` | ✅ |

Result: 10 of 10, so no relationship was missed in the ER mapping. `add_on` has no separate foreign key to `subscription`: it belongs to a subscription through `fk_add_on_delivery`.

CHECK and FOREIGN KEY names must be unique within the whole database. The table prefix in each name guarantees this (D09), and the 30 named constraints above are all distinct.

## Differences and notes

- **`allocated_cost` (resolved, CL02):** The data dictionary gave only `CHECK IN (160, 192, 200, 240)`, which was weaker than the BR5 Enforcement field. BR5 requires the cost to match the plan, and its test case (a farmer's choice subscription with a cost of 240 is rejected) passes only with that version. This inventory uses the BR5 version, `ck_subscription_allocated_cost`; `DataDictionary.md` has been updated to match.
- **`ck_refund_amount` (`amount > 0`, resolved, D20):** Some refunds work out to 0. Under BR8, a skip when no refundable skip remains refunds nothing. Under BR10, cancelling an active subscription can give 0, for example when no refundable skip remains and no add-on fee applies. In these cases the operation inserts no refund row, so this CHECK is never hit by a valid operation.
- **NULL in UNIQUE and FOREIGN KEY:** `uq_refund_subscription_week_no` allows several rows with `week_no IS NULL`, so it does not limit a subscription to one cancellation refund. That limit comes from the BR10 transaction: its UPDATE matches only a planned or active subscription, and the subscription is cancelled afterwards. Likewise, `fk_refund_delivery` is not checked when `week_no IS NULL`. This is intended, because a cancellation refund is for no delivery.
- **D16 (Agreed):** `fk_refund_delivery` has no ON DELETE clause. Also, `delivery.week_no` is a referenced column and is used in `ck_delivery_week_no`, so the probe must confirm that `fk_add_on_delivery` with `ON DELETE RESTRICT` raises no error.
- **Primary-key columns:** The foreign-key columns of `delivery`, `chosen_products` and `add_on` are part of each table's primary key, so they are NOT NULL automatically and have no NOT NULL rows of their own. In BR7, "the subscription is a NOT NULL foreign key" is guaranteed by the primary key of `delivery`.

## Pending candidates (not in the DDL)

When a candidate is decided, add it to the Constraints table and record a `CLxx` entry in `changelog.md`. If it is not adopted, record the reason in `decisions.md`.

| Candidate | Table | Proposed constraint name | Source |
| --- | --- | --- | --- |
| Enforce the candidate key `(customer_id, submission_date)` with a UNIQUE constraint, or explain in the report why it is not enforced | subscription | `uq_subscription_customer_submission_date` | changelog pending candidates |
| Enforce the candidate key `(subscription_id, type, refund_date)` with a UNIQUE constraint, or explain in the report why it is not enforced | refund | `uq_refund_subscription_type_refund_date` | changelog pending candidates |
| `status = 'cancelled'` exactly when `cancellation_date IS NOT NULL` | subscription | `ck_subscription_cancellation` | changelog pending candidates (BR3, BR10) |
| `cancellation_date >= submission_date` | subscription | `ck_subscription_cancellation_date` | changelog pending candidates (BR10) |
| `is_farmers_choice IN (0, 1)` | product | `ck_product_is_farmers_choice` | changelog pending candidates (BR6) |
| `YEAR(first_planning_day) = year` | season | `ck_season_year` | changelog pending candidates (BR3) |
| Declare the status and type columns with `COLLATE utf8mb4_bin` so that the CHECK constraints reject case variants such as `'PLANNED'`; otherwise list this in README `# Limitations` | season, subscription, delivery, refund | — (changes column definitions; no new constraint) | D17 |
