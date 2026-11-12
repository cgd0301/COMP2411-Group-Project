# COMP2411 Stage 2 Self-Check Checklist

- **Source:** `COMP2411_Project_Guidance_2026.pdf`. A tag such as [6.2] is the guidance section number. **Location** is a path inside the deliverable folder `COMP2411_2026_G085_Stage2/` unless it names something else (`report.pdf`, `Canvas`, `Live session`).
- **Deadlines (HKT):** complete Stage 2 submission, including `presentation.pdf`: **Mon 23 Nov 2026, 23:55** [1.1, 6]. In-person presentation, live demonstration and live-modification task: the date, time and room in the current Canvas group name (at Stage 1: `Group 85, Nov 25 Wed 12:40-12:45 PQ604A`) [6.5].
- **Marks:** Stage 2 = 15 marks = 12 × R/100 + P, where R is the core rubric score out of 100 and P is the shared presentation score out of 3 [7.3]. Core rubric weights: SQL implementation and functionality 28% (including 6% for technical depth); conceptual and relational design 18%; requirements, normalization and integrity, testing and analysis, and documentation and reproducibility 12% each; index selection 6% [7.2].
- **Status:** ☐ not started　◐ in progress　☑ verified (preferably by the member who did not do the work).
- This is an internal working file. **Do not put it in the submission ZIP.**

## A. Required files and overall scope [6, 6.1]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| A1  | The final system implements the registered workflow (D17-W04) with an improved final design, and every change from the submitted Stage 1 design is explained in the change log (draft: `changelog.md`) [6] | `report.pdf` | | ☐ |
| A2  | The W04 minimum core requirement is implemented and demonstrated: enrolment and renewal with explicit eligibility or validity rules, and recorded use of defined benefits, entitlements or quotas [6, A.2] | `sql/`, `tests/` | | ☐ |
| A3  | `README.md` is a text-based user guide that follows the headings and execution conventions of 9.3, and gives software versions, setup order, account prerequisites (without passwords), key operations, test instructions and limitations [6.1] | `README.md` | | ☐ |
| A4  | `sql/01_schema.sql` creates the tables, keys, foreign keys and other constraints [6.1] | `sql/01_schema.sql` | | ☑ |
| A5  | `sql/02_data.sql` inserts the synthetic seed data in a valid insertion order (parent rows before child rows) [6.1] | `sql/02_data.sql` | CHEN | ☑ |
| A6  | `sql/03_views.sql` defines the required view(s) [6.1] | `sql/03_views.sql` | | ☐ |
| A7  | `sql/04_indexes.sql` holds the additional index definition(s), or comments that identify and justify an existing index [6.1, 6.3] | `sql/04_indexes.sql` | | ☐ |
| A8  | `queries/Q01.sql` to `queries/Q08.sql` (and `Q09.sql` onwards if needed) each hold one distinct business query [6.1] | `queries/` | | ☐ |
| A9  | `tests/` contains the successful operations, the commit and rollback demonstrations, and separately executable negative tests [6.1] | `tests/` | | ☐ |
| A10 | `report.pdf` states the final scope [6.1] | `report.pdf` | | ☐ |
| A11 | `report.pdf` contains the business rules and management questions [6.1] | `report.pdf` | | ☐ |
| A12 | `report.pdf` contains the final ER diagram [6.1] | `report.pdf` | | ☐ |
| A13 | `report.pdf` contains the final schema and data dictionary [6.1] | `report.pdf` | | ☐ |
| A14 | `report.pdf` contains a normalization summary [6.1] | `report.pdf` | | ☐ |
| A15 | `report.pdf` contains the change log [6, 6.1] | `report.pdf` | | ☐ |
| A16 | `report.pdf` contains the test cases and their results [6.1] | `report.pdf` | | ☐ |
| A17 | `report.pdf` contains at least two analytical findings [6.1] | `report.pdf` | | ☐ |
| A18 | `report.pdf` contains the index-selection rationale [6.1] | `report.pdf` | | ☐ |
| A19 | `contribution.pdf` gives each member's main responsibilities and relevant files or tasks, a contribution category (Equal, Major, Minor or No Contribution), any disagreement, and the signatures of all members [6.1, 3.3] | `contribution.pdf` | | ☐ |
| A20 | `metadata.json`, `ai_usage.md` and `evidence/` are present and follow the formats of 9.2 and the AI declaration requirements of Section 8 [6.1] | `metadata.json`, `ai_usage.md`, `evidence/` | | ☐ |
| A21 | `presentation.pdf` is present (required for all teams) and is the file used in the in-person presentation [6.1, 6.5] | `presentation.pdf` | | ☐ |
| A22 | Application source code is included only if we build an interface; a front end does not replace any required SQL evidence [6.1] | `app/` (optional) | | ☐ |
| A23 | The four construction scripts in `sql/` succeed in numerical order in an empty project database [6.1] | `sql/` | | ◐ |
| A24 | Query files and tests are run separately, after construction; expected-failure tests are not part of installation [6.1] | `queries/`, `tests/` | | ☐ |
| A25 | All scripts use comments and the fixed filenames, and no file contains a real password [6.1] | all files | | ◐ |

