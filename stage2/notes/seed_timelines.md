# Seed Event Timelines (roadmap 2.5)

Internal working file: do not put it in the submission ZIP. It turns the cast in `seed_cast.md` into dated events, and each event into the rows it leaves in the seed data. `sql/02_data.sql` is written from the registers in Section 6. Abbreviations are those of `seed_cast.md`.

## Conventions

- **Baseline.** The seed data are the state at the start of Tuesday 2026-07-07, before any operation of that day (D04). Only events dated up to 2026-07-06 are included.
- **Delivery day.** Week w is delivered on D + 7 × (w − 1), where D is the season's first planning day (BR7).
- **Change window (BR8, BR9).** Week 1: D − 6 to D − 1. Weekly, w ≥ 2: from the day after week w − 1's delivery day to the day before week w's. Biweekly (odd w ≥ 3): from the day after week w − 2's delivery day to the day before week w's.
- **Recording.** A delivery's result is recorded on the day after its delivery day (BR7). Every recorded delivery not named in a timeline is `success`.
- **Range events.** On the first day of the range (D − 6), every subscription that is not cancelled becomes `active` and gets all its deliveries as `planned` (BR3, BR7). From the day after D + 77, it is `finished`.
- **Prices.** Add-on fee = weight × price per kg. A skip or failed refund = `allocated_cost` + that delivery's add-on fee. A cancellation refund follows BR10, and a zero refund writes no row (D20).
- **Renewal.** Decided on the submission date (D24). Autumn 2025 subscriptions are all new (D23).
- **Checks.** Each date below has been checked against its window, and every amount and final state has been recomputed by replaying all events in date order.

## 1. Season calendar

| Season | D | Range | Enrolment window | Delivery days, weeks 1–12 |
|---|---|---|---|---|
| A25 | 2025-09-08 | 2025-09-02 to 2025-11-24 | 2025-05-27 to 2025-08-18 (D22) | Sep 8, 15, 22, 29; Oct 6, 13, 20, 27; Nov 3, 10, 17, 24 |
| S26 | 2026-03-02 | 2026-02-24 to 2026-05-18 | 2025-11-25 to 2026-02-23 | Mar 2, 9, 16, 23, 30; Apr 6, 13, 20, 27; May 4, 11, 18 |
| Su26 | 2026-06-01 | 2026-05-26 to 2026-08-17 | 2026-02-24 to 2026-05-18 | Jun 1, 8, 15, 22, 29; Jul 6, 13, 20, 27; Aug 3, 10, 17 |
| A26 | 2026-09-07 | 2026-09-01 to 2026-11-23 | 2026-05-26 to 2026-08-17 | Not needed: no deliveries before the baseline |

Biweekly subscriptions have only the odd weeks 1, 3, 5, 7, 9 and 11.

## 2. Plain subscriptions

These subscriptions have no event other than submission and the range events.

| Sub | Customer | Season, plan, frequency | Submitted | `allocated_cost` and reason | Deliveries on the baseline | Status, remaining skips |
|---|---|---|---|---|---|---|
| 101 | C01 | A25 fc W | 2025-07-10 | 200.00, new (D23) | wk1–12 `success` | finished, 2 |
| 102 | C06 | A25 cz W | 2025-07-18 | 240.00, new (D23); chosen: all A25 products except Pumpkin, Winter Melon | wk1–12 `success` | finished, 2 |
| 103 | C08 | A25 fc B | 2025-08-02 | 200.00, new (D23) | wk1, 3, 5, 7, 9, 11 `success` | finished, 2 |
| 104 | C10 | A25 cz B | 2025-08-15 | 240.00, new (D23); chosen: all A25 products except Pumpkin, Winter Melon | wk1, 3, 5, 7, 9, 11 `success` | finished, 2 |
| 209 | C09 | S26 fc B | 2026-02-05 | 200.00, new: C09 has no A25 subscription | wk1, 3, 5, 7, 9, 11 `success` | finished, 2 |
| 210 | C10 | S26 cz B | 2026-01-08 | 192.00, renewal: 104 finished on 2025-11-25; chosen: all S26 products except Pak Choi, Carrots | wk1, 3, 5, 7, 9, 11 `success` | finished, 2 |
| 303 | C05 | Su26 fc W | 2026-04-10 | 200.00, new: C05's S26 subscription 205 was cancelled on 2026-03-18, before this submission (D24) | wk1–5 `success`; wk6–12 `planned` | active, 2 |
| 401 | C01 | A26 fc W | 2026-06-15 | 160.00, renewal: 301 active on that day | none yet | planned, 2 |
| 402 | C06 | A26 cz W | 2026-06-20 | 240.00, new: C06 has no Su26 subscription; chosen: all A26 products except White Radish, Taro | none yet | planned, 2 |

