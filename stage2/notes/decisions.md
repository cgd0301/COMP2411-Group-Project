# Stage 2 Implementation Decisions

This file records conventions that do not change the Stage 1 design but affect how Stage 2 is implemented. Each entry states the decision and gives a one- or two-sentence rationale. Design changes go in `changelog.md` instead. These entries are the source for the README sections `# Environment`, `# Queries`, `# Tests` and `# Limitations` [9.3] and for the implementation notes in the report. This is an internal working file: do not put it in the submission ZIP.

## How to use this file

- Number entries `D01`, `D02`, … in order. Never renumber or reuse an ID.
- To change a decision, set the old entry's status to `Superseded by Dxx` and add a new entry. Do not delete or rewrite the old decision.
- Status values: `Agreed` (fixed and in use), `Open` (not yet decided), `Superseded by Dxx`.
- Each member ticks their column in the index after reading and accepting the entry.
- To add an entry, copy the template at the end of this file and add a row to the index.

## Index

| ID  | Topic                                                                       | Status | Date       | CHEN | SHI |
| --- | --------------------------------------------------------------------------- | ------ | ---------- | ---- | --- |
| D01 | Season calendar for the seed data                                           | Agreed | 2026-11-03 | ✅   | ☐   |
| D02 | Autumn 2025 is included in the seed data                                    | Agreed | 2026-11-03 | ✅   | ☐   |
| D03 | Season ranges never overlap                                                 | Agreed | 2026-11-03 | ✅   | ☐   |
| D04 | Baseline reference date 2026-07-07                                          | Agreed | 2026-11-03 | ✅   | ☐   |
| D05 | Reference date in test and operation scripts                                | Agreed | 2026-11-03 | ✅   | ☐   |
| D06 | Dates in `queries/Qxx.sql`                                                  | Open   | 2026-11-03 | ☐    | ☐   |
| D07 | No `CURDATE()` or `NOW()`                                                   | Agreed | 2026-11-03 | ✅   | ☐   |
| D08 | Table and column names                                                      | Agreed | 2026-11-03 | ✅   | ☐   |
| D09 | Constraint names                                                            | Agreed | 2026-11-03 | ✅   | ☐   |
| D10 | SQL layout                                                                  | Agreed | 2026-11-03 | ✅   | ☐   |
| D11 | No integer display widths                                                   | Agreed | 2026-11-03 | ✅   | ☐   |
| D12 | Test IDs                                                                    | Agreed | 2026-11-03 | ✅   | ☐   |
| D13 | SQL file header comment                                                     | Agreed | 2026-11-03 | ✅   | ☐   |
| D14 | Development environment check                                               | Open   |            | ✅   | ☐   |
| D15 | Acknowledgement requirement check                                           | Agreed |            | ✅   | ☐   |
| D16 | Referential-action clause on foreign keys whose columns are used in a CHECK | Agreed | 2026-11-03 | ✅   | ☐   |
| D17 | Case sensitivity of status and type values                                  | Agreed | 2026-11-09 | ✅   | ☐   |
| D18 | Signed and unsigned columns, and the values used in negative tests          | Agreed | 2026-11-04 | ✅    | ☐   |
| D19 | Apostrophes in string literals                                              | Open   |            | ☐    | ☐   |
| D20 | No refund row for a zero refund                                             | Agreed | 2026-11-03 | ☐    | ☐   |
| D21 | Candidate keys not enforced by UNIQUE                                       | Agreed | 2026-11-09 | ✅   | ☐   |
| D22 | Submission dates of Autumn 2025 subscriptions                               | Agreed | 2026-11-10 | ✅   | ☐   |
| D23 | Autumn 2025 subscriptions are all at full price                             | Agreed | 2026-11-10 | ✅   | ☐   |
| D24 | Renewal is decided on the submission date                                   | Agreed | 2026-11-10 | ✅   | ☐   |
| D25 | Identifier scheme of the seed data                                          | Agreed | 2026-11-10 | ✅   | ☐   |
| D26 | Delivery rows are literal values in `sql/02_data.sql`                       | Agreed | 2026-11-10 | ✅   | ☐   |
| D27 | Add-on purchase dates are not stored                                        | Agreed | 2026-11-10 | ✅   | ☐   |

