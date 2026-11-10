# Seed Cast (roadmap 2.4)

Internal working file: do not put it in the submission ZIP. The dated events of every subscription are in `seed_timelines.md` (roadmap 2.5); this file gives the overview.

**Abbreviations.** A25 = Autumn 2025, S26 = Spring 2026, Su26 = Summer 2026, A26 = Autumn 2026. fc = `'farmer''s choice'`, cz = `'customizable'`. W = weekly, B = biweekly. The number after the frequency is `allocated_cost`. Numbers in brackets such as (201) are the suggested `subscription_id` values (roadmap 2.7: A25 101–, S26 201–, Su26 301–, A26 401–).

**Status** is the status on the baseline date, the start of Tuesday 2026-07-07 (D04). "Plain" means every recorded delivery is `success`, with no add-on and no refund.

**Easter skip.** S26 week 6 is Monday 2026-04-06 (Easter Monday). Its change window for weekly subscriptions runs from 2026-03-31 to 2026-04-05. Every S26 weekly subscription that is not cancelled by then skips this week (coverage #7).

## 1. Cast

| 客户 | 设定 | 订阅轨迹 | 覆盖 |
|---|---|---|---|
| C01 | Loyal customer, renews every season | A25 fc W 200 (101, finished, plain) → S26 fc W 160 (201, finished: Easter skip, wk10 add-on) → Su26 fc W 160 (301, active: wk6 add-on) → A26 fc W 160 (401, planned) | #1, #6, #7, #10, #12, #15, #16, #18 |
| C02 | Busy spring, two summer skips | S26 fc W 200 (202, finished: 2 add-ons, Easter skip, wk9 failed) → Su26 fc W 160 (302, active: skips wk2 and wk4, 0 refundable skips left) | #1, #2, #4, #5, #6, #7, #10, #16, #19 |
| C03 | Changed mind before spring started | S26 fc B 200 (203, cancelled 2026-02-10 before the range: case A, refund 1200) | #1, #4 |
| C04 | Used both skips, then quit with nothing back | S26 fc W 200 (204, cancelled 2026-04-14: case B, refund 0, so no refund row) | #4, #5, #7, #8 |
| C05 | Quit spring early, came back in summer at full price | S26 fc W 200 (205, cancelled 2026-03-18: case B, refund 526) → Su26 fc W 200 (303, active, plain) | #4, #5, #8, #11, #16, #19 |
| C06 | Skips a season, returns at full price | A25 cz W 240 (102, finished, plain) → S26 cz W 192 (206, finished: wk3 add-on, Easter skip) → no Su26 → A26 cz W 240 (402, planned) | #1, #6, #7, #9, #10, #12, #18 |
| C07 | Easter holiday | S26 cz W 240 (207, finished: wk2 add-on, Easter skip) | #1, #6, #7, #9, #10 |
| C08 | Biweekly renewer | A25 fc B 200 (103, finished, plain) → S26 fc B 160 (208, finished: wk5 add-on) → Su26 fc B 160 (304, active: wk7 add-on) | #1, #6, #10, #16, #17, #19 |
| C09 | Plain spring subscriber, does not renew | S26 fc B 200 (209, finished, plain) | #1, #3, #10 |
| C10 | The only customizable renewer | A25 cz B 240 (104, finished, plain) → S26 cz B 192 (210, finished, plain) → Su26 cz B 192 (305, active: wk3 skip, 1 refundable skip left) | #1, #9, #10, #16, #19 |
| C11 | One failed box | S26 cz B 240 (211, finished: wk1 add-on, wk5 failed) | #1, #4, #6, #9, #10 |
| C12 | Summer only, cancelled on a delivery day | Su26 fc B 200 (306, cancelled 2026-06-15, the Monday of wk3: case B, refund 400) | #11, #19, #21 |
| C13 | Registered, never subscribed | — | #14, #19 |
| C14 | Registered, never subscribed | — | #14 |
| C15 | Renewed for autumn, then quit summer; keeps the discount (D24) | Su26 fc W 200 (307, cancelled 2026-06-24: case B, refund 400) → A26 fc W 160 (403, planned; submitted 2026-06-05 while 307 was active) | #11, #13, #18 |

## 2. Event timelines

See `seed_timelines.md`. It also holds the registers of refunds, add-ons and delivery statuses that `sql/02_data.sql` is written from.

## 3. Chosen products

Each customizable subscription chooses 8 of its season's 10 products, so only the 2 excluded products are listed.

| Sub | Season | Excluded (not chosen) |
|---|---|---|
| 102 (C06) | A25 | Pumpkin, Winter Melon |
| 104 (C10) | A25 | Pumpkin, Winter Melon |
| 206 (C06) | S26 | Pak Choi, Carrots |
| 207 (C07) | S26 | Pak Choi, Lettuce |
| 210 (C10) | S26 | Pak Choi, Carrots |
| 211 (C11) | S26 | Pak Choi, Snow Peas |
| 305 (C10) | Su26 | Watermelon, Okra |
| 402 (C06) | A26 | White Radish, Taro |

The S26 customizable add-ons (Asparagus for 206, Strawberries for 207 and 211) are inside each subscription's chosen 8 (I14). No S26 customizable subscription is cancelled, so MQ4 does not have to decide whether a cancelled subscription's choices count.

## 4. Coverage check (roadmap 2.3)

| # | Covered by |
|---|---|
| 1 | fc W renewal 201; fc W new 202, 204, 205; fc B renewal 208; fc B new 209 (and 203); cz W renewal 206; cz W new 207; cz B renewal 210; cz B new 211 |
| 2 | 202: 2 add-ons (78.00) and 2 refunds (430.00). Joining both at once gives 4 rows, so a wrong query reports 156.00 and 860.00 |
| 3 | 209 |
| 4 | `skipped`: 201, 202, 204 (×2), 206, 207. `failed`: 202, 211. `cancelled`: 203 (case A, 1200.00), 205 (case B, 526.00). Case B with refund 0 and no row: 204 |
| 5 | Add-on on a skipped delivery: 204 wk7 Lettuce. On a failed one: 202 wk9 Broccoli. On a cancelled one: 205 wk4 Chinese Kale |
| 6 | fc: Spinach 112.00 (202 wk3 48.00 + 208 wk5 64.00) ahead of Choy Sum 35.00. cz: Strawberries 127.50 (207 85.00 + 211 42.50) ahead of Asparagus 58.00. Trap: Chinese Kale 126.00 sits on a cancelled delivery; if Q02 wrongly includes it, it overtakes Spinach |
| 7 | S26 wk6: the non-cancelled deliveries are 201, 202, 204, 206 and 207, all `skipped`. 205's wk6 is `cancelled`, and biweekly subscriptions have no wk6. Attempted = 0, so the failure rate is NULL |
| 8 | 204 wk8–12; 205 wk4–12 |
| 9 | Pak Choi (a farmer's choice type) is chosen by 0 of 4. Asparagus and Strawberries (not farmer's choice types) are chosen by 4 of 4 |
| 10 | fc, not cancelled: 201, 202, 208, 209; renewed 201, 202, 208 = 3/4 = 75% (HAVING rejects). cz, not cancelled: 206, 207, 210, 211; renewed 210 = 1/4 = 25% (HAVING keeps) |
| 11 | C05: S26 cancelled, then Su26 at 200, so not in the MQ5 denominator. C12 and C15: Su26 only |
| 12 | Chain: C01 101 → 201 → 301 → 401. Return after a gap: C06 102 → 206 → (no Su26) → 402 at 240 |
| 13 | C15: 403 submitted on 2026-06-05 at 160 while 307 was active; 307 cancelled on 2026-06-24; 403 keeps 160 (D24) |
| 14 | C13, C14 |
| 15 | Su26 wk6 `planned`: 301, 302, 303; 301 carries a 48.00 add-on |
| 16 | Remaining skips 2: 301, 303, 304. 1: 305. 0: 302 |
| 17 | 304 wk7 Tomatoes 2.00 kg (50.00) |
| 18 | 401 and 403 (fc), 402 (cz with 8 chosen) |
| 19 | Su26 active, no A26: C02, C05, C08, C10. Su26 cancelled: C12. No subscription at all: C13 |
| 20 | Finished: 101–104, 201, 202, 206–211 |
| 21 | 306: cancelled on its wk3 delivery day; wk3 stays planned and is recorded as `success` on 06-16 |
| 22 | `cancellation_date` NULL on every non-cancelled subscription; `refund.week_no` NULL on the `cancelled` refunds of 203, 205, 306 and 307 |

## 5. Test fixtures on the baseline (for Phase 7; each test starts from fresh seed data)

| Test idea | Fixture | Expected |
|---|---|---|
| UC1 renewal into A26 | C05 (303 active) | 160 for fc, 192 for cz |
| UC1 full price | C12 (306 cancelled); C13 (no subscription) | 200 for fc, 240 for cz |
| UC1 duplicate season | C01, C06 or C15 enrols in A26 again | 1062 |
| UC2 failed delivery with add-on | 301 wk6 | wk6 `failed`; refund 160 + 48 = 208.00 (same figures as the BR7 test example) |
| UC3 first skip | 303 wk7 | refund 200.00; skips 2 → 1 |
| UC3 last refundable skip | 305 wk7 | refund 192.00; skips 1 → 0 |
| UC3 skip with none left | 302 wk7 | wk7 `skipped`; no refund row; skips stay 0 |
| UC4 case B | 303 | 2 × 200 = 400.00; wk7–12 `cancelled`; wk6 (07-06) stays `planned` |
| UC4 case B with add-on | 304 | 2 × 160 + 50 = 370.00; wk7, 9, 11 `cancelled` |
| UC4 case A | 401; 402; 403 | 12 × 160 = 1920.00; 12 × 240 = 2880.00; 12 × 160 = 1920.00 |
| Cancel a finished subscription | e.g. 209 | 0 rows |
| UC5 product outside the plan | 305 adds Watermelon (not chosen) | 0 rows |

## 6. Expected baseline row counts

| Table | Rows | Breakdown |
|---|---|---|
| season | 4 | — |
| product | 40 | 10 per season, 6 of them farmer's choice |
| customer | 15 | 13 with subscriptions, 2 without |
| subscription | 25 | A25 4, S26 11, Su26 7, A26 3 |
| chosen_products | 64 | 8 customizable subscriptions × 8 |
| delivery | 198 | A25 36, S26 96, Su26 66, A26 0 |
| add_on | 11 | S26 9, Su26 2 |
| refund | 15 | S26 10, Su26 5 |

## 7. Changes from the first draft

- **C02:** The draft had Su26 fc W 160 with no S26 subscription, but 160 is a renewal price (BR4). Coverage #2 also has to be in S26, because MQ1 covers Spring 2026 only. C02 is now the busy S26 subscription and renews into Su26.
- **C03:** Moved from A26 to S26. MQ1 needs both cancellation cases in Spring 2026, and the A26 planned subscriptions are kept as the UC4 case A fixtures.
- **C04:** Kept, with dates added. The wk7 add-on is 1.00 kg Lettuce = 22.00, because the price comes from weight × price per kg.
- **C05:** Kept, now specified as case B with a refund row. Its cancelled wk4 add-on is the MQ2 trap.
- **C06:** Changed from fc to cz. With fc, the S26 fc subscriptions that were not cancelled would be 5 with 3 renewals, exactly 60%. As cz, it also provides the A26 customizable planned subscription (#18).
- **C07:** Kept, with a Strawberries add-on added for MQ2.
- **C08–C15:** New. C15 was added to cover #13 after D24. It uses Su26 and A26, so the Spring 2026 results of MQ1–MQ5 do not change.

## 8. Adding more rows later

The cast is the minimum that covers every requirement. Extra "filler" subscriptions must not break it:

- A new S26 weekly subscription must also take the Easter skip, or #7 fails.
- Any new S26 subscription that is not cancelled changes the MQ5 rates. Keep fc ≥ 60% and cz < 60%, and avoid exactly 60%.
- A new S26 customizable subscription must exclude Pak Choi, or #9 fails.
- An add-on on a successful S26 delivery may change the top products of MQ2.
- Safest filler: plain A25 subscriptions, or plain Su26 biweekly fc subscriptions.