## B. Minimum database evidence [6.2]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| B1  | Every table has a primary key, and every relevant relationship has a foreign key (check the counts against the constraint inventory) [6.2] | `sql/01_schema.sql` | | ☑ |
| B2  | Meaningful NOT NULL, UNIQUE and CHECK constraints, and referential actions where supported and appropriate [6.2] | `sql/01_schema.sql` | | ☑ |
| B3  | There are enough synthetic rows to exercise every relationship, constraint, query and edge case [6.2] | `sql/02_data.sql` | CHEN | ☑ |
| B4  | Successful INSERT, UPDATE and DELETE operations are shown, each in a business context [6.2] | `tests/positive.sql` | | ☐ |
| B5  | Deliberate invalid operations show that the important constraints reject bad data [6.2] | `tests/negative/` | | ☐ |
| B6  | At least eight labelled, distinct business queries (Q01–Q08). Near-duplicates do not count; CREATE VIEW does not count, but a business query that uses a view may count [6.2] | `queries/` | | ☐ |
| B7  | Two distinct queries with multi-table joins, at least one of them using three or more tables [6.2] | `queries/` | | ☐ |
| B8  | Two distinct aggregate queries using GROUP BY, at least one of them using HAVING [6.2] | `queries/` | | ☐ |
| B9  | Two distinct subquery-based queries, at least one of them using a correlated subquery, EXISTS or NOT EXISTS [6.2] | `queries/` | | ☐ |
| B10 | One query that handles missing values correctly [6.2] | `queries/` | | ☐ |
| B11 | One additional non-trivial query chosen for our scenario [6.2] | `queries/` | | ☐ |
| B12 | At least one useful VIEW [6.2] | `sql/03_views.sql` | | ☐ |
| B13 | One multi-statement transaction with COMMIT and a demonstrated failure/rollback case (details in section D) [6.2, 6.4.1] | `tests/transaction_*.sql` | | ☐ |
| B14 | One justified index, with its target query and an explanation of the indexed columns, expected benefit, additional storage and update-maintenance cost (details in section C) [6.2, 6.3] | `sql/04_indexes.sql`, `report.pdf` | | ☐ |
| B15 | Every query is mapped to its question and techniques in `evidence/query_map.csv`. Technique categories may overlap, but eight distinct queries are still needed; several queries may serve one management question [6.2] | `evidence/query_map.csv` | | ☐ |
| B16 | Seed data include meaningful relationships and groups, and the relevant statuses and dates [6.2] | `sql/02_data.sql` | CHEN | ☑ |
| B17 | Seed data include both matching and non-matching cases (for example, a product chosen by nobody) [6.2] | `sql/02_data.sql` | CHEN | ☑ |
| B18 | Seed data include legitimate missing values (NULL) [6.2] | `sql/02_data.sql` | CHEN | ☑ |
| B19 | Seed data include groups that HAVING keeps and groups that it rejects [6.2] | `sql/02_data.sql` | CHEN | ☑ |
| B20 | Seed data include rows that verify each subquery (rows that satisfy it and rows that do not) [6.2] | `sql/02_data.sql` | CHEN | ☑ |
| B21 | Each query's expected result is stated; most results are meaningfully non-empty, and any intentionally empty result is explained [6.2] | `report.pdf`, `evidence/` | CHEN | ◐ |
| B22 | Boundary and negative tests reflect business rules (row count alone earns no marks) [6.2] | `tests/` | | ☐ |

