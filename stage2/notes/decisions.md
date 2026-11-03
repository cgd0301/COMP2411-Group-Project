# Stage 2 Implementation Decisions

This file records conventions that do not change the Stage 1 design but affect how Stage 2 is implemented. Each entry states the decision and gives a one- or two-sentence rationale. Design changes go in `changelog.md` instead. These entries are the source for the README sections `# Environment`, `# Queries`, `# Tests` and `# Limitations` [9.3] and for the implementation notes in the report. This is an internal working file: do not put it in the submission ZIP.

## How to use this file

- Number entries `D01`, `D02`, … in order. Never renumber or reuse an ID.
- To change a decision, set the old entry's status to `Superseded by Dxx` and add a new entry. Do not delete or rewrite the old decision.
- Status values: `Agreed` (fixed and in use), `Open` (not yet decided), `Superseded by Dxx`.
- Each member ticks their column in the index after reading and accepting the entry.
- To add an entry, copy the template at the end of this file and add a row to the index.

## Index

| ID  | Topic | Status | Date | CHEN | SHI |
| --- | ----- | ------ | ---- | ---- | --- |
| D01 | Season calendar for the seed data | Agreed | 2026-11-03 | ☐ | ☐ |
| D02 | Autumn 2025 is included in the seed data | Agreed | 2026-11-03 | ☐ | ☐ |
| D03 | Season ranges never overlap | Agreed | 2026-11-03 | ☐ | ☐ |
| D04 | Baseline reference date 2026-07-07 | Agreed | 2026-11-03 | ☐ | ☐ |
| D05 | Reference date in test and operation scripts | Agreed | 2026-11-03 | ☐ | ☐ |
| D06 | Dates in `queries/Qxx.sql` | Open | 2026-11-03 | ☐ | ☐ |
| D07 | No `CURDATE()` or `NOW()` | Agreed | 2026-11-03 | ☐ | ☐ |
| D08 | Table and column names | Agreed | 2026-11-03 | ☐ | ☐ |
| D09 | Constraint names | Agreed | 2026-11-03 | ☐ | ☐ |
| D10 | SQL layout | Agreed | 2026-11-03 | ☐ | ☐ |
| D11 | No integer display widths | Agreed | 2026-11-03 | ☐ | ☐ |
| D12 | Test IDs | Agreed | 2026-11-03 | ☐ | ☐ |
| D13 | SQL file header comment | Agreed | 2026-11-03 | ☐ | ☐ |
| D14 | Development environment check | Open | | ☐ | ☐ |
| D15 | Acknowledgement requirement check | Open | | ☐ | ☐ |
| D16 | Referential-action clause on foreign keys whose columns are used in a CHECK | Open | | ☐ | ☐ |
| D17 | Case sensitivity of status and type values | Open | | ☐ | ☐ |
| D18 | Signed and unsigned columns, and the values used in negative tests | Open | | ☐ | ☐ |
| D19 | Apostrophes in string literals | Open | | ☐ | ☐ |

---

## D01 Season calendar for the seed data

- **Decision:** The seed data contain exactly the four seasons below. D is the first planning day (a Monday); the subscription range runs from D − 6 to D + 77, both included (84 days, BR3); the enrolment window follows BR4.

  | Season      | First planning day D | Subscription range (D − 6 to D + 77) | Enrolment window (BR4) | Status of non-cancelled subscriptions on the baseline date (D04) |
  | ----------- | -------------------- | ------------------------------------ | ---------------------- | ---------------------------------------------------------------- |
  | Autumn 2025 | 2025-09-08 | 2025-09-02 to 2025-11-24 | The Summer 2025 range (Summer 2025 is not stored) | finished |
  | Spring 2026 | 2026-03-02 | 2026-02-24 to 2026-05-18 | 2025-11-25 to 2026-02-23 | finished |
  | Summer 2026 | 2026-06-01 | 2026-05-26 to 2026-08-17 | 2026-02-24 to 2026-05-18 | active |
  | Autumn 2026 | 2026-09-07 | 2026-09-01 to 2026-11-23 | 2026-05-26 to 2026-08-17 | planned (its window is open) |

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

  | Constraint  | Pattern                 | Example               |
  | ----------- | ----------------------- | --------------------- |
  | CHECK       | `ck_<table>_<meaning>`  | `ck_delivery_week_no` |
  | UNIQUE      | `uq_<table>_<columns>`  | `uq_customer_email`   |
  | FOREIGN KEY | `fk_<child>_<parent>`   | `fk_add_on_delivery`  |

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

  | Item | Expected | CHEN | SHI |
  | ---- | -------- | ---- | --- |
  | `VERSION()` | `8.4.11` | | |
  | `@@sql_mode` | includes `STRICT_TRANS_TABLES` and `ONLY_FULL_GROUP_BY` | | |
  | `@@autocommit` | `1` | | |
  | `@@default_storage_engine` | `InnoDB` | | |
  | `@@character_set_server` | `utf8mb4` | | |
  | `@@collation_server` | `utf8mb4_0900_ai_ci` | | |
  | The `mysql` command-line client connects and can `source` a script | yes | | |
  | Account used (name and privileges only) | | | |