---

## D01 Season calendar for the seed data

- **Decision:** The seed data contain exactly the four seasons below. D is the first planning day (a Monday); the subscription range runs from D − 6 to D + 77, both included (84 days, BR3); the enrolment window follows BR4.

  | Season      | First planning day D | Subscription range (D − 6 to D + 77) | Enrolment window (BR4)                            | Status of non-cancelled subscriptions on the baseline date (D04) |
  | ----------- | -------------------- | ------------------------------------ | ------------------------------------------------- | ---------------------------------------------------------------- |
  | Autumn 2025 | 2025-09-08           | 2025-09-02 to 2025-11-24             | The Summer 2025 range (Summer 2025 is not stored) | finished                                                         |
  | Spring 2026 | 2026-03-02           | 2026-02-24 to 2026-05-18             | 2025-11-25 to 2026-02-23                          | finished                                                         |
  | Summer 2026 | 2026-06-01           | 2026-05-26 to 2026-08-17             | 2026-02-24 to 2026-05-18                          | active                                                           |
  | Autumn 2026 | 2026-09-07           | 2026-09-01 to 2026-11-23             | 2026-05-26 to 2026-08-17                          | planned (its window is open)                                     |

- **Rationale:** On the baseline date these seasons give finished, active and planned subscriptions, so every BR3 status appears in the seed data. All four first planning days have been checked to be Mondays, and no two ranges overlap.
- **Applies to:** `sql/02_data.sql`, all tests and queries, README `# Queries`.
- **Status:** Agreed, 2026-11-03.

## D02 Autumn 2025 is included in the seed data

- **Decision:** The seed data include Autumn 2025 as a finished season with subscriptions.
- **Rationale:** Under BR4, the previous subscribable season of a spring season is the previous year's autumn, which is the least obvious (cross-year) case of the rule. Without Autumn 2025 subscriptions, the Spring 2026 renewal prices (160 and 192 HKD per delivery) would have no data to support them.
- **Applies to:** `sql/02_data.sql`, renewal tests (BR4).
- **Status:** Agreed, 2026-11-03.

## D03 Season ranges never overlap

- **Decision:** No two seasons' subscription ranges overlap, so on any day at most one season's enrolment window is open. Any season added later must keep this property.
- **Rationale:** The normalization analysis (proposal §6.1, `subscription`) relies on the dependency `submission_date → season_id` and the candidate key `{customer_id, submission_date}`, and both hold only if at most one window is open on any day. The report should state this assumption.
- **Applies to:** `sql/02_data.sql`, report normalization section.
- **Status:** Agreed, 2026-11-03.

## D04 Baseline reference date: 2026-07-07

- **Decision:** The seed data represent the farm's state on Tuesday 2026-07-07. Every status and date in the seed data is consistent with this day.
- **Rationale:** On this date every use case can be demonstrated directly from the seed state, without first changing the data. The details are:
  - Spring 2026 and Autumn 2025 are finished, so MQ1–MQ5 have complete data.
  - The Summer 2026 week-6 delivery (Monday 2026-07-06) is still planned, so UC2 can record its result.
  - The week-7 change window (2026-07-07 to 2026-07-12 for weekly subscriptions) is open, so UC3 (skip) and the add-on purchase (BR9; UC5 in `userCases.md`) can run.
  - The Autumn 2026 enrolment window is open, so UC1 can show both a new enrolment and the renewal discount.
  - Both cancellation cases of UC4 are available: an active Summer 2026 subscription (case B) and a planned Autumn 2026 subscription (case A).