## C. Index selection and justification [6.3]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| C1  | One representative query is chosen, and either a new index is created with CREATE INDEX or an existing index that already serves the query is justified [6.3] | `sql/04_indexes.sql` | | ☐ |
| C2  | `sql/04_indexes.sql` defines the new index (or identifies the existing one in SQL comments) and cites the target Query ID [6.3] | `sql/04_indexes.sql` | | ☐ |
| C3  | The executable target query stays in its own `queries/Qxx.sql` file [6.3] | `queries/` | | ☐ |
| C4  | The report explains which query condition or join the indexed column(s) support [6.3] | `report.pdf` | | ☐ |
| C5  | The report explains why the index may help locate the required rows, considering how many rows the query is expected to match [6.3] | `report.pdf` | | ☐ |
| C6  | The report explains the additional storage, and the maintenance work when rows are inserted or deleted or indexed values are updated [6.3] | `report.pdf` | | ☐ |
| C7  | The explanation uses the indexing concepts taught in class, and no speedup is claimed without measurements [6.3] | `report.pdf` | | ☐ |

## D. Testing and analysis [6.4, 6.4.1]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| D1  | A test table gives, for every test: test ID, requirement/rule, setup, SQL or action, expected result, actual result and pass/fail status [6.4] | `evidence/test_cases.csv` | | ☐ |
| D2  | The test table uses the machine-readable format of 9.2, and the report discusses the important results [6.4] | `evidence/test_cases.csv`, `report.pdf` | | ☐ |
| D3  | Tests include normal cases [6.4] | `tests/` | | ☐ |
| D4  | Tests include boundary cases [6.4] | `tests/` | | ☐ |
| D5  | Tests include null handling [6.4] | `tests/` | | ☐ |
| D6  | Tests include duplicate-key attempts [6.4] | `tests/negative/` | | ☐ |
| D7  | Tests include invalid references [6.4] | `tests/negative/` | | ☐ |
| D8  | Tests include a transaction failure [6.4] | `tests/transaction_rollback.sql` | | ☐ |
| D9  | Executable SQL and captured results are the primary evidence; screenshots only support the report [6.4] | `tests/`, `evidence/` | | ☐ |
| D10 | Negative tests are run one at a time, outside construction, with one expected-failure statement per file under `tests/negative/` (the transaction rollback script is the only exception) [6.4] | `tests/negative/` | | ☐ |
| D11 | Each negative test states its Test ID, prerequisites, and the expected MySQL error number or SQLSTATE [6.4] | `tests/negative/` | | ☐ |
| D12 | Each rejection is shown to leave the relevant data unchanged, with concrete before/after evidence [6.4] | `tests/negative/`, `evidence/test_cases.csv` | | ☐ |
| D13 | Each test starts from fresh seed data unless its exact prerequisites are documented [6.4] | `tests/`, `README.md` | | ☐ |
| D14 | The transaction uses transactional tables (InnoDB) [6.4.1] | `sql/01_schema.sql` | | ☑ |
| D15 | The transaction is a coherent business operation with at least two related data-changing statements [6.4.1] | `tests/transaction_*.sql` | | ☐ |
| D16 | Commit path: explicitly starts a transaction, makes the changes and commits; before/after evidence shows that all intended changes persist [6.4.1] | `tests/transaction_commit.sql` | | ☐ |
| D17 | Rollback path: explicitly starts a transaction, makes at least one successful change, then meets a related failure and explicitly executes ROLLBACK; before/after evidence proves that every earlier change in that transaction was undone [6.4.1] | `tests/transaction_rollback.sql` | | ☐ |
| D18 | Both transaction scripts are submitted and follow 9.4; an observed error alone is not accepted as proof of rollback [6.4.1] | `tests/` | | ☐ |
| D19 | At least two decision-relevant analytical findings, each linking a management question to its SQL, output and a brief interpretation (they may reuse Q01–Q08 results) [6.4, 6.2] | `report.pdf` | | ☐ |
| D20 | No interpretation infers causation or business impact that the synthetic data cannot support [6.4] | `report.pdf` | | ☐ |

