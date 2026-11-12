# Expected Query Results on the Seed Baseline (roadmap 2.10)

Internal working file: do not put it in the submission ZIP. These are the results Q01–Q08 must return on freshly built seed data (`sql/01_schema.sql` then `sql/02_data.sql`), before any test changes the data. Phase 5 compares each exported `evidence/query_results/Qxx.csv` with the tables below.

**Source.** The `expected` sheet of `stage2/notes/seed_plan.xlsx` computes every figure from the workbook tables: pivot tables for Q01, Q02 and Q05, formula tables for Q03 and Q04. Each figure was also computed by hand from `seed_timelines.md`, and the two sets agree. Q06–Q08 were computed by hand from `seed_timelines.md`; the Q07 amounts agree with the `fee`, `addon_income` and `refund_total` columns of the workbook's `t_sub`, and the Q06 and Q08 rows agree with plain listings of the seed rows.

**Scope.** Q01–Q05 cover Spring 2026 (`season_id` 2); Q06–Q08 state their own scope. Plan types are written fc = `'farmer''s choice'` and cz = `'customizable'`. Column names here are working names; the final query may name or round its columns differently, but the values must match.

## Q01 / MQ1: subscriptions, fee, add-on income, refunds and net income per plan type

Cancelled subscriptions are included, because they were sold and then refunded.

- **Fee** = number of deliveries (12 for weekly, 6 for biweekly) × `allocated_cost`.
- **Add-on income** = the sum of weight × price per kg over all of the subscription's add-ons, whatever the delivery status.
- **Net** = fee + add-on income − refunds.

| plan_type | subscriptions | fee | add-on income | refunds | net |
|---|---|---|---|---|---|
| customizable | 4 | 7776.00 | 185.50 | 672.00 | 7289.50 |
| farmer's choice | 7 | 12480.00 | 325.00 | 2738.00 | 10067.00 |

**Traps the query must survive:**
- Subscription 202 has 2 add-ons (78.00) and 2 refunds (430.00). Joining add-ons and refunds in one step multiplies the rows, and the fc add-on income and refunds come out too high. Add-ons and refunds must be aggregated per subscription first.
- Subscriptions 209 and 210 have neither add-ons nor refunds, so their totals need `COALESCE(..., 0)`.
- Subscription 203 (case A) contributes fee 1200.00 and refund 1200.00, so its net is 0.00; it must still be counted.

## Q02 / MQ2: add-on income from successful deliveries, per plan type and product

Only add-ons on deliveries whose status is `success` count. Products are ordered by income within each plan type.

| plan_type | product | income | weight (kg) | top of plan type |
|---|---|---|---|---|
| customizable | Strawberries | 127.50 | 1.50 | yes |
| customizable | Asparagus | 58.00 | 1.00 | |
| farmer's choice | Spinach | 112.00 | 3.50 | yes |
| farmer's choice | Choy Sum | 35.00 | 1.00 | |

**Trap:** three Spring 2026 add-ons sit on deliveries that are not `success` and must be excluded:
- Chinese Kale 126.00 on cancelled 205 wk4;
- Broccoli 30.00 on failed 202 wk9;
- Lettuce 22.00 on skipped 204 wk7.

If the Chinese Kale add-on is wrongly included, it overtakes Spinach as the fc top product.

## Q03 / MQ3: skip rate and failure rate per delivery week

Cancelled deliveries are excluded.

- **Skip rate** = skipped ÷ non-cancelled deliveries of the week.
- **Failure rate** = failed ÷ attempted, where attempted = success + failed.

| week_no | non_cancelled | skipped | failed | success | attempted | skip_rate | failure_rate |
|---|---|---|---|---|---|---|---|
| 1 | 10 | 0 | 0 | 10 | 10 | 0.0000 | 0.0000 |
| 2 | 6 | 0 | 0 | 6 | 6 | 0.0000 | 0.0000 |
| 3 | 10 | 0 | 0 | 10 | 10 | 0.0000 | 0.0000 |
| 4 | 5 | 0 | 0 | 5 | 5 | 0.0000 | 0.0000 |
| 5 | 9 | 0 | 1 | 8 | 9 | 0.0000 | 0.1111 |
| 6 | 5 | 5 | 0 | 0 | 0 | 1.0000 | NULL |
| 7 | 9 | 1 | 0 | 8 | 8 | 0.1111 | 0.0000 |
| 8 | 4 | 0 | 0 | 4 | 4 | 0.0000 | 0.0000 |
| 9 | 8 | 0 | 1 | 7 | 8 | 0.0000 | 0.1250 |
| 10 | 4 | 0 | 0 | 4 | 4 | 0.0000 | 0.0000 |
| 11 | 8 | 0 | 0 | 8 | 8 | 0.0000 | 0.0000 |
| 12 | 4 | 0 | 0 | 4 | 4 | 0.0000 | 0.0000 |