All submission dates lie inside the season's enrolment window, and every `cancellation_date` above is NULL.

## 3. Spring 2026 timelines

Every S26 subscription that is not cancelled becomes `finished` on 2026-05-19.

### 201 · C01 · fc · weekly · 160.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2025-12-10 | Submitted | Inside the S26 window. 101 finished → renewal | subscription 201: 160.00, `planned`, skips 2 |
| 2026-02-24 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-04-01 | Skips wk6 (Apr 6, Easter) | Window Mar 31 to Apr 5; 2 refundable skips left | wk6 `skipped`; refund `skipped` wk6 160.00 on 2026-04-01; skips 2 → 1 |
| 2026-04-29 | Add-on for wk10 (May 4) | Window Apr 28 to May 3; Choy Sum is an S26 farmer's choice type | add_on wk10 Choy Sum 1.00 kg = 35.00 |
| 2026-05-19 | Range ended | — | status `finished` |

**Baseline:** `finished`, skips 1, no cancellation. wk6 `skipped`; all other weeks `success`, including wk10 with its add-on.

### 202 · C02 · fc · weekly · 200.00 (new)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-01-05 | Submitted | Inside the S26 window. No A25 subscription → new | subscription 202: 200.00, `planned`, skips 2 |
| 2026-02-24 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-03-10 | Add-on for wk3 (Mar 16) | Window Mar 10 to Mar 15; Spinach is a farmer's choice type | add_on wk3 Spinach 1.50 kg = 48.00 |
| 2026-04-01 | Skips wk6 (Apr 6, Easter) | Window Mar 31 to Apr 5; 2 left | wk6 `skipped`; refund `skipped` wk6 200.00 on 2026-04-01; skips 2 → 1 |
| 2026-04-21 | Add-on for wk9 (Apr 27) | Window Apr 21 to Apr 26; Broccoli is a farmer's choice type | add_on wk9 Broccoli 1.00 kg = 30.00 |
| 2026-04-28 | wk9 recorded as failed | wk9 `planned` | wk9 `failed`; refund `failed` wk9 230.00 (200.00 + 30.00) on 2026-04-28; skips unchanged |
| 2026-05-19 | Range ended | — | status `finished` |