## E. Demonstration [6.5]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| E1  | Every member has checked the date, time and room in the current Canvas group name, and any teaching-team announcements [6.5] | Canvas | | ☐ |
| E2  | All members attend and bring student identification [6.5] | Live session | | ☐ |
| E3  | The team is outside the assigned room at least 10 minutes before the start time [6.5] | Live session | | ☐ |
| E4  | The team brings the submitted slides, the SQL scripts and a working local MySQL database; the connection is tested and the relevant queries are prepared in advance [6.5] | Live session | | ☐ |
| E5  | The 4-minute prepared portion explains key design decisions, runs representative SQL against the submitted database, and shows correctness evidence, including a transaction or an important constraint test [6.5] | `presentation.pdf` | | ☐ |
| E6  | The prepared portion uses the submitted `presentation.pdf` and includes a real live run (slides alone are not a live demonstration) [6.5] | `presentation.pdf` | | ☐ |
| E7  | The prepared portion is rehearsed to fit 4 minutes; the 6-minute slot has no changeover time [6.5] | Live session | | ☐ |
| E8  | Both members have practised the four example task types: include rows with no related records (for example, customers with no bookings); count only completed rows and keep only groups above a threshold; insert data that violate an enforced rule, predicting and explaining the rejection; change one transaction step, show rollback after failure and identify the data that must be restored [6.5] | Live session | | ☐ |
| E9  | Every member can explain and operate any part of the database (the instructor may ask any member) [6.5] | Live session | | ☐ |
| E10 | During the assessment we use only our own SQL and course materials: no AI tools, messaging or chat tools, or remote assistance [6.5, 8] | Live session | | ☐ |
| E11 | Any attendance conflict is reported to the teaching team promptly; nobody switches Canvas groups independently [6.5] | Canvas | | ☐ |

## F. Archive, directory structure and upload [9, 9.1]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| F1  | The ZIP is named `COMP2411_2026_G085_Stage2.zip` and contains exactly one top-level directory, `COMP2411_2026_G085_Stage2/` (file and directory names are case-sensitive) [9.1] | ZIP | | ☐ |
| F2  | The ZIP name contains no Canvas group name, presentation details, member names or Scenario ID [9.1] | ZIP | | ☐ |
| F3  | The directory tree matches the expected tree below exactly [9.1] | ZIP | | ☐ |
| F4  | Every extra query (Q09, Q10, …) has a matching result CSV and a mapping row; negative tests are numbered N01, N02, … [9.1] | `queries/`, `evidence/`, `tests/negative/` | | ☐ |
| F5  | All text files are UTF-8 [9.1] | all files | | ☐ |
| F6  | No extra wrapper directories, passwords, database binaries, caches or editor dependencies: every `.gitkeep` placeholder is deleted, there is no `__MACOSX/` or `.DS_Store`, and working files (`stage2/notes/`, `stage2/scratch/`, the report source) stay outside the package. `tar -tf COMP2411_2026_G085_Stage2.zip` shows every path starting with the top-level directory [9.1] | ZIP | | ☐ |
| F7  | `contribution.pdf` includes the signatures of all members (scanned handwritten or electronic signatures are acceptable) [9.1] | `contribution.pdf` | | ☐ |
| F8  | No signatures or student details appear in the synthetic database [9.1] | `sql/02_data.sql` | CHEN | ☑ |
| F9  | Before upload: every member is still in the same Canvas group, and the archive and metadata use its Group ID (G085) [9] | Canvas | | ☐ |
| F10 | One designated member uploads the ZIP to the Stage 2 assignment before the deadline [9] | Canvas | | ☐ |
| F11 | After upload: the submission confirmation and uploaded filename are checked, and the submitted package is shared with all members [9] | Canvas | | ☐ |

