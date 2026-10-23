UC1-Book a subscription for an upcoming season
| Field | content |
| --- | --- |
| Actor | Customer(new subscriber or renewing subscriber) |
| Supporting actor | Farm staff recording the payment | 
| Trigger | A customer asks to subscribe to an upcoming season |
| Preconditions | The submission date is inside the enrolment window of the target season (BR4): for spring, after the previous year's autumn range ends and before the spring range starts (the winter gap); for summer, inside the spring range; for autumn, inside the summer range. A range runs from D-6 to D+77, where D is the season's first_planning_day (BR3). Once the target season's range has started, enrolment for it is closed. The target season exists; the plan type is farmer's choice or customizable and the frequency is weekly or biweekly; the customer holds no subscription for the target season, whatever its status (a cancelled one also counts). |
| Main flow | 1. (New customer only) Insert the customer row with a unique email (C) [BR1]. 2. Retrieve the target season and the previous subscribable season (season_name, year, first_planning_day) and derive their range dates D-6 and D+77 (R) [BR3]. 3. Check that the customer has no subscription for the target season (R) [BR2]. 4. Check that the submission date is inside the enrolment window (R) [BR4]. 5. Determine whether this is a renewal: check whether, on the submission date, the customer holds a subscription for the previous subscribable season (the previous year's autumn for spring, spring for summer, summer for autumn) with status active or finished (R). The allocated_cost is 160/192 HKD for a renewal and 200/240 HKD otherwise (160 = 200 × 0.8, 192 = 240 × 0.8) [BR4, BR5]. 6. Compute the season fee: scheduled deliveries (12 weekly / 6 biweekly) × allocated_cost; the fee is derived and not stored [BR5]. 7. Insert the subscription with customer_id, season_id, plan_type, frequency, allocated_cost, submission_date, status 'planned', remaining_refundable_skip = 2 and cancellation_date NULL (C) [BR1, BR3, BR5, BR8]. 8. (Customizable plan only) Check the requested product types against product (R) and insert exactly 8 different chosen_products rows, all from the target season's 10 types (C) [BR6]; a farmer's choice subscription inserts no chosen_products rows. 9. The customer pays the season fee to farm staff; payment is outside the database scope and no row is written. |
| Tables affected | customer (C, R), season (R), subscription (R, C), product (R), chosen_products (C) |
| Rules checked | BR1, BR2, BR3, BR4, BR5, BR6 |
| Failure outcome | A new customer with an existing email → rejected (1062); a subscription for a customer that does not exist → rejected (1452); a NULL customer → rejected (1048); a duplicate subscription for the same season, even a cancelled one → rejected (1062); submission outside the window → 0 rows inserted; an invalid plan_type or frequency value, or an allocated_cost that does not match the plan → rejected (3819); the same type chosen twice → rejected (1062); fewer or more than 8 chosen types, or a type from another season → the transaction is rolled back. Any failure leaves no partial rows. |

UC2-Record a weekly delivery
| Field | content |
| --- | --- |
| Actor | Farm staff |
| Supporting actor | - |
| Trigger | The day after a scheduled Monday delivery |
| Preconditions | The subscription is active, finished or cancelled (a cancelled subscription may still have a 'planned' delivery on or before its cancellation date, BR10); the delivery rows for that delivery day exist with status 'planned', where delivery day = first_planning_day + 7 × (week_no − 1). |
| Main flow of success path | 1. Retrieve the delivery rows whose derived delivery day is the previous day and whose status is 'planned', together with their subscriptions and the season's first_planning_day (R) [BR3, BR7]. 2. For each box that reached the customer: update the delivery from 'planned' to 'success'; the UPDATE matches only a delivery whose status is 'planned' (U) [BR7]. No refund row is inserted and remaining_refundable_skip is not changed. |
| Main flow of failure path | (The delivery box did not reach the customer.) 1. Retrieve the target delivery (status 'planned', delivery day = the previous day), its subscription's allocated_cost and the season's first_planning_day (R) [BR3, BR7]. 2. Start one transaction and update the delivery from 'planned' to 'failed'; the UPDATE matches only a delivery whose status is 'planned' (U) [BR7]. 3. If 0 rows are affected, roll back: the delivery has already been recorded, skipped or cancelled, and no refund is written. 4. Compute this delivery's add-on fee as the sum of weight × price_per_kg over its add_on rows; it is 0 if the delivery has no add-on (R) [BR9]. 5. Farm staff inserts one refund row of type 'failed' for this delivery (subscription_id, week_no), with amount = allocated_cost (which already includes any renewal discount) + the add-on fee, and refund_date = today (C) [BR7, BR11]. 6. Commit. remaining_refundable_skip is not changed, because a failed refund does not use a refundable skip [BR7]. |
| Tables affected | delivery (R, U), subscription (R), season (R), add_on (R), product (R), refund (C) |
| Rules checked | BR3, BR7, BR9, BR11|
| Failure outcome | Updating a delivery that is not 'planned' (e.g., skipped or cancelled) affects 0 rows and leaves it unchanged; the status value 'delivered' is rejected (3819) — the correct value is 'success'. Marking an already 'failed' delivery as failed again affects 0 rows, so no second refund row is inserted; a second refund row for the same delivery is rejected (1062); a 'failed' refund with no delivery is rejected (3819). If the refund INSERT fails, the whole transaction is rolled back and the delivery stays 'planned'. |

UC3-Skip a delivery
| Field | content |
| --- | --- |
| Actor | Customer |
| Supporting actor | Farm staff recording the refund |
| Trigger |  A customer asks to skip the upcoming delivery before its scheduled delivery date |
| Preconditions | The subscription is active; the target delivery exists with status 'planned'; today is inside the change window (BR8). The window runs from the day after the subscription's previous delivery day (the previous week_no for weekly, two week_no earlier for biweekly) to the day before this delivery day. For the first delivery, it runs from D-6 (the first day of the range) to D-1. |
| Main flow | 1. Retrieve the target delivery, its subscription and the season's first_planning_day (R). 2. Check the delivery status is 'planned' and today is inside the window (R) [BR8]. 3. Update the delivery from 'planned' to 'skipped' (U) [BR7]. 4. Read the subscription's remaining_refundable_skip (R). 5. If at least one remains: compute this delivery's add-on fee (sum of weight × price_per_kg over its add_on rows) (R) [BR9]; farm staff inserts a refund row of type 'skip' for this delivery (subscription_id, week_no), with amount = allocated_cost + the add-on fee and refund_date = today (C) [BR8, BR11]; then decrease remaining_refundable_skip by one (U) [BR8]. Otherwise nothing is refunded and no refund row is inserted. Steps 2–5 run in one transaction. |
| Tables affected | delivery (R, U), subscription (R, U), season (R), add_on (R), product (R), refund (C) |
| Rules checked | BR7, BR8, BR9,BR11 |
| Failure outcome | Skipping on the delivery day itself, before the window starts, or skipping a non-'planned' delivery → 0 rows, data unchanged. The 3rd skip in a season is valid but must produce no refund row and leave the skip count at 0; a count below 0 is rejected (3819). |

UC4-Cancel a subscription with two refund cases
| Field | content |
| --- | --- |
| Actor | Customer |
| Supporting actor | Farm staff recording the refund |
| Trigger | A customer asks to cancel the subscription |
| Preconditions	| The subscription is 'planned' or 'active' (BR10); the cancellation date is the day of the request. |
| Main flow of Case A: subscription is 'planned' (not started) | 1. Retrieve the subscription's frequency and allocated_cost and derive the full season fee: 12 or 6 × allocated_cost (R) [BR5]. 2. Insert one refund row of type 'cancellation' with no delivery, amount = the full season fee, refund_date = the cancellation date (C) [BR10, BR11]. 3. Set remaining_refundable_skip to 0 (U) [BR10]. 4. Update the subscription to 'cancelled' and record the cancellation_date (U). (No delivery rows exist yet, since deliveries are generated on the first day of the range from BR7.). |
| Main flow of Case B: subscription is 'active' | 1. Retrieve the subscription, its allocated_cost and the season's first_planning_day (R). 2. Count its 'planned' deliveries whose delivery day is after the cancellation date (R). 3. Read remaining_refundable_skip (R). 4. Compute the refund: min(remaining_refundable_skip, number of those deliveries) × allocated_cost, plus the add-on fees of those deliveries, i.e. the sum of weight × price_per_kg (R) [BR9, BR10]. 5. If the refund is greater than 0, insert one refund row of type 'cancellation' with no delivery and refund_date = the cancellation date (C) [BR11]. 6. Set remaining_refundable_skip to 0 (U). 7. Update those deliveries to 'cancelled' (U) [BR7]; a 'planned' delivery on or before the cancellation date is left for UC2. 8. Update the subscription to 'cancelled' and record the cancellation_date (U). All steps run in one transaction in this order. |
| Tables affected |	subscription (R, U), season (R), delivery (R, U), add_on (R), product (R), refund (C). |
| Rules checked | BR3, BR5, BR7, BR8, BR9, BR10, BR11 |
| Failure outcome | Cancelling a 'finished' or 'cancelled' subscription affects 0 rows; no refund row is inserted and all data stays unchanged. A 'cancellation' refund linked to a delivery is rejected (3819). |

UC5-Purchase add-on items in an upcoming delivery
| Field | content |
| --- | --- |
| Actor | Customer |
| Supporting actor | Farm staff recording the payment |
| Trigger | A customer wants to add products to an upcoming delivery |
| Preconditions | The subscription is active; the target delivery exists with status 'planned'; today is inside the change window, which is the same window as skipping (BR8, BR9). |
| Main flow | 1. Retrieve the target delivery, its subscription's plan_type and season_id, and the season's first_planning_day (R). 2. Check the delivery status and the window (R) [BR8, BR9]. 3. For each requested product, check eligibility (R) [BR6, BR9]: for a farmer's choice subscription, the product must be one of its season's 6 types with is_farmers_choice = TRUE; for a customizable subscription, it must be one of the 8 types in its chosen_products. 4. Insert one add_on row (subscription_id, week_no, product_id, weight) per product, each with weight ≥ 0.1 kg and each product appearing at most once per delivery (C) [BR9]. 5. The add-on fee is the sum of weight × the product's price_per_kg, and the delivery price is allocated_cost + the add-on fee. Both are derived and not stored; the customer pays farm staff outside the database [BR5, BR9]. |
| Tables affected | delivery (R), subscription (R), season (R), chosen_products (R), product (R), add_on (C). |
| Rules checked | 	BR5, BR6, BR7,BR8, BR9 |
| failure outcome | A product outside the subscription's eligible types, a delivery that is not 'planned', or a date outside the window → 0 rows; a weight below 0.1 kg → rejected (3819); the same product twice in one delivery → rejected (1062); an add-on for a delivery that does not exist → rejected (1452). |