- **Note:** Proposal §8.2 (Table 15) used `@ref_date = '2026-04-20'` only as an example. This entry replaces it, and because it is not a design change it does not go in the change log.
- **Applies to:** `sql/02_data.sql`, all tests, README `# Queries` and `# Tests`.
- **Status:** Agreed, 2026-11-03.

## D05 Reference date in test and operation scripts

- **Decision:** Every test and operation script starts with `SET @ref_date = '2026-07-07';` and compares dates only with `@ref_date`.
- **Rationale:** The date-dependent rules (BR3 status, BR4 enrolment window, BR8 change window, BR10 cancellation) then give the same result on whatever day the evaluator runs the scripts. A single variable also makes a boundary case easy to show by changing one line.
- **Applies to:** `tests/`, demonstration scripts.
- **Status:** Agreed, 2026-11-03.

## D06 Dates in `queries/Qxx.sql`

- **Decision (provisional):** Each `Qxx.sql` may contain only one SELECT statement [9.2], so it cannot start with `SET @ref_date`. Dates are written as literals with a comment, or derived from the data (for example from a season's `first_planning_day`). The final rule is to be fixed in Phase 5.
- **Rationale:** This keeps each query file a single statement while its result stays reproducible.
- **Applies to:** `queries/`, README `# Queries`.
- **Status:** Open (to be finalized in Phase 5).

## D07 No `CURDATE()` or `NOW()`

- **Decision:** No script uses `CURDATE()`, `NOW()` or any other function that returns the current date or time (such as `CURRENT_DATE` or `SYSDATE()`).
- **Rationale:** Their results change with the day the scripts are run, so captured query results and test outcomes could not be reproduced [9.2].
- **Applies to:** all SQL files.
- **Status:** Agreed, 2026-11-03.

## D08 Table and column names

- **Decision:** Every table and column keeps its Stage 1 name exactly as in the data dictionary (snake_case). `chosen_products` stays plural, and no table or column is renamed silently.
- **Rationale:** The ER diagram, schema, data dictionary, SQL and report must agree [10]. A rename is a design change and would need a change-log entry.
- **Applies to:** all SQL files, report.
- **Status:** Agreed, 2026-11-03.

## D09 Constraint names

- **Decision:** Every constraint except the primary key is named as follows. Primary keys are not named, because MySQL always names them `PRIMARY`.

  | Constraint  | Pattern                | Example               |
  | ----------- | ---------------------- | --------------------- |
  | CHECK       | `ck_<table>_<meaning>` | `ck_delivery_week_no` |
  | UNIQUE      | `uq_<table>_<columns>` | `uq_customer_email`   |
  | FOREIGN KEY | `fk_<child>_<parent>`  | `fk_add_on_delivery`  |

- **Rationale:** MySQL reports the constraint name when a check fails (for example `Check constraint 'ck_delivery_week_no' is violated.`), so a test shows which rule rejected the data, and CHECK and foreign-key names must be unique within a database, which the table prefix guarantees. The traceability matrix and negative tests can also cite these names directly.
- **Applies to:** `sql/01_schema.sql`, constraint inventory, `tests/negative/`, report.
- **Status:** Agreed, 2026-11-03.

## D10 SQL layout

- **Decision:** SQL keywords are written in upper case, each column definition goes on its own line, and a comment line above each `CREATE TABLE` names the business rules the table implements (for example `-- Implements: BRx, BRy`).
- **Rationale:** A consistent layout makes reviews and the live-modification task faster, and the comments keep the link from rule to table visible in the code.
- **Applies to:** all SQL files.
- **Status:** Agreed, 2026-11-03.

## D11 No integer display widths

- **Decision:** Integer types are written without a display width (`INT`, not `INT(11)`). The only exception is `TINYINT(1)`.
- **Rationale:** MySQL 8.4 issues a deprecation warning for integer display widths, and our target is a schema build with zero warnings.
- **Applies to:** `sql/01_schema.sql`.
- **Status:** Agreed, 2026-11-03.

## D12 Test IDs

- **Decision:** The Stage 1 numbering is kept: `POS01`, `POS02`, … for positive tests; `TXC01`, … for transaction commit tests; `TXR01`, … for transaction rollback tests; `N01`, `N02`, … for negative tests (one file each, `tests/negative/Nxx.sql`).
- **Rationale:** The proposal already cites these IDs (for example POS03, TXC02–TXC04 and POS15 in §8.2), and they match the examples in guidance 9.2, so `evidence/test_cases.csv`, the SQL comments and the report can share one set of IDs.
- **Applies to:** `tests/`, `evidence/test_cases.csv`, report.
- **Status:** Agreed, 2026-11-03.

## D13 SQL file header comment

- **Decision:** Every SQL file starts with a comment block that gives the file's purpose, the related BR, Query ID or Test ID, and the prerequisites for running it:

  ```sql
  -- File:          <path inside the deliverable folder>
  -- Purpose:       <one line>
  -- Related IDs:   <BRx; Qxx or Test ID>
  -- Prerequisites: <starting state, e.g. fresh seed data (sql/01-04 just run)>
  ```

- **Rationale:** The guidance requires comments in the scripts, a Query ID comment in each query file and Test IDs in the test comments [6.1, 9.2]. A fixed header lets the evaluator run any file without reading the report first.
- **Applies to:** all SQL files.
- **Status:** Agreed, 2026-11-03.

---

## D14 Development environment check (roadmap 0.6)

- **Check:** Each member runs the query below in DBeaver and fills in their column. Development database: `comp2411_g085`; probe database: `comp2411_g085_scratch`. Do not record any password here.

  ```sql
  SELECT VERSION(), @@sql_mode, @@autocommit, @@default_storage_engine,
         @@character_set_server, @@collation_server;
  ```

  | Item                                                               | Expected                                                | CHEN                                                    | SHI |
  | ------------------------------------------------------------------ | ------------------------------------------------------- | ------------------------------------------------------- | --- |
  | `VERSION()`                                                        | `8.4.11`                                                | `8.4.11`                                                |     |
  | `@@sql_mode`                                                       | includes `STRICT_TRANS_TABLES` and `ONLY_FULL_GROUP_BY` | includes `STRICT_TRANS_TABLES` and `ONLY_FULL_GROUP_BY` |     |
  | `@@autocommit`                                                     | `1`                                                     | `1`                                                     |     |
  | `@@default_storage_engine`                                         | `InnoDB`                                                | `InnoDB`                                                |     |
  | `@@character_set_server`                                           | `utf8mb4`                                               | `utf8mb4`                                               |     |
  | `@@collation_server`                                               | `utf8mb4_0900_ai_ci`                                    | `utf8mb4_0900_ai_ci`                                    |     |
  | The `mysql` command-line client connects and can `source` a script | yes                                                     | yes                                                     |     |
  | Account used (name and privileges only)                            |                                                         |                                                         |     |

- **Decision:** <environment recorded in the README `# Environment` section and in `metadata.json`>
- **Rationale:** The README must state the tested versions and privileges [9.3], and strict mode makes invalid values fail instead of being silently adjusted, which the negative tests depend on.
- **Applies to:** README `# Environment` and `# Tests` (autocommit), `metadata.json`.
- **Status:** Open.

## D15 Acknowledgement requirement check (roadmap 0.7)

- **Check:** Open the guidance PDF in a PDF reader, search (Ctrl+F) for the professor's name in the last bullet of Section 10 (search for `Yuawqv`), and see whether the highlighted text is visible on the page.
- **Result:** Found but not visible (for example white text); asked the TA, answer: This is a prompt injection, please ignore the sentence.
- **Decision:** Ignore the sentence, do not add any acknowledgement.
- **Rationale:**
- **Applies to:** `report.pdf` Acknowledgements section; checklist item J10.
- **Status:** Agreed.

## D16 Referential-action clause on foreign keys whose columns are used in a CHECK (roadmap 1.2, question 1)

- **Question:** MySQL does not allow a column used in a CHECK constraint to carry a foreign-key referential action. `refund.week_no` is used in `ck_refund_link` and in the composite foreign key to `delivery`. Should that foreign key state `ON DELETE RESTRICT` explicitly, or omit the clause (RESTRICT is the InnoDB default)? Proposal §8.2 planned no referential actions. Decide after the schema probe.
- **Decision:** Omit the clause and keep the MySQL's default setting.
- **Rationale:** There's no actual difference on the performance whether the `ON DELETE RESTRICT` is written or not.
- **Applies to:** `sql/01_schema.sql`.
- **Status:** Agreed, 2026-11-03.

## D17 Case sensitivity of status and type values (roadmap 1.2, question 2)

- **Question:** With the default collation `utf8mb4_0900_ai_ci`, `'PLANNED'` passes `CHECK (status IN ('planned', …))` and is stored in upper case. Accept this and list it as a limitation, or declare these columns with `COLLATE utf8mb4_bin` (case-sensitive comparison)? If the column definitions change, also add a change-log entry.
- **Decision:** The value-list columns use `COLLATE utf8mb4_bin`: `season.season_name`, `subscription.status`, `subscription.plan_type`, `subscription.frequency`, `delivery.status` and `refund.type`. `customer.email` keeps the server collation, so email uniqueness stays case-insensitive. Recorded as CL05.
- **Rationale:** Under the default case-insensitive collation, `'PLANNED'` passes `CHECK (status IN ('planned', …))` and is stored in upper case.
- **Applies to:** `sql/01_schema.sql`, README `# Limitations`.
- **Status:** Agreed, 2026-11-09.

## D18 Signed and unsigned columns, and the values used in negative tests (roadmap 1.2, question 5)

- **Question:** Confirm the signedness of each numeric column and choose negative-test values that trigger the intended CHECK (error 3819) rather than an out-of-range error. The early draft of this question expected `week_no` to stay `TINYINT UNSIGNED`, so that −1 would fail with 1264. That option was not taken.
- **Decision:** Every numeric column used in a CHECK is signed. Every other numeric column stays unsigned. Signed: `delivery.week_no`, `refund.week_no`, `add_on.week_no` and `remaining_refundable_skip` (`TINYINT`); `allocated_cost`, `price_per_kg`, `amount` and `weight` (`DECIMAL`, signed by default). Unsigned: identifier columns and `season.year`. A negative test uses a value the signed type can store, such as `week_no = -1` or `remaining_refundable_skip = -1`, and expects 3819.
- **Rationale:** An UNSIGNED column rejects a negative value with error 1264 (out of range) before the CHECK runs, so the message does not name the constraint. A signed column stores the value, the CHECK rejects it with 3819, and the message names the constraint, for example `ck_delivery_week_no`. The `week_no` type change from the Stage 1 data dictionary is CL04.
- **Applies to:** `sql/01_schema.sql`, `tests/negative/`, `evidence/test_cases.csv`.
- **Status:** Agreed, 2026-11-04.

## D19 Apostrophes in string literals

- **Proposed decision:** Inside a string literal, a single quote is written as two single quotes, for example `'farmer''s choice'` (the `plan_type` value in the data dictionary); backslash escapes are not used.
- **Rationale:**
- **Applies to:** all SQL files.
- **Status:** Agreed.

## D20 No refund row for a zero refund

- **Decision:** When a refund works out to 0 HKD, the operation inserts no `refund` row; the rest of the operation runs as usual. This covers a skip when no refundable skip remains (BR8) and the cancellation of an active subscription whose BR10 refund (min(remaining refundable skips, planned deliveries after the cancellation date) × allocated cost, plus the add-on fees on those deliveries) is 0.
- **Rationale:** `ck_refund_amount` (`amount > 0`, data dictionary §5.5) rejects a zero amount, and a row that refunds nothing carries no information. Queries that total refunds already use `COALESCE(..., 0)` for subscriptions with no refund rows.
- **Applies to:** skip and cancellation operations (BR8, BR10), their tests, README `# Tests`.
- **Status:** Agreed, 2026-11-03.

## D21 Candidate keys not enforced by UNIQUE

- **Decision:** Do not add `UNIQUE (customer_id, submission_date)` on `subscription` or `UNIQUE (subscription_id, type, refund_date)` on `refund`. The report keeps both candidate keys and states that the database does not enforce them by itself.
- **Rationale:** `{customer_id, submission_date}` follows from one open enrolment window (D03) together with BR2. `{subscription_id, type, refund_date}` follows from non-overlapping skip windows, one failed refund on the day after its delivery, and at most one cancellation. A direct INSERT can bypass both, which stays a documented limitation.
- **Applies to:** report normalization section, README `# Limitations`.
- **Status:** Agreed, 2026-11-09.

## D22 Submission dates of Autumn 2025 subscriptions

- **Decision:** Every Autumn 2025 subscription has a `submission_date` between 2025-05-27 and 2025-08-18, both included. This is the range Summer 2025 would have under BR3 with its first planning day on Monday 2025-06-02, the first Monday of June, as for Summer 2026 (D01). Summer 2025 itself is not stored.
- **Rationale:** Under BR4, the enrolment window for an autumn season is the summer range of the same year. Without a Summer 2025 row, the window has to be fixed by this convention. The range ends before the Autumn 2025 range starts (2025-09-02), so D03 still holds.
- **Note:** Autumn 2025 rows are inserted directly by `sql/02_data.sql`, not by the enrolment operation (UC1). The window check of BR4 is therefore not run on them, and the seed check for submission dates (I02) uses the range above for this season.
- **Applies to:** `sql/02_data.sql`, `stage2/scratch/seed_checks.sql`, README `# Queries`.
- **Status:** Agreed, 2026-11-10.

## D23 Autumn 2025 subscriptions are all at full price

- **Decision:** Every Autumn 2025 subscription has the full allocated cost: 200.00 for `'farmer''s choice'` and 240.00 for `'customizable'`. None is a renewal.
- **Rationale:** Under BR4, an autumn subscription is a renewal only if the customer holds an active or finished subscription for the summer of the same year. Summer 2025 is not stored, so no Autumn 2025 subscription can be shown to be a renewal from the data. Autumn 2025 subscriptions can still make Spring 2026 subscriptions renewals (D02).
- **Applies to:** `sql/02_data.sql`, `stage2/scratch/seed_checks.sql` (the renewal-price check, I03, treats every Autumn 2025 subscription as new).
- **Status:** Agreed, 2026-11-10.

## D24 Renewal is decided on the submission date

- **Decision:** Whether a subscription is a renewal, and so whether it gets the 20% discount (160.00 or 192.00), is decided once, on its submission date. The previous-season subscription counts if it is active or finished on that date. Cancelling it later does not change the renewal's allocated cost, and no extra charge or refund follows.
- **Rationale:** BR4 already defines a renewal by the previous subscription's status "when it is submitted", and `allocated_cost` is a price snapshot (data dictionary §5.3). This entry states how that wording is applied when the previous subscription is cancelled after the renewal is submitted. It is not a design change, so it has no change-log entry.
- **Consequence for the seed checks:** The renewal-price check (I03) cannot use the current `status`, which may now be `'cancelled'`. Because the enrolment window of a season lies inside or after the range of its previous subscribable season (BR4), a previous-season subscription that exists is active or finished on the submission date unless it was already cancelled. A subscription is therefore a renewal exactly when the same customer has a subscription for the previous subscribable season whose `cancellation_date` is NULL or later than this subscription's `submission_date`.
- **Same-day case:** If the previous subscription is cancelled on the renewal's submission date, the result depends on which operation runs first. The seed data never put both on the same day.
- **Example in the seed data:** C15 submits Autumn 2026 subscription 403 on 2026-06-05, while Summer 2026 subscription 307 is active, so 403 costs 160.00. C15 then cancels 307 on 2026-06-24, and 403 stays at 160.00 (`stage2/notes/seed_cast.md`, coverage #13).
- **Applies to:** `sql/02_data.sql`, `stage2/scratch/seed_checks.sql`, enrolment operation (UC1), report BR4 discussion.
- **Status:** Agreed, 2026-11-10.

## D25 Identifier scheme of the seed data

- **Decision:** `sql/02_data.sql` writes every identifier explicitly:

  | Table | Identifiers |
  | --- | --- |
  | `season` | 1 = Autumn 2025, 2 = Spring 2026, 3 = Summer 2026, 4 = Autumn 2026 |
  | `product` | 1–10 Autumn 2025, 11–20 Spring 2026, 21–30 Summer 2026, 31–40 Autumn 2026; within each block the 6 farmer's choice types come first |
  | `customer` | `customer_id` = cast number (C01 = 1, …, C15 = 15) |
  | `subscription` | 101– Autumn 2025, 201– Spring 2026, 301– Summer 2026, 401– Autumn 2026 |
  | `refund` | 1–15 in `refund_date` order |

- **Rationale:** The season of a subscription or product can be read from its identifier, so test results and query outputs are easy to check against `seed_cast.md`. Because the identifiers are explicit, AUTO_INCREMENT continues from the largest one; tests and operations must read a new row's identifier with `LAST_INSERT_ID()` instead of assuming it.
- **Applies to:** `sql/02_data.sql`, `stage2/notes/seed_plan.xlsx`, `tests/`.
- **Status:** Agreed, 2026-11-10.

## D26 Delivery rows are literal values in `sql/02_data.sql`

- **Decision:** All 198 delivery rows are written as literal `INSERT ... VALUES` tuples, generated with the rest of the file from `stage2/notes/seed_plan.xlsx` by `stage2/scratch/export_seed_sql.ps1`. The seed file contains no `INSERT ... SELECT` and no `UPDATE`. The BR7 rule that generates a subscription's deliveries on the first day of its range is implemented once, as a Phase 3 operation, and tested there.
- **Rationale:** Literal rows can be reviewed directly against `seed_timelines.md`, and the seed data do not depend on operation code that is still to be written. The workbook derives each status by the same rule as BR7 (exceptions first, then cancelled after the cancellation date, then success up to 2026-07-05, otherwise planned), and its checks confirm the distribution 134 / 9 / 2 / 26 / 27.
- **Applies to:** `sql/02_data.sql`, Phase 3 operations, README `# Build`.
- **Status:** Agreed, 2026-11-10.

## D27 Add-on purchase dates are not stored

- **Decision:** `add_on` has no purchase date, so the database cannot show that an add-on was bought inside its change window (BR9). In the seed data, every add-on's purchase date is recorded in `seed_timelines.md` and checked there against the window. In later operations, the window is enforced by the add-on INSERT ... SELECT at purchase time.
- **Rationale:** The data dictionary (§5.8) defines no date on `add_on`, and adding one would be a design change for a value no query or rule reads after the purchase.
- **Applies to:** README `# Limitations`, `stage2/scratch/seed_checks.sql` (I14 checks the plan and the delivery, not the window).
- **Status:** Agreed, 2026-11-10.

---

## Entry template

```markdown
## Dxx <Topic>

- **Decision:**
- **Rationale:** <one or two sentences>
- **Applies to:** <files or README sections>
- **Status:** Agreed / Open / Superseded by Dyy, YYYY-MM-DD
```