Expected tree for F3 (ellipses mean further numbered files):

```
COMP2411_2026_G085_Stage2/
  metadata.json
  README.md
  report.pdf
  contribution.pdf
  ai_usage.md
  sql/
    01_schema.sql
    02_data.sql
    03_views.sql
    04_indexes.sql
  queries/
    Q01.sql ... Q08.sql        (Q09.sql ... if needed)
  tests/
    positive.sql
    transaction_commit.sql
    transaction_rollback.sql
    negative/
      N01.sql ...
  evidence/
    query_map.csv
    test_cases.csv
    query_results/
      Q01.csv ... Q08.csv      (one per query file)
  presentation.pdf
  app/                         (optional interface source)
```

## G. Metadata and evidence formats [9.2]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| G1  | Every example value from the guidance (G002, D07-W03, Student A, REPLACE_A, …) is replaced with our own information [9, 9.2] | all files | | ☐ |
| G2  | `metadata.json` is valid JSON (`python -m json.tool metadata.json` runs without error) and has the 10 required keys: `group_id`, `canvas_group_name`, `scenario_id`, `stage`, `team_size`, `members`, `dbms`, `dbms_version`, `database_name`, `approval_reference` [9.2] | `metadata.json` | | ☑ |
| G3  | `"stage": 2`; `"team_size": 2` matches the number of members; the member list matches Canvas; every `student_id` is a string [9.2] | `metadata.json` | | ◐ |
| G4  | `"scenario_id": "D17-W04"` (the Stage 1 file has lowercase `D17-w04`), and `canvas_group_name` is copied exactly from Canvas (the Stage 1 file has a trailing space) [9.2] | `metadata.json` | | ◐ |
| G5  | `"approval_reference": null` (no quotes) unless a written approval exists [9.2] | `metadata.json` | | ☑ |
| G6  | `dbms`, `dbms_version` and `database_name` record the actual verified Stage 2 environment (see `decisions.md`, environment check) [9.2] | `metadata.json` | | ◐ |
| G7  | The report cover and the presentation title slide show the Group ID, full Canvas group name, Scenario ID, member names and student IDs; the Canvas group name is re-checked before submission [9.2] | `report.pdf`, `presentation.pdf` | | ☐ |
| G8  | CSV files have the exact header rows; fields containing commas, quotes or newlines are quoted with normal CSV escaping; paths are relative to the top-level directory and use forward slashes [9.2] | `evidence/` | | ☐ |
| G9  | `evidence/query_map.csv` has the header `query_id,script,business_question,techniques,result_file` and one row per business query (for Q01: `queries/Q01.sql`, `evidence/query_results/Q01.csv`) [9.2] | `evidence/query_map.csv` | | ☐ |
| G10 | `business_question` identifies one of the proposal's management questions, or a refinement justified in the change log [9.2] | `evidence/query_map.csv` | | ☐ |
| G11 | `techniques` lists every applicable tag, separated by semicolons, from: `join`, `join3plus`, `group_by`, `having`, `subquery`, `correlated`, `exists`, `null_handling`, `view`, `other_nontrivial`; the non-trivial logic is explained whenever `other_nontrivial` is used [9.2] | `evidence/query_map.csv` | | ☐ |
| G12 | `evidence/test_cases.csv` has the header `test_id,requirement,script,initial_state,expected_result,expected_error,actual_result,status` and one row per labelled test case, each with a unique ID (POS01, TXC01, TXR01, N01, …) [9.2] | `evidence/test_cases.csv` | | ☐ |
| G13 | `status` is PASS or FAIL; `expected_error` is NONE for successful tests and otherwise the MySQL error number or SQLSTATE [9.2] | `evidence/test_cases.csv` | | ☐ |
| G14 | `expected_result` and `actual_result` give concrete values or rows, including the unchanged state after a rejection or rollback [9.2] | `evidence/test_cases.csv` | | ☐ |
| G15 | Every Test ID is referenced in the SQL comments and in any supporting report evidence; several cases may be labelled blocks in `tests/positive.sql` [9.2] | `tests/`, `report.pdf` | | ☐ |
| G16 | Each `Qxx.sql` contains one business SELECT statement (it may contain subqueries) with a Query ID comment, and does not modify data [9.2] | `queries/` | | ☐ |
| G17 | Each query is run on the freshly constructed seed state, before any test changes the data, and its output is exported with column headers to the matching `evidence/query_results/Qxx.csv` [9.2] | `evidence/query_results/` | | ☐ |
| G18 | Queries use explicit column aliases where needed and stable seed values, produce no time-dependent or random output, and use ORDER BY whenever row order matters [9.2] | `queries/` | | ☐ |
| G19 | SQL NULL is exported as `\N`, empty strings stay empty, and the literal string `\N` is never used as synthetic data [9.2] | `evidence/query_results/`, `sql/02_data.sql` | | ◐ |
| G20 | An intentionally empty result is submitted as a header row only, and the reason it is empty is explained [9.2] | `evidence/query_results/`, `report.pdf` | | ☐ |