**Baseline:** `finished`, skips 1, no cancellation. wk6 `skipped`, wk9 `failed`; all other weeks `success`. Two add-ons and two refunds on one subscription (coverage #2).

### 203 · C03 · fc · biweekly · 200.00 (new), cancelled before the range

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-01-20 | Submitted | Inside the S26 window; no A25 subscription → new | subscription 203: 200.00, `planned`, skips 2 |
| 2026-02-10 | Cancelled (case A) | Status `planned`: the range starts on Feb 24 | refund `cancelled`, no week, 1200.00 (6 × 200.00) on 2026-02-10; skips → 0; status `cancelled`; `cancellation_date` 2026-02-10 |
| 2026-02-24 | Range starts | Cancelled → no deliveries are generated | — |

**Baseline:** `cancelled`, skips 0, cancelled 2026-02-10. No deliveries.

### 204 · C04 · fc · weekly · 200.00 (new), cancelled during the range with a zero refund

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-01-12 | Submitted | Inside the S26 window; new | subscription 204: 200.00, `planned`, skips 2 |
| 2026-02-24 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-04-02 | Skips wk6 (Apr 6, Easter) | Window Mar 31 to Apr 5; 2 left | wk6 `skipped`; refund `skipped` wk6 200.00 on 2026-04-02; skips 2 → 1 |
| 2026-04-07 | Add-on for wk7 (Apr 13) | Window Apr 7 to Apr 12; Lettuce is a farmer's choice type | add_on wk7 Lettuce 1.00 kg = 22.00 |
| 2026-04-09 | Skips wk7 | Window Apr 7 to Apr 12; 1 left | wk7 `skipped`; refund `skipped` wk7 222.00 (200.00 + 22.00) on 2026-04-09; skips 1 → 0 |
| 2026-04-14 | Cancelled (case B) | Status `active`. Planned deliveries after Apr 14: wk8–12 (5); 0 skips left; no add-ons on wk8–12 | min(0, 5) × 200.00 + 0 = 0 → no refund row (D20); wk8–12 `cancelled`; status `cancelled`; `cancellation_date` 2026-04-14 |

**Baseline:** `cancelled`, skips 0, cancelled 2026-04-14. wk1–5 `success`, wk6–7 `skipped`, wk8–12 `cancelled`.

### 205 · C05 · fc · weekly · 200.00 (new), cancelled during the range

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-01-15 | Submitted | Inside the S26 window; new | subscription 205: 200.00, `planned`, skips 2 |
| 2026-02-24 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-03-17 | Add-on for wk4 (Mar 23) | Window Mar 17 to Mar 22; Chinese Kale is a farmer's choice type | add_on wk4 Chinese Kale 4.50 kg = 126.00 |
| 2026-03-18 | Cancelled (case B) | Status `active`. Planned deliveries after Mar 18: wk4–12 (9); 2 skips left; add-on fee on them: 126.00 (wk4) | refund `cancelled`, no week, 526.00 (min(2, 9) × 200.00 + 126.00) on 2026-03-18; skips → 0; wk4–12 `cancelled`; status `cancelled`; `cancellation_date` 2026-03-18 |

**Baseline:** `cancelled`, skips 0, cancelled 2026-03-18. wk1–3 `success`, wk4–12 `cancelled`. The wk4 add-on sits on a cancelled delivery (the MQ2 trap, coverage #5 and #6).

### 206 · C06 · cz · weekly · 192.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2025-12-20 | Submitted | Inside the S26 window. 102 finished → renewal | subscription 206: 192.00, `planned`, skips 2; chosen: all S26 products except Pak Choi, Carrots |
| 2026-02-24 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-03-11 | Add-on for wk3 (Mar 16) | Window Mar 10 to Mar 15; Asparagus is one of the 8 chosen | add_on wk3 Asparagus 1.00 kg = 58.00 |
| 2026-04-02 | Skips wk6 (Apr 6, Easter) | Window Mar 31 to Apr 5; 2 left | wk6 `skipped`; refund `skipped` wk6 192.00 on 2026-04-02; skips 2 → 1 |
| 2026-05-19 | Range ended | — | status `finished` |

**Baseline:** `finished`, skips 1, no cancellation. wk6 `skipped`; all other weeks `success`.

### 207 · C07 · cz · weekly · 240.00 (new)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-02-01 | Submitted | Inside the S26 window; no A25 subscription → new | subscription 207: 240.00, `planned`, skips 2; chosen: all S26 products except Pak Choi, Lettuce |
| 2026-02-24 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-03-04 | Add-on for wk2 (Mar 9) | Window Mar 3 to Mar 8; Strawberries is one of the 8 chosen | add_on wk2 Strawberries 1.00 kg = 85.00 |
| 2026-04-03 | Skips wk6 (Apr 6, Easter) | Window Mar 31 to Apr 5; 2 left | wk6 `skipped`; refund `skipped` wk6 240.00 on 2026-04-03; skips 2 → 1 |
| 2026-05-19 | Range ended | — | status `finished` |

**Baseline:** `finished`, skips 1, no cancellation. wk6 `skipped`; all other weeks `success`.

### 208 · C08 · fc · biweekly · 160.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2025-12-15 | Submitted | Inside the S26 window. 103 finished → renewal | subscription 208: 160.00, `planned`, skips 2 |
| 2026-02-24 | Range starts | — | delivery wk1, 3, 5, 7, 9, 11 `planned`; status `active` |
| 2026-03-20 | Add-on for wk5 (Mar 30) | Biweekly window Mar 17 to Mar 29; Spinach is a farmer's choice type | add_on wk5 Spinach 2.00 kg = 64.00 |
| 2026-05-19 | Range ended | — | status `finished` |

**Baseline:** `finished`, skips 2, no cancellation. All six deliveries `success`.

### 211 · C11 · cz · biweekly · 240.00 (new)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-02-10 | Submitted | Inside the S26 window; no A25 subscription → new | subscription 211: 240.00, `planned`, skips 2; chosen: all S26 products except Pak Choi, Snow Peas |
| 2026-02-24 | Range starts | — | delivery wk1, 3, 5, 7, 9, 11 `planned`; status `active` |
| 2026-02-26 | Add-on for wk1 (Mar 2) | Window Feb 24 to Mar 1; Strawberries is one of the 8 chosen | add_on wk1 Strawberries 0.50 kg = 42.50 |
| 2026-03-31 | wk5 (Mar 30) recorded as failed | wk5 `planned`; it has no add-on | wk5 `failed`; refund `failed` wk5 240.00 on 2026-03-31; skips unchanged |
| 2026-05-19 | Range ended | — | status `finished` |

**Baseline:** `finished`, skips 2, no cancellation. wk5 `failed`; all other deliveries `success`.

## 4. Summer 2026 timelines

On the baseline, wk1–5 have been recorded. wk6 (Jul 6) is `planned` and waits for its result on Jul 7; wk7 and later are `planned`.

### 301 · C01 · fc · weekly · 160.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-04-20 | Submitted | Inside the Su26 window. 201 active on that day → renewal | subscription 301: 160.00, `planned`, skips 2 |
| 2026-05-26 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-07-02 | Add-on for wk6 (Jul 6) | Window Jun 30 to Jul 5; Green Beans is a Su26 farmer's choice type | add_on wk6 Green Beans 1.50 kg = 48.00 |

**Baseline:** `active`, skips 2, no cancellation. wk1–5 `success`; wk6–12 `planned`. Fixture for UC2: if wk6 is recorded as failed, the refund is 160.00 + 48.00 = 208.00.

### 302 · C02 · fc · weekly · 160.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-05-01 | Submitted | Inside the Su26 window. 202 active on that day → renewal | subscription 302: 160.00, `planned`, skips 2 |
| 2026-05-26 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-06-03 | Skips wk2 (Jun 8) | Window Jun 2 to Jun 7; 2 left | wk2 `skipped`; refund `skipped` wk2 160.00 on 2026-06-03; skips 2 → 1 |
| 2026-06-17 | Skips wk4 (Jun 22) | Window Jun 16 to Jun 21; 1 left | wk4 `skipped`; refund `skipped` wk4 160.00 on 2026-06-17; skips 1 → 0 |

**Baseline:** `active`, skips 0, no cancellation. wk1, 3, 5 `success`; wk2, 4 `skipped`; wk6–12 `planned`.

### 304 · C08 · fc · biweekly · 160.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-04-15 | Submitted | Inside the Su26 window. 208 active on that day → renewal | subscription 304: 160.00, `planned`, skips 2 |
| 2026-05-26 | Range starts | — | delivery wk1, 3, 5, 7, 9, 11 `planned`; status `active` |
| 2026-07-01 | Add-on for wk7 (Jul 13) | Biweekly window Jun 30 to Jul 12, already open before the baseline; Tomatoes is a Su26 farmer's choice type | add_on wk7 Tomatoes 2.00 kg = 50.00 |

**Baseline:** `active`, skips 2, no cancellation. wk1, 3, 5 `success`; wk7, 9, 11 `planned`. Fixture for UC4 case B: cancelling on Jul 7 refunds 2 × 160.00 + 50.00 = 370.00.

### 305 · C10 · cz · biweekly · 192.00 (renewal)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-04-28 | Submitted | Inside the Su26 window. 210 active on that day → renewal | subscription 305: 192.00, `planned`, skips 2; chosen: all Su26 products except Watermelon, Okra |
| 2026-05-26 | Range starts | — | delivery wk1, 3, 5, 7, 9, 11 `planned`; status `active` |
| 2026-06-10 | Skips wk3 (Jun 15) | Biweekly window Jun 2 to Jun 14; 2 left | wk3 `skipped`; refund `skipped` wk3 192.00 on 2026-06-10; skips 2 → 1 |

**Baseline:** `active`, skips 1, no cancellation. wk1, 5 `success`; wk3 `skipped`; wk7, 9, 11 `planned`.

### 306 · C12 · fc · biweekly · 200.00 (new), cancelled on a delivery day

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-04-25 | Submitted | Inside the Su26 window; no S26 subscription → new | subscription 306: 200.00, `planned`, skips 2 |
| 2026-05-26 | Range starts | — | delivery wk1, 3, 5, 7, 9, 11 `planned`; status `active` |
| 2026-06-15 | Cancelled (case B) on wk3's delivery day | Status `active`. Planned deliveries after Jun 15: wk5, 7, 9, 11 (4); 2 left; no add-ons | refund `cancelled`, no week, 400.00 (min(2, 4) × 200.00) on 2026-06-15; skips → 0; wk5, 7, 9, 11 `cancelled`; wk3 stays `planned` (BR10); status `cancelled`; `cancellation_date` 2026-06-15 |
| 2026-06-16 | wk3 recorded | wk3 `planned` | wk3 `success` |

**Baseline:** `cancelled`, skips 0, cancelled 2026-06-15. wk1, 3 `success`; wk5, 7, 9, 11 `cancelled`.

### 307 · C15 · fc · weekly · 200.00 (new), cancelled after renewing into A26

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-03-20 | Submitted | Inside the Su26 window; no S26 subscription → new | subscription 307: 200.00, `planned`, skips 2 |
| 2026-05-26 | Range starts | — | delivery wk1–12 `planned`; status `active` |
| 2026-06-05 | C15 submits A26 subscription 403 | 307 is active → 403 is a renewal at 160.00 (Section 5) | — (no change to 307) |
| 2026-06-24 | Cancelled (case B) | Status `active`. Planned deliveries after Jun 24: wk5–12 (8); 2 left; no add-ons | refund `cancelled`, no week, 400.00 (min(2, 8) × 200.00) on 2026-06-24; skips → 0; wk5–12 `cancelled`; status `cancelled`; `cancellation_date` 2026-06-24 |

**Baseline:** `cancelled`, skips 0, cancelled 2026-06-24. wk1–4 `success`; wk5–12 `cancelled`.

## 5. Autumn 2026 timeline with a story

### 403 · C15 · fc · weekly · 160.00 (renewal kept after the previous subscription is cancelled)

| Date | Event | Check | Rows written or changed |
|---|---|---|---|
| 2026-06-05 | Submitted | Inside the A26 window. Previous subscribable season Su26: 307 active on that day → renewal (D24) | subscription 403: 160.00, `planned`, skips 2 |
| 2026-06-24 | 307 cancelled | The renewal was decided on Jun 5, so 403 keeps 160.00 (D24, coverage #13) | — (no change to 403) |

**Baseline:** `planned`, skips 2, no cancellation, no deliveries. The renewal-price seed check must pass for 403, because 307's `cancellation_date` (2026-06-24) is later than 403's `submission_date` (2026-06-05).

## 6. Registers for `sql/02_data.sql`

### 6.1 Refunds (15 rows, in date order; suggested `refund_id` = #)

| # | `refund_date` | Sub | `type` | `week_no` | `amount` |
|---|---|---|---|---|---|
| 1 | 2026-02-10 | 203 | `cancelled` | NULL | 1200.00 |
| 2 | 2026-03-18 | 205 | `cancelled` | NULL | 526.00 |
| 3 | 2026-03-31 | 211 | `failed` | 5 | 240.00 |
| 4 | 2026-04-01 | 201 | `skipped` | 6 | 160.00 |
| 5 | 2026-04-01 | 202 | `skipped` | 6 | 200.00 |
| 6 | 2026-04-02 | 204 | `skipped` | 6 | 200.00 |
| 7 | 2026-04-02 | 206 | `skipped` | 6 | 192.00 |
| 8 | 2026-04-03 | 207 | `skipped` | 6 | 240.00 |
| 9 | 2026-04-09 | 204 | `skipped` | 7 | 222.00 |
| 10 | 2026-04-28 | 202 | `failed` | 9 | 230.00 |
| 11 | 2026-06-03 | 302 | `skipped` | 2 | 160.00 |
| 12 | 2026-06-10 | 305 | `skipped` | 3 | 192.00 |
| 13 | 2026-06-15 | 306 | `cancelled` | NULL | 400.00 |
| 14 | 2026-06-17 | 302 | `skipped` | 4 | 160.00 |
| 15 | 2026-06-24 | 307 | `cancelled` | NULL | 400.00 |

### 6.2 Add-ons (11 rows)

| Sub | `week_no` | Product | `weight` | Fee | Delivery status on the baseline |
|---|---|---|---|---|---|
| 211 | 1 | Strawberries | 0.50 | 42.50 | `success` |
| 207 | 2 | Strawberries | 1.00 | 85.00 | `success` |
| 202 | 3 | Spinach | 1.50 | 48.00 | `success` |
| 206 | 3 | Asparagus | 1.00 | 58.00 | `success` |
| 205 | 4 | Chinese Kale | 4.50 | 126.00 | `cancelled` |
| 208 | 5 | Spinach | 2.00 | 64.00 | `success` |
| 204 | 7 | Lettuce | 1.00 | 22.00 | `skipped` |
| 202 | 9 | Broccoli | 1.00 | 30.00 | `failed` |
| 201 | 10 | Choy Sum | 1.00 | 35.00 | `success` |
| 301 | 6 | Green Beans | 1.50 | 48.00 | `planned` |
| 304 | 7 | Tomatoes | 2.00 | 50.00 | `planned` |

### 6.3 Deliveries that are not `success` on the baseline

| Status | Count | Deliveries |
|---|---|---|
| `skipped` | 9 | 201 wk6; 202 wk6; 204 wk6, wk7; 206 wk6; 207 wk6; 302 wk2, wk4; 305 wk3 |
| `failed` | 2 | 202 wk9; 211 wk5 |
| `cancelled` | 26 | 204 wk8–12; 205 wk4–12; 306 wk5, 7, 9, 11; 307 wk5–12 |
| `planned` | 27 | 301 wk6–12; 302 wk6–12; 303 wk6–12; 304 wk7, 9, 11; 305 wk7, 9, 11 |
| `success` | 134 | All other deliveries |
| Total | 198 | A25 36, S26 96, Su26 66 |

### 6.4 Subscription state on the baseline

| Status | Subscriptions | `remaining_refundable_skip` | `cancellation_date` |
|---|---|---|---|
| `finished` | 101–104, 201, 202, 206–211 | 2, except 201, 202, 206, 207 = 1 | NULL |
| `active` | 301–305 | 301, 303, 304 = 2; 305 = 1; 302 = 0 | NULL |
| `planned` | 401–403 | 2 | NULL |
| `cancelled` | 203, 204, 205, 306, 307 | 0 | 203: 2026-02-10; 204: 2026-04-14; 205: 2026-03-18; 306: 2026-06-15; 307: 2026-06-24 |
