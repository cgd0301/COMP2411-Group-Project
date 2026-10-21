# Business Rules

Enforcement labels:
- **DB constraint**: PK, FK, NOT NULL, UNIQUE or CHECK in the schema.
- **SQL check**: a condition inside the SQL operation (a conditional INSERT ... SELECT or UPDATE ... WHERE in a transaction). Used when the rule needs another row, another table or the current date, which a MySQL CHECK cannot read.
- **Limitation**: documented, not enforced by the database.

Error numbers in tests: 1048 = NULL in a NOT NULL column, 1062 = duplicate key, 1452 = foreign key without a parent row, 3819 = CHECK violated. "0 rows" means the SQL check stopped the change and the data is unchanged.

## BR1 Subscription ownership

- **Rule:** Every subscription is held by exactly one customer and is for exactly one season. A customer may hold zero or more subscriptions, and a season may have zero or more subscriptions.
- **Type:** Cardinality (Customer 1:N Subscription, Season 1:N Subscription); Participation (total for Subscription, partial for Customer and Season).
- **Enforcement:** DB constraint: NOT NULL foreign keys from Subscription to Customer and to Season.
- **Test:** A subscription for a customer that does not exist is rejected (1452); a subscription with a NULL customer is rejected (1048); a customer with no subscription is valid.

## BR2 One subscription per customer per season

- **Rule:** A customer may hold at most one subscription for the same season (for example, Spring 2027). A cancelled subscription still counts, so its holder cannot subscribe to that season again.
- **Type:** Uniqueness.
- **Enforcement:** DB constraint: UNIQUE (customer, season) on Subscription.
- **Test:** A second Spring 2027 subscription for the same customer is rejected (1062); the same customer's Summer 2027 subscription is accepted.

## BR3 Season calendar and subscription status

- **Rule:** A season is the spring, summer or autumn of one year; winter is not a season. Each season has 12 delivery planning days, the Mondays of 12 consecutive weeks. If D is the 1st planning day, the subscription range runs from D-6 to the 12th planning day D+77, both included (84 days). A subscription is planned before its range starts, active from the first to the last day of the range, finished after the range ends, and cancelled once the customer cancels it (BR10). No other status is allowed.
- **Type:** Value; Validity.
- **Enforcement:** DB constraint: UNIQUE (year, season name) on Season; CHECK on the season name, on the four status values, and that D is a Monday. SQL check: status changes at the range boundaries are made by SQL operations (no automatic scheduling).
- **Test:** A season whose 1st planning day is a Tuesday is rejected (3819). Boundary: the subscription is planned on D-7, active on D-6 and on D+77, finished on D+78.

## BR4 Enrolment window and renewal

- **Rule:** A subscription can only be submitted inside the window of its season, which is the season before it: winter for spring (after the previous year's autumn range ends and before the spring range starts), the spring range for summer, and the summer range for autumn. A subscription is a renewal if, when it is submitted, the same customer holds a subscription for the previous subscribable season (the previous year's autumn for spring, spring for summer, summer for autumn) whose status is active or finished. A renewal gets 20% off its allocated cost per delivery (BR5).
- **Type:** Eligibility.
- **Enforcement:** SQL check: the enrolment INSERT ... SELECT inserts the subscription only if its submission date is inside the window, and reads the customer's previous-season subscription to set the allocated cost.
- **Test:** An autumn subscription submitted during the spring range inserts 0 rows; a summer subscription submitted on the last day of the spring range is accepted. A summer subscription whose holder has an active spring subscription gets the renewal cost (160 or 192 HKD per delivery); if that spring subscription was cancelled, it gets 200 or 240 HKD.

## BR5 Plan, frequency and subscription fee