## H. Execution contract and README [9.3]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| H1  | The scripts assume the evaluator has created an empty dedicated database and selected it as the active database, so they never create or select a database themselves; the intended database name (`comp2411_g085`) is recorded in `metadata.json` [9.3] | `sql/`, `metadata.json` | | ◐ |
| H2  | Project table names are unqualified (no database prefix) [9.3] | all SQL files | | ◐ |
| H3  | No executable script contains CREATE/DROP DATABASE, account creation, server administration, global settings, machine-specific file paths or real credentials; account prerequisites are documented in the README instead [9.3] | all SQL files | | ◐ |
| H4  | Foreign-key checks are never disabled to hide an invalid construction order (no `SET FOREIGN_KEY_CHECKS = 0`) [9.3] | `sql/` | | ◐ |
| H5  | All project objects and data are created by the submitted scripts, without manual edits or an external import [9.3] | `sql/` | | ◐ |
| H6  | `README.md` uses exactly these top-level headings: `# Environment`, `# Build`, `# Queries`, `# Tests`, `# Limitations`, `# File inventory` [9.3] | `README.md` | | ☐ |
| H7  | Environment: the tested versions, the privileges needed, and any approval reference [9.3] | `README.md` | | ☐ |
| H8  | Build: lists the four construction scripts and explains how to start from an empty dedicated database [9.3] | `README.md` | | ☐ |
| H9  | Queries: describes the seed baseline (reference date, see `decisions.md`) and the result-export convention [9.3] | `README.md` | | ☐ |
| H10 | Tests: gives the starting state, execution blocks, expected errors and the explicit rollback procedure, and explains how to restore the seed baseline between tests [9.3] | `README.md` | | ☐ |
| H11 | Limitations: distinguishes rules implemented as database constraints, rules checked by SQL operations, and documented exclusions [9.3] | `README.md` | | ☐ |
| H12 | File inventory: lists every submitted file and its purpose [9.3] | `README.md` | | ☐ |
| H13 | Any missing test or known failure is disclosed, not hidden by labelling it as an expected error [9.3] | `README.md`, `evidence/test_cases.csv` | | ☐ |

