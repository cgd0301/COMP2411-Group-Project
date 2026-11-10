# Expected Query Results on the Seed Baseline (roadmap 2.10)

Internal working file: do not put it in the submission ZIP. These are the results Q01–Q05 must return on freshly built seed data (`sql/01_schema.sql` then `sql/02_data.sql`), before any test changes the data. Phase 5 compares each exported `evidence/query_results/Qxx.csv` with the tables below.

**Source.** The `expected` sheet of `stage2/notes/seed_plan.xlsx` computes every figure from the workbook tables: pivot tables for Q01, Q02 and Q05, formula tables for Q03 and Q04. Each figure was also computed by hand from `seed_timelines.md`, and the two sets agree.

**Scope.** Every query covers Spring 2026 (`season_id` 2). Plan types are written fc = `'farmer''s choice'` and cz = `'customizable'`. Column names here are working names; the final query may name or round its columns differently, but the values must match.

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

## Test fixtures

The expected values for the Phase 7 test fixtures (UC1–UC5 on the baseline) are in `seed_cast.md` section 5 and are not repeated here.