**What these rows test:**
- Week 6 (Easter Monday 2026-04-06) has only skipped deliveries, so its failure rate must be NULL (`NULLIF(attempted, 0)`), not an error and not 0. In the CSV it is written as `\N`.
- Even weeks contain only weekly subscriptions, which is why rates rather than counts are compared.
- Weeks 4–12 exclude the cancelled deliveries of 204 and 205.

## Q04 / MQ4: products chosen by customizable subscribers

All 10 Spring 2026 products are listed, including those nobody chose. The denominator is the number of Spring 2026 customizable subscriptions, which is 4.

| product_id | product | farmer's choice type | chosen_count | pick_rate |
|---|---|---|---|---|
| 11 | Spinach | 1 | 4 | 1.0000 |
| 12 | Lettuce | 1 | 3 | 0.7500 |
| 13 | Pak Choi | 1 | 0 | 0.0000 |
| 14 | Chinese Kale | 1 | 4 | 1.0000 |
| 15 | Choy Sum | 1 | 4 | 1.0000 |
| 16 | Broccoli | 1 | 4 | 1.0000 |
| 17 | Carrots | 0 | 2 | 0.5000 |
| 18 | Snow Peas | 0 | 3 | 0.7500 |
| 19 | Asparagus | 0 | 4 | 1.0000 |
| 20 | Strawberries | 0 | 4 | 1.0000 |

**Traps:**
- Pak Choi has no `chosen_products` row. It appears with 0 only if the query starts from `product` and uses a LEFT JOIN; an inner join drops it.
- Six products share the maximum count of 4, so a "most popular" query must return all six.

## Q05 / MQ5: renewal from Spring 2026 into Summer 2026, per plan type

Only Spring 2026 subscriptions that were not cancelled are counted. A customer renewed if the same customer has a Summer 2026 subscription.

| plan_type | spring subscriptions | renewed | renewal_rate | HAVING rate < 0.60 |
|---|---|---|---|---|
| customizable | 4 (206, 207, 210, 211) | 1 (210) | 0.2500 | kept |
| farmer's choice | 4 (201, 202, 208, 209) | 3 (201, 202, 208) | 0.7500 | rejected |

The query with `HAVING` returns the customizable row only.

**Traps:**
- C05 (205 cancelled, then 303 in summer) must not be counted, neither in the denominator nor as a renewal.
- C12 and C15 have Summer 2026 subscriptions but no Spring 2026 subscription, so they do not appear at all.

## Technique coverage of Q01–Q08

The source for `evidence/query_map.csv`. The Q01–Q05 tags follow the analysis in `mgtQuestions.md`; confirm every tag when the SQL is written. Each query names an existing management question, so no new question and no change-log entry are needed [9.2].

| Query | Business question | Techniques |
|---|---|---|
| Q01 | MQ1 | join; join3plus; group_by; subquery; null_handling |
| Q02 | MQ2 | join; join3plus; group_by; subquery; correlated |
| Q03 | MQ3 | join; join3plus; group_by; null_handling |
| Q04 | MQ4 | join; join3plus; group_by; subquery; null_handling |
| Q05 | MQ5 | join; group_by; having; null_handling |
| Q06 | MQ5 | join; join3plus; subquery; correlated; exists |
| Q07 | MQ1 | view; join; join3plus |
| Q08 | MQ1 | join; join3plus; group_by; having; subquery; null_handling; other_nontrivial |

Against guidance 6.2: multi-table joins Q01–Q08 (three or more tables in all but Q05); GROUP BY in Q01–Q05 and Q08, HAVING in Q05 and Q08; subqueries in Q01, Q02, Q04, Q06 and Q08, correlated or EXISTS in Q02 and Q06; missing values in Q01, Q03, Q04, Q05 and Q08; the additional non-trivial query is Q08; Q07 uses the view.

## Q06 / MQ5: Summer 2026 subscribers who have not enrolled for Autumn 2026

- **Question:** Which customers hold an active Summer 2026 subscription but no Autumn 2026 subscription yet, and what allocated cost per delivery would each get by renewing with the same plan?
- **Business question:** MQ5 (renewal), applied to the Autumn 2026 enrolment window that is open on the baseline.
- **Techniques:** `join; join3plus; subquery; correlated; exists`
- **Tables:** customer, subscription and season in the outer query (Summer 2026); subscription and season in the subquery (Autumn 2026).
- **Logic:** Start from the Summer 2026 subscriptions with `status = 'active'`, identifying the season by `season_name` and `year` rather than a `season_id` literal, and join the customer. Keep a row only if NOT EXISTS an Autumn 2026 subscription of the same customer, whatever its status: under BR2 a cancelled Autumn 2026 subscription still occupies the slot, so its holder cannot enrol again. The renewal cost is 160.00 for fc and 192.00 for cz, because under BR4 an active Summer subscription makes any Autumn enrolment a renewal. ORDER BY `customer_id`. The query uses the stored status and no date literal (D06).
- **Expected result (4 rows):**