## I. Transaction test execution [9.4]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| I1  | `tests/transaction_commit.sql` and `tests/transaction_rollback.sql` implement the commit path and the failure/rollback path defined in 6.4.1 [9.4] | `tests/` | | ☐ |
| I2  | Each starts from a freshly constructed seed database unless its exact prerequisites are documented, and concrete before/after values or row sets are recorded in `evidence/test_cases.csv` [9.4] | `tests/`, `evidence/test_cases.csv` | | ☐ |
| I3  | Comments clearly mark the expected-error statement and the rollback/verification block that follows it [9.4] | `tests/transaction_rollback.sql` | | ☐ |
| I4  | The blocks are run interactively in the same connection; if the client stops on the error, the rollback/verification block is still run [9.4] | `tests/transaction_rollback.sql` | | ☐ |
| I5  | `README.md` documents this procedure and the connection's autocommit setting [9.4] | `README.md` | | ☐ |
| I6  | No DDL appears inside the demonstrated transaction (MySQL DDL can cause an implicit commit) [9.4] | `tests/transaction_*.sql` | | ☐ |
| I7  | Each `tests/negative/Nxx.sql` is run separately, with one expected-failure statement per file and documented prerequisites, Test ID and expected MySQL error number or SQLSTATE; each run verifies that the relevant data are unchanged [9.4] | `tests/negative/` | | ☐ |
| I8  | Expected failures never appear in the construction scripts [9.4] | `sql/` | | ◐ |
| I9  | Material SQL-dialect choices are stated in the README [9.4] | `README.md` | | ☐ |
| I10 | Scripts are run with a course database account that has the necessary privileges, and no real credentials are in the archive [9.4] | `README.md`, ZIP | | ☐ |

## J. Final submission checklist [10]

| #   | Check item (pass criterion) [guidance §] | Location | Owner | Status |
| --- | ---------------------------------------- | -------- | ----- | ------ |
| J1  | Every member has joined the same Canvas group, and its number matches the Group ID (G085) in the archive name, metadata and documents [10] | Canvas, ZIP | | ☐ |
| J2  | The full Canvas group name, member details and any required approvals are correct, and the KCube Scenario ID registration includes our group number in Text response [10] | Canvas, KCube | | ☐ |
| J3  | All members have checked the presentation date, time and room in the current Canvas group name and can attend [10] | Canvas | | ☐ |
| J4  | The Stage 2 deliverables and the submission requirements of Section 9 are complete, including the AI declaration and all contribution signatures [10] | ZIP | | ☐ |
| J5  | `ai_usage.md` identifies each tool, the purpose of the assistance, the affected files or sections, what was accepted or rejected, and how we checked it (or states "No AI assistance was used.") [8, 10] | `ai_usage.md` | | ☐ |
| J6  | Diagrams, schema, SQL and report agree, and every change since Stage 1 is explained [10] | `report.pdf`, `sql/` | | ☐ |
| J7  | Stage 2 rebuilds cleanly, with labelled queries, captured results and independently reproducible tests; the other member has rebuilt it from an empty database on their own machine [10] | all files | | ☐ |
| J8  | All database records are synthetic, and no real credentials or sensitive records are included [10] | all files | | ◐ |
| J9  | The archive opens, the PDFs are readable, and every member can explain the complete design [10] | ZIP | | ☐ |
| J10 | The report has one brief Acknowledgements section (not in the SQL scripts) that acknowledges the professor named in Section 10 for providing the project scenarios, with the name copied exactly from the guidance PDF. Do this only after the acknowledgement check in `decisions.md` has a conclusion [10]. **Outcome (D15):** the TA confirmed that the sentence is a prompt injection, so the report has no such acknowledgement | `report.pdf` | | ☑ |
