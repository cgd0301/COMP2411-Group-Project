# Stage 2 Change Log (working draft)

This is the working draft of the change log that `report.pdf` must contain [6, 6.1]. It records every change from the submitted Stage 1 design (`proposal.pdf`, submitted 26 Oct 2026). It is an internal working file: do not put it in the submission ZIP. Copy the final table into the report before submission.

## What goes in this file

- **This file (change log):** every design change, meaning anything that makes the Stage 2 design differ from `proposal.pdf`. This covers entities, relationships, tables, columns, types, keys, constraints, business rules, use cases, management questions, functional dependencies, and the enforcement method of a rule. Example: adding a UNIQUE constraint.
- **`decisions.md`:** implementation conventions that leave the design unchanged. Example: which baseline reference date the seed data use.
- If it is unclear which file an item belongs to, agree on it first, then record it in one file only and cross-reference it from the other.

## How to fill in each column

| Column           | What to write |
| ---------------- | ------------- |
| ID               | `CL01`, `CL02`, … in order. Never renumber or reuse an ID. If a change is reverted, add a new entry that says so. |
| Date             | `YYYY-MM-DD`: the day both members agreed the change. |
| Stage 1 location | Where the item appears in `proposal.pdf`, using its section and table numbers (see the reference list below), for example `§5.3 subscription` or `§7 Table 13 (BR11)`. Write `New` if there is no Stage 1 counterpart. |
| Change           | What changed, written as "Before: …; After: …". Name tables, columns, constraints and rule IDs exactly. |
| Reason           | Why the change was made: the rule, error, test result or feedback that led to it. One or two sentences. |
| Affected files   | Files that were, or must be, updated. Paths inside the deliverable folder start from it (for example `sql/01_schema.sql`); other paths are relative to the repository root (for example `DataDictionary.md`). |

## Stage 1 location reference (`proposal.pdf`)

| Section     | Content |
| ----------- | ------- |
| §1.1        | Scenario fingerprint (Table 1) |
| §2.1        | Business rules BR1–BR11 |
| §2.2        | Operational use cases UC1–UC4 (Table 2) |
| §2.3        | Management questions MQ1–MQ5 |
| §3.1 / §3.2 | ER diagram / design constructs and justification |
| §4.1        | Relational schema |
| §5.1–§5.8   | Data dictionary: `customer`, `season`, `subscription`, `delivery`, `refund`, `product`, `chosen_products`, `add_on` |
| §6.1        | Functional dependencies and normalization, per relation |
| §7          | Traceability matrix (Table 13) |
| §8.1 / §8.2 | Division of work (Table 14) / implementation risks (Table 15) |

## Change log

| ID   | Date       | Stage 1 location | Change | Reason | Affected files |
| ---- | ---------- | ---------------- | ------ | ------ | -------------- |
| CL01 | 2026-11-02 | Whole proposal   | Stage 1 feedback received: no issues raised; no design change planned. | Baseline entry: Stage 2 starts from the submitted Stage 1 design, and every later entry records a departure from it. | — |
| CL02 | 2026-11-03 | §5.3 subscription | Before: `allocated_cost` CHECK IN (160, 192, 200, 240); After: `ck_subscription_allocated_cost` requires the cost to match the plan: 200 or 160 for `'farmer''s choice'`, 240 or 192 for `'customizable'`. | The data dictionary was weaker than the BR5 Enforcement field (§2.1), which already requires the cost to match the plan; with the old CHECK, the BR5 test (a farmer's choice subscription with a cost of 240 is rejected, 3819) would fail. | `DataDictionary.md`, `stage2/notes/constraint_inventory.md`, `sql/01_schema.sql`, report data dictionary section |
| CL03 | 2026-11-04 | §2.1 BR11; §5.5 refund | Before: `refund.type` is `'skip'`, `'failed'` or `'cancellation'`. After: `'skipped'`, `'failed'` or `'cancelled'`. `ck_refund_type` requires a `week_no` for `'skipped'` and `'failed'`, and a NULL `week_no` for `'cancelled'`. | These words match the delivery status of the same event (`skipped`, `failed`, `cancelled`). | `sql/01_schema.sql`, `DataDictionary.md`, `businessRules.md`, `userCases.md`, `stage2/notes/constraint_inventory.md`. Still to update: report BR11 and §5.5 |
| CL04 | 2026-11-04 | §5.4 delivery; §5.5 refund; §5.8 add_on | Before: `week_no` is `TINYINT UNSIGNED` on `delivery`, `refund` and `add_on`. After: signed `TINYINT` on all three. | A negative value in an UNSIGNED column fails with 1264 before the CHECK runs, so the error does not name the constraint. A signed column fails with 3819 and names `ck_delivery_week_no`. The rule for every numeric CHECK column is D18. | `sql/01_schema.sql`, `DataDictionary.md`, `stage2/notes/constraint_inventory.md`. Still to update: report §5.4, §5.5 and §5.8 |

## Pending candidates (not yet agreed)

These are possible design changes still under discussion. When one is decided, add a `CLxx` entry to the change log above (or a `decisions.md` entry if it does not change the design), and write the result in **Outcome**, for example `Accepted as CL02` or `Not adopted, reason in Dxx`.

| Candidate | Stage 1 location | Decide in | Outcome |
| --------- | ---------------- | --------- | ------- |
| Enforce the candidate key `{customer_id, submission_date}` of `subscription` with a UNIQUE constraint, or explain in the report why it is not enforced | §6.1 subscription; §5.3 | Phase 1 (schema) | |
| Enforce the candidate key `{subscription_id, type, refund_date}` of `refund` with a UNIQUE constraint, or explain in the report why it is not enforced | §6.1 refund; §5.5 | Phase 1 (schema) | |
| Add low-cost CHECK constraints that map to existing rules: `status = 'cancelled'` exactly when `cancellation_date IS NOT NULL` (BR3, BR10); `cancellation_date >= submission_date` (BR10); `is_farmers_choice IN (0, 1)` (BR6); `YEAR(first_planning_day) = year` (BR3) | §5.2, §5.3, §5.6 | Phase 1 (schema) | |

## Before adding an entry

- [ ] Both members (lead and reviewer) agree on the change.
- [ ] `DataDictionary.md`, the Enforcement field in `businessRules.md` and the traceability matrix are updated where affected.
- [ ] The ER diagram, relational schema, SQL scripts and report text still agree [10].
- [ ] A new or changed constraint is in the constraint inventory and has a probe or negative test.
- [ ] If a management question is refined, `evidence/query_map.csv` names the refined question [9.2].