| customer_id | name | email | summer_subscription_id | plan_type | frequency | renewal_cost |
|---|---|---|---|---|---|---|
| 2 | Bella Wong | bella.wong@example.com | 302 | farmer's choice | weekly | 160.00 |
| 5 | Ethan Ho | ethan.ho@example.com | 303 | farmer's choice | weekly | 160.00 |
| 8 | Helen Lau | helen.lau@example.com | 304 | farmer's choice | biweekly | 160.00 |
| 10 | Jenny Yip | jenny.yip@example.com | 305 | customizable | biweekly | 192.00 |

- **Matching rows:** C02, C05, C08 and C10 (`seed_cast.md` coverage #19).
- **Non-matching rows:**
  - C01: 301 is active, but C01 already holds 401, so NOT EXISTS removes the row.
  - C15: holds 403, and 307 is cancelled, so the status filter removes the row.
  - C12: 306 is cancelled, so the status filter removes the row.
  - C06: holds 402 but has no Summer 2026 subscription, so C06 never enters the outer query.
  - C13 and C14: no subscription at all.
- **Traps:**
  - C05's 303 was bought at full price (200.00), yet the renewal cost is 160.00: the discount depends on the previous subscription being active, not on whether it was itself a renewal.
  - A subquery that is not correlated on `customer_id` ("does any Autumn 2026 subscription exist?") is always true here, so the query returns 0 rows.
  - Adding `status <> 'cancelled'` inside the subquery would remind a customer whose Autumn 2026 subscription was cancelled, who cannot enrol again (BR2). The seed has no such customer, so the result does not show this mistake; the logic must still exclude it.
- **Decision supported:** Send these four customers a renewal reminder with the discounted price before the Autumn 2026 enrolment window closes on 2026-08-17. The list shows who has not renewed yet; it does not explain why.

## Q07 / MQ1: settled subscriptions with a high refund share (uses the view)

- **Question:** Among settled subscriptions (status `finished` or `cancelled`, so their refunds are final), which had more than 15% of the amount paid refunded?
- **Business question:** MQ1 (cost of the refund policies), refined from plan-type totals in one season to individual subscriptions in all seasons.
- **Techniques:** `view; join; join3plus`. The missing-value handling (no add-ons or no refunds gives 0) happens inside the view.
- **Tables:** the Phase 4 per-subscription view, subscription, customer and season.
- **What the view must provide** (its content; the column names are SHI's choice): for every subscription, fee = 12 (weekly) or 6 (biweekly) × `allocated_cost`; add-on income = the sum of weight × price per kg over all its add-ons, whatever the delivery status (as in Q01); refund total = the sum of all its refunds; 0, not NULL, when it has no add-on or no refund.
- **Logic:** amount paid = fee + add-on income; refund share = refund total ÷ amount paid, rounded to 4 decimals. Keep `status IN ('finished', 'cancelled')` and refund share > 0.15. ORDER BY refund share DESC.
- **Expected result (7 rows):**

| subscription_id | customer | season | plan_type | frequency | status | amount_paid | refund_total | refund_share |
|---|---|---|---|---|---|---|---|---|
| 203 | Calvin Lee | spring 2026 | farmer's choice | biweekly | cancelled | 1200.00 | 1200.00 | 1.0000 |
| 306 | Lily Kwok | summer 2026 | farmer's choice | biweekly | cancelled | 1200.00 | 400.00 | 0.3333 |
| 205 | Ethan Ho | spring 2026 | farmer's choice | weekly | cancelled | 2526.00 | 526.00 | 0.2082 |
| 204 | Daisy Lam | spring 2026 | farmer's choice | weekly | cancelled | 2422.00 | 422.00 | 0.1742 |
| 202 | Bella Wong | spring 2026 | farmer's choice | weekly | finished | 2478.00 | 430.00 | 0.1735 |
| 307 | Oscar Poon | summer 2026 | farmer's choice | weekly | cancelled | 2400.00 | 400.00 | 0.1667 |
| 211 | Kelvin Mak | spring 2026 | customizable | biweekly | finished | 1482.50 | 240.00 | 0.1619 |

- **Rejected by the threshold (10 settled subscriptions):** 201 (160.00 / 1955.00 = 0.0818), 206 (192.00 / 2362.00 = 0.0813), 207 (240.00 / 2965.00 = 0.0809); 101–104 and 208–210 at 0.0000. The threshold has a wide margin: the lowest kept share is 0.1619, the highest rejected share is 0.0818.
- **Not settled, so not considered:** 301–305 (active) and 401–403 (planned).
- **Traps:**
  - The fee must come from the frequency, not from counting delivery rows: 203 was cancelled before its range and has no deliveries, yet its fee is 1200.00. Counting deliveries gives a fee of 0 and a division by zero (NULL), and 203 disappears.
  - 202's add-ons and refunds must be aggregated separately inside the view. Joining both at once gives 156.00 and 860.00, so its share becomes 860.00 / 2556.00 = 0.3365.
- **Decision supported:** The most refund-heavy settled subscriptions are cancellations: 203 (cancelled before its range, full refund), then 306, 205 and 307 (cancelled during the range). 204's refunds come from its two skips (its cancellation refunded 0), 202's from a skip and a failed delivery, and 211's from a failed delivery. This informs whether the in-season cancellation refund and the 2 refundable skips should be reviewed. The shares describe synthetic data only.

## Q08 / MQ1 and the W04 quota: use of the refundable skips per season and plan type

- **Question:** For each season and plan type, how many skips were made, how many were refunded, how many were not refunded because both refundable skips had already been used, and what share of subscriptions used both refundable skips?
- **Business question:** MQ1, whose decision includes whether the 2 refundable skips per subscription should be reviewed. It also shows the W04 requirement to record the use of a quota.
- **Techniques:** `join; join3plus; group_by; having; subquery; null_handling; other_nontrivial`. The non-trivial logic: a two-level aggregation (per subscription, then per season and plan type), in which an unrefunded skip is recognised by the absence of a refund row.
- **Tables:** season, subscription, delivery and refund.
- **Logic:**
  - Level 1, one row per subscription: start from `subscription`, LEFT JOIN its `skipped` deliveries, and LEFT JOIN each of those deliveries to its refund on (`subscription_id`, `week_no`). skips = number of skipped deliveries; refunded = number of them with a refund row.
  - Level 2, GROUP BY season and plan type: subscriptions = number of level-1 rows; skips; refunded; unrefunded = skips − refunded; used_both = number of subscriptions with refunded = 2; used_both_share = used_both ÷ subscriptions, rounded to 4 decimals. HAVING skips > 0. ORDER BY season (chronologically) and plan type.
  - Every subscription of the group counts, including cancelled ones. Summer 2026 is still running, so its figures are those of the baseline. The query uses no date literal (D06).
- **Expected result (4 rows):**

| season | plan_type | subscriptions | skips | refunded | unrefunded | used_both | used_both_share |
|---|---|---|---|---|---|---|---|
| spring 2026 | customizable | 4 | 2 | 2 | 0 | 0 | 0.0000 |
| spring 2026 | farmer's choice | 7 | 4 | 4 | 0 | 1 | 0.1429 |
| summer 2026 | customizable | 1 | 1 | 1 | 0 | 0 | 0.0000 |
| summer 2026 | farmer's choice | 6 | 3 | 2 | 1 | 1 | 0.1667 |

- **Rows behind the figures:**
  - Spring cz (206, 207, 210, 211): one refunded skip each for 206 and 207 (wk6).
  - Spring fc (201–205, 208, 209): 201 wk6, 202 wk6, 204 wk6 and wk7, all refunded; 204 used both.
  - Summer cz (305): wk3, refunded.
  - Summer fc (301–304, 306, 307): 302 wk2 and wk4 refunded, wk5 not refunded (added for this query, `seed_cast.md` coverage #23); 302 used both.
- **Rejected by HAVING (no skips):** Autumn 2025 fc (101, 103), Autumn 2025 cz (102, 104), Autumn 2026 fc (401, 403) and Autumn 2026 cz (402).
- **Traps:**
  - `remaining_refundable_skip = 0` does not mean "used both": a cancellation also sets it to 0. Counting it gives used_both = 3 for Spring fc (203, 204, 205) and 3 for Summer fc (302, 306, 307).
  - Skips must be counted from `delivery`. An unrefunded skip has no refund row, so counting `'skipped'` refund rows makes skips equal refunded and unrefunded 0 everywhere.
  - Level 1 must start from `subscription` with LEFT JOINs and count a delivery column, not `COUNT(*)`. Otherwise the groups with no skips never form, so HAVING rejects nothing, or a subscription with no skip is counted as one skip.
- **Decision supported:** In each group at most one subscription used both refundable skips, and only one skip in the whole seed went unrefunded, so in the synthetic data the 2-skip quota rarely limits customers. This informs whether the quota should stay at 2; it describes synthetic data only.

## Test fixtures

The expected values for the Phase 7 test fixtures (UC1–UC5 on the baseline) are in `seed_cast.md` section 5 and are not repeated here.