- **Rule:** A subscription's plan is farmer's choice or customizable, and its frequency is weekly or biweekly; neither can be changed after the subscription is submitted. The allocated cost per delivery is 200 HKD for farmer's choice and 240 HKD for customizable, or 160 HKD and 192 HKD for a renewal (BR4). The subscription fee is the number of deliveries (12 for weekly, 6 for biweekly) × the allocated cost per delivery.
- **Type:** Value.
- **Enforcement:** DB constraint: CHECK on the plan and frequency values, and CHECK that the allocated cost matches the plan (200 or 160 for farmer's choice, 240 or 192 for customizable). SQL check: the fee is calculated from the frequency and the allocated cost. Limitation: no operation updates plan or frequency, but a direct UPDATE is not blocked.
- **Test:** Frequency 'monthly' is rejected (3819); a farmer's choice subscription with an allocated cost of 240 is rejected (3819). A weekly farmer's choice renewal costs 12 × 160 = 1920 HKD; a new biweekly customizable subscription costs 6 × 240 = 1440 HKD.

## BR6 Product types of a plan

- **Rule:** Each season has 10 product types, 6 of which are the farmer's choice types. A farmer's choice subscription gets those 6 types, and the customer does not choose them. A customizable subscription must choose exactly 8 different types from its own season's 10 when it is submitted, and the choice cannot be changed once its range starts.
- **Type:** Cardinality (Subscription M:N Product; each customizable subscription chooses exactly 8); Value.
- **Enforcement:** DB constraint: PK (subscription, product) on the chosen types. SQL check: the enrolment transaction counts the chosen types and is rolled back unless there are exactly 8, all from the subscription's season; a change to the choice is accepted only before the range starts.
- **Test:** Choosing the same type twice is rejected (1062). Choosing 7 types, or a summer product for a spring subscription, fails the check and the transaction is rolled back. Replacing a chosen type after the range starts affects 0 rows.

## BR7 Delivery schedule and status

- **Rule:** Each delivery belongs to exactly one subscription and falls on one planning day of that subscription's season; a subscription has at most one delivery per planning day. On the first day of the range, each subscription that is not cancelled gets all its deliveries with status planned: weekly on all 12 planning days, biweekly on the 1st, 3rd, 5th, 7th, 9th and 11th only (6 deliveries). A delivery's status is planned, skipped, success, failed or cancelled. The only allowed changes are planned to skipped by the customer (BR8); planned to success or failed, recorded on the day after the delivery day; and planned to cancelled when the subscription is cancelled (BR10).
- **Type:** Cardinality (Subscription 1:N Delivery); Participation (total for Delivery, partial for Subscription); Uniqueness; Value.
- **Enforcement:** DB constraint: NOT NULL foreign key to Subscription, UNIQUE (subscription, delivery day), CHECK on the five status values. SQL check: deliveries are generated by one INSERT ... SELECT per subscription; every status UPDATE requires the current status to be planned, so any other change affects 0 rows.
- **Test:** A second delivery for the same subscription and day is rejected (1062); status 'delivered' is rejected (3819); changing a skipped delivery to success affects 0 rows. A biweekly subscription has exactly 6 deliveries and none on the 12th planning day.

## BR8 Skipping and refundable skips

- **Rule:** A customer may skip a delivery only while its status is planned and only inside its change window: from the day after the subscription's previous delivery day to the day before this delivery day; for the first delivery, from 6 days before it (the first day of the range) to the day before. Each subscription starts with 2 refundable skips. While at least one remains, a skip refunds the subscription's allocated cost per delivery plus that delivery's add-on fee, and uses up one refundable skip. When none remain, the delivery can still be skipped, but nothing is refunded.
- **Type:** Validity; Quota.
- **Enforcement:** DB constraint: CHECK that the remaining refundable skips are between 0 and 2. SQL check: the skip transaction changes the delivery only if it is planned and the date is inside the window, then records the refund and lowers the count.
- **Test:** Skipping on the delivery day affects 0 rows; skipping the day before succeeds. On a new farmer's choice subscription, the 1st and 2nd skips each refund 200 HKD plus that delivery's add-on fee; the 3rd skip refunds 0 and the count stays 0.

## BR9 Add-on purchases

- **Rule:** An add-on can only be bought for a delivery whose status is planned, inside the same change window as skipping (BR8). Its product types are limited to the subscription's plan: the season's 6 fixed types for a farmer's choice subscription, or the 8 types the customer chose for a customizable one (BR6). Each product type appears at most once in a delivery's add-ons, with a weight of at least 0.1 kg. A delivery's add-on fee is the sum of weight × that product's price per kg, and the price of the delivery is its allocated cost per delivery plus this fee.
- **Type:** Value; Validity; Uniqueness.
- **Enforcement:** DB constraint: CHECK (weight >= 0.1); PK (delivery, product). SQL check: the INSERT ... SELECT adds the line only if the delivery is planned, the date is inside the window, and the product belongs to the subscription's plan.
- **Test:** A weight of 0.05 kg is rejected (3819); a second line for the same product on the same delivery is rejected (1062); a customizable customer adding a type they did not choose inserts 0 rows. 1.5 kg of spinach at 32 HKD/kg gives an add-on fee of 48 HKD.

## BR10 Cancellation and refund

- **Rule:** Only a planned or active subscription can be cancelled. If it is planned (its range has not started), the full subscription fee charged is refunded. If it is active, the refund is min(remaining refundable skips, number of planned deliveries) × the subscription's allocated cost per delivery, plus the add-on fees on all planned deliveries. In both cases the refund is calculated first; then the remaining refundable skips are set to 0, every planned delivery becomes cancelled, and the subscription becomes cancelled. A finished subscription cannot be cancelled.
- **Type:** Validity; Quota.
- **Enforcement:** SQL check: one transaction runs these steps in this order; its UPDATE matches only a planned or active subscription, so cancelling a finished one affects 0 rows.
- **Test:** A new weekly farmer's choice subscription with no skips and no add-ons, cancelled on D-3, refunds 2 × 200 = 400 HKD; its remaining skips become 0 and its 12 deliveries become cancelled. The same subscription cancelled before its range refunds 2400 HKD. Cancelling a finished subscription affects 0 rows.