- **Decision:** <environment recorded in the README `# Environment` section and in `metadata.json`>
- **Rationale:** The README must state the tested versions and privileges [9.3], and strict mode makes invalid values fail instead of being silently adjusted, which the negative tests depend on.
- **Applies to:** README `# Environment` and `# Tests` (autocommit), `metadata.json`.
- **Status:** Open.

## D15 Acknowledgement requirement check (roadmap 0.7)

- **Check:** Open the guidance PDF in a PDF reader, search (Ctrl+F) for the professor's name in the last bullet of Section 10 (search for `Yuawqv`), and see whether the highlighted text is visible on the page.
- **Result:** ☐ Visible text, so it is a formal requirement　☐ Found but not visible (for example white text); asked the TA on ________, answer: ________
- **Decision:** <what the report's Acknowledgements section will say>
- **Rationale:**
- **Applies to:** `report.pdf` Acknowledgements section; checklist item J10.
- **Status:** Open.

## D16 Referential-action clause on foreign keys whose columns are used in a CHECK (roadmap 1.2, question 1)

- **Question:** MySQL does not allow a column used in a CHECK constraint to carry a foreign-key referential action. `refund.week_no` is used in `ck_refund_link` and in the composite foreign key to `delivery`. Should that foreign key state `ON DELETE RESTRICT` explicitly, or omit the clause (RESTRICT is the InnoDB default)? Proposal §8.2 planned no referential actions. Decide after the schema probe.
- **Decision:**
- **Rationale:**
- **Applies to:** `sql/01_schema.sql`.
- **Status:** Open.

## D17 Case sensitivity of status and type values (roadmap 1.2, question 2)

- **Question:** With the default collation `utf8mb4_0900_ai_ci`, `'PLANNED'` passes `CHECK (status IN ('planned', …))` and is stored in upper case. Accept this and list it as a limitation, or declare these columns with `COLLATE utf8mb4_bin` (case-sensitive comparison)? If the column definitions change, also add a change-log entry.
- **Decision:**
- **Rationale:**
- **Applies to:** `sql/01_schema.sql`, README `# Limitations`.
- **Status:** Open.

## D18 Signed and unsigned columns, and the values used in negative tests (roadmap 1.2, question 5)

- **Question:** Confirm the signedness of each numeric column and choose negative-test values that trigger the intended CHECK (error 3819) rather than an out-of-range error. Expected behaviour, to be confirmed by the schema probe: `remaining_refundable_skip` is a signed `TINYINT`, so lowering 0 by 1 gives 3819; `week_no` is `TINYINT UNSIGNED`, so 13 gives 3819 but −1 gives 1264.
- **Decision:**
- **Rationale:**
- **Applies to:** `sql/01_schema.sql`, `tests/negative/`, `evidence/test_cases.csv`.
- **Status:** Open.

## D19 Apostrophes in string literals

- **Proposed decision:** Inside a string literal, a single quote is written as two single quotes, for example `'farmer''s choice'` (the `plan_type` value in the data dictionary); backslash escapes are not used.
- **Rationale:**
- **Applies to:** all SQL files.
- **Status:** Open.

---

## Entry template

```markdown
## Dxx <Topic>

- **Decision:**
- **Rationale:** <one or two sentences>
- **Applies to:** <files or README sections>
- **Status:** Agreed / Open / Superseded by Dyy, YYYY-MM-DD
```
