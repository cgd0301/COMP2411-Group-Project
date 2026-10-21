UC1-Book a subscription for an upcoming season
| Field | content |
| --- | --- |
| Actor | Customer(new subscriber or renewing subscriber) |
| Supporting actor | Farm staff recording the payment | 
| Trigger | A customer asks to subscribe to an upcoming season |
| Preconditions | The sign-up date is within the booking window which is from the previous season's start date to the day before the target season's start date(the winter gap for spring, the spring range for summer, the summer range for autumn (BR4)); once a season has started, enrolment for it is closed; the chosen plan and frequency exists; the customer holds no subscription for the target season. |
| Main flow | 1. (New customer only) Insert the customer row (C). 2. Retrieve the plan's allocated cost per delivery and the target season's range dates (R). 3. Check that the customer has no subscription for the target season (R) [BR2]. 4. Check that the submission date is inside the enrolment window (R) [BR4]. 5. Determine whether this is a renewal: check whether the customer holds a subscription for the previous subscribable season with status active or finished (R); the allocated cost per delivery is 160/192 HKD for a renewal and 200/240 HKD otherwise(160 = 200 × 0.8,192 = 240 × 0.8)[BR4, BR5]. 6. Compute the season fee: scheduled deliveries (12 weekly / 6 biweekly) × allocated cost per delivery [BR5]. 7. Insert the subscription with status 'planned', the season's range dates, and — for a renewal — renewed_from_sub_id pointing to the previous-season subscription (C) [BR3]. 8. (Customizable plan only) Insert exactly 8 chosen product types, all from the target season's 10 types (C) [BR6]. 9. The customer pays; farm staff inserts the payment row (C). |
| Tables affected | customer (C, R), plan (R), season (R), subscription (R, C), chosen_product (C), payment (C) |
| Rules checked | BR1, BR2, BR4, BR5, BR6 |
| Failure outcome | Duplicate subscription for the same season → rejected (1062); submission outside the window → 0 rows inserted; fewer or more than 8 chosen types, or a type from another season → the transaction is rolled back; an invalid plan or frequency value → rejected (3819). Any failure leaves no partial rows. |

UC2-Record a weekly delivery
| Field | content |
| --- | --- |
| Actor | Farm staff |
| Supporting actor | - |
| Trigger | The day after a scheduled Monday delivery |
| Preconditions | The subscription is active, finished or cancelled; the delivery rows for that delivery day exist with status 'planned' |
| Main flow of success path | 1. Retrieve the delivery rows of that delivery day whose status is 'planned', together with their subscriptions' status (R). 2. For each box that reached the customer: update the delivery from 'planned' to 'success' (U) [BR7]. 3. For each box that did not: update the delivery from 'planned' to 'failed' (U), and farm staff inserts a refund payment row equal to the subscription's allocated cost per delivery (after renewal discount) plus this delivery's add-on fee (C) [BR7, BR9]. The remaining refundable skips are not changed. |
| Tables affected | delivery (R, U), subscription (R), payment (C) |
| Rules checked | BR3, BR7, BR9 |
| Failure outcome | Updating a delivery that is not 'planned' (e.g., skipped or cancelled) affects 0 rows and leaves it unchanged; the status value 'delivered' is rejected (3819) — the correct value is 'success'. Marking an already 'failed' delivery as failed again affects 0 rows, so no second refund row is inserted. |

UC3-Skip a delivery
| Field | content |
| --- | --- |
| Actor | Customer |
| Supporting actor | Farm staff recording the refund |
| Trigger |  A customer asks to skip the upcoming delivery before its scheduled delivery date |
| Preconditions | The subscription is active; the target delivery exists with status 'planned'; the current date is inside the skip window — from the day after the previous delivery day to the day before this delivery day, and from D-6 for the first delivery (BR8) |
| Main flow | 1. Retrieve the target delivery and its subscription (R). 2. Check the delivery status is 'planned' and the date is inside the window (R) [BR8]. 3. Update the delivery from 'planned' to 'skipped' (U). 4. Read the subscription's remaining refundable skips (R). 5. If at least one remains: farm staff inserts a refund payment row equal to the subscription's allocated cost per delivery (after renewal discount) plus this delivery's add-on fee (C), and decreases the remaining refundable skips by one (U) [BR8]. Otherwise nothing is refunded. |
| Tables affected | delivery (R, U), subscription (R, U), payment (C) |
| Rules checked | BR7, BR8|
| Failure outcome | Skipping on the delivery day itself, or skipping a non-'planned' delivery → 0 rows, data unchanged. The 3rd skip in a season is valid but must produce no refund row and leave the skip count at 0. |

UC4-Cancel a subscription with two refund cases
| Field | content |
| --- | --- |
| Actor | Customer |
| Supporting actor | Farm staff recording the refund |
| Trigger | A customer asks to cancel the subscription |
| Preconditions	| The subscription is 'planned' or 'active' (BR10) |
| Main flow of Case A: subscription is 'planned' (not started) | 1. Retrieve the subscription and the fee charged (R). 2. Insert one refund payment row equal to the full season fee (C). 3. Update the subscription to 'cancelled' and record the cancellation date (U). (No delivery rows exist yet, since deliveries are generated on the first day of the range from BR7.) |
| Main flow of Case B: subscription is 'active' | 1. Retrieve the subscription and its allocated cost per delivery (R). 2. Count its 'planned' deliveries whose delivery day is after the cancellation date (R). 3. Read the remaining refundable skips (R). 4. Compute the refund: min(remaining refundable skips, number of those deliveries) × allocated cost per delivery, plus the add-on fees of those deliveries (R) [BR10]. 5. If the refund is greater than 0, insert one refund payment row (C). 6. Set the remaining refundable skips to 0 (U). 7. Update those deliveries to 'cancelled' (U); a 'planned' delivery on or before the cancellation date is left for UC2. 8. Update the subscription to 'cancelled' and record the cancellation date (U). |
| Tables affected |	subscription (R, U), delivery (R, U), payment (R, C) |
| Rules checked |	BR3, BR8, BR10 |
| Failure outcome | Cancelling a 'finished' or 'cancelled' subscription affects 0 rows; no refund row is inserted and all data stays unchanged. |

UC5-Purchase add-on items in an upcoming delivery
| Field | content |
| --- | --- |
| Actor | Customer |
| Supporting actor | Farm staff recording the payment |
| Trigger | A customer wants to add products to an upcoming delivery |
| Preconditions | The subscription is active; the target delivery exists with status 'planned'; the current date is inside the change window — the same window as skipping (BR8, BR9) |
| Main flow | 1. Retrieve the target delivery and its subscription's plan (R). 2. Check the delivery status and the window (R) [BR9]. 3. For each requested product, check eligibility: one of the season's 6 fixed types for a farmer's choice subscription, or one of the 8 chosen types for a customizable subscription (R) [BR6, BR9]. 4. Insert one add-on line per product, each with weight ≥ 0.1 kg and each product appearing at most once per delivery (C) [BR9]. 5. Farm staff inserts the add-on payment row: sum of weight × the product's price per kg (C) [BR9]. |
| Tables affected | delivery (R), subscription (R), plan (R), product (R), delivery_item (C), payment (C) |
| Rules checked | 	BR5, BR6, BR7, BR9 |
| failure outcome | A product outside the subscription's eligible types → 0 rows; a weight below 0.1 kg → rejected (3819); the same product twice in one delivery → rejected (1062). |


