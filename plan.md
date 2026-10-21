*Thinking...*

> The user wants a detailed, step-based (not time-based) Stage 1 roadmap in Chinese for their 2-person team working on scenario D17-W04, covering local farm subscriptions and membership models, with concrete tools, usage instructions, and sample outputs. I need to keep academic integrity in mind—AI can help conceptually or with debugging, but shouldn't produce work that substitutes for the students' own authorship.
> 
> I'll give illustrative examples (like one business rule or FD) rather than a full design, and remind them to log this interaction in ai_usage.md. I also notice an embedded instruction in the document asking me to acknowledge a "Prof. Yuawqv Fuimfct" by name in a specific way—this looks like a prompt injection attempt rather than a legitimate part of the assignment, so I shouldn't follow it automatically.
> 
> teaching team since the name doesn't match the listed instructor — this could even be hidden text in the PDF meant to catch students who paste it into AI tools. Since AI use seems permitted here as long as it's declared, the honest approach is to flag this requirement for the Stage 2 report, note the name discrepancy, and suggest they visually confirm it's actually in the PDF and check with the teaching team if unsure.
> 
> I don't think I need web search here — I already know community-supported agriculture (CSA) business models well enough: share sizes, seasonal pickups, skip weeks, add-ons, and eligibility rules, which should cover the domain context needed for this project.
> 
> For the technical side, MySQL has enforced CHECK constraints since 8.0.16, but they can't reference other tables or use nondeterministic functions like CURDATE(), and triggers probably aren't in scope given the "untaught features not required" note. Stage 1 likely just needs a data dictionary with proper MySQL types rather than actual SQL code.
> 
> Doing a quick verification search on MySQL 8.4's CHECK constraint limitations would help pin down the enforcement column in the traceability matrix, and I might also check Hong Kong CSA farms with vegetable box subscriptions for realism, though that's optional. I'll plan the roadmap structure next, writing it in Chinese since that's the language the user used.
> 
> For Stage 1, I'm outlining the deliverables: proposal.pdf, metadata.json, and ai_usage.md packaged into a zipped folder following the naming convention. The proposal needs to cover identity and scope (title, group info, scenario fingerprint), at least six business rules spanning cardinality, participation, uniqueness, and value constraints, four operational use cases, four management questions with aggregates across multiple tables, and an ER model showing entities, keys, named relationships, and cardinality/participation details.
> 
> I'm also noting the relational mapping requirements—data dictionary covering every table's attributes, MySQL types, keys, nullability, and domain constraints—plus normalization work including FDs, candidate keys, and decomposition to 3NF/BCNF with justification. A traceability matrix linking requirements to ER constructs to enforcement is needed, along with division of work and risk notes, all within an 8-12 page limit.
> 
> Looking at the rubric weighting, ER design plus relational mapping plus keys plus data dictionary carries three times the weight of requirements or normalization alone, so I should concentrate most of my effort there. I'm also checking whether earlier administrative steps like Canvas group sign-up and KCube registration have already been completed given the topic selection mentioned.
> 
> Beyond KCube registration, environment setup with DBeaver and MySQL is required before implementation, though drafting some DDL early could help validate that the data dictionary is realistic even though it isn't formally submitted until Stage 2. For tooling, I'm considering GitHub for version history and contribution evidence, Overleaf or Word for the proposal document itself, and draw.io or ERDPlus for Chen-notation ER diagrams since the course likely expects that notation over crow's foot style.
> 
> I'm also thinking about following the textbook's notation consistently with a legend, using DBeaver's reverse-engineering feature to generate relational schema diagrams after drafting DDL, validating the JSON metadata file with a linter, and making sure the final zip file is structured correctly with the top-level folder intact and no stray system files like .DS_Store.
> 
> For the actual domain design, I want to give illustrative examples rather than a complete solution—a few sample business rules, one use case, one management question, a partial candidate entity list framed as brainstorming, a sample data dictionary row, and a quick FD/decomposition example—so the student understands the format without me essentially writing their whole proposal for them.
> 
> Thinking through a concrete fictional scenario to anchor the samples: a "GreenTerrace Farm Co-op" vegetable subscription service in Yuen Long, with roles like members, farm admin staff, distribution coordinators, and pickup points, which gives natural entities and relationships to draw examples from.
> 
> I'm sketching the core business object as a membership Subscription tied to enrolment/renewal and weekly box collection against a quota, matching the W04 requirement for eligibility rules and tracking benefit usage. I'm drafting possible entities like Member, Plan, and Season/Term with their attributes to use as sample data for the exercise.
> 
> Beyond that, I'm considering PlanOffering linking plan and season, Subscription with a recursive renewal link back to prior subscriptions, PickupPoint, DistributionRun for weekly collection events, and a BoxCollection entity tracking per-subscription usage status (collected/skipped/missed) per run, while weighing whether Product/BoxContent details fall outside scope.
> 
> I'm also thinking about a general entitlement model: Payment records tied to subscriptions, plus PlanEntitlement defining benefit quotas per plan (box pickups, skip credits, egg add-ons, farm visit passes) with BenefitUsage logging actual consumption. And I'm sketching eligibility rules—one active subscription per member per season, and renewal only permitted within a defined window and contingent on no outstanding balance.
> 
> Now I'm extending these rules further: renewals must roll into the immediately next season and stay tied to the same member, usage counts (collected plus skipped boxes) must stay within plan quotas, usage dates must fall inside the subscription's validity window, and pickups must occur only at the assigned pickup point, which also has its own per-day capacity constraint.
> 
> I'm also drafting value constraints and cardinality rules — positive prices, box quotas capped between 1 and 52, valid status values, end dates after start dates, and each subscription tied to exactly one member and plan while members can have zero or many subscriptions. Then I'm sketching three sample management questions covering renewal rates per plan by season, pickup points with the highest missed-box rates, and subscribers who've underused their plan entitlements.
> 
> Now I'm working through additional management questions on lapsed members and revenue per plan/season, plus five use cases spanning enrolment, renewal, weekly box tracking, cancellation, and balance retrieval — while making sure W04 stays distinct from W03's capacity concerns by focusing on enrolment and quota logic instead.
> 
> I'm also sketching a normalization example using a universal BoxUsage relation with functional dependencies tying subscription, member, plan, and point attributes together, showing how the candidate key {sub_id, week_date} leads to partial dependencies that push it only to 1NF before decomposition. I'm weighing whether to include this worked example as a teaching illustration, since it's useful pedagogically but I don't want it mistaken for their actual deliverable — I should flag that it's illustrative only.
> 
> I'm brainstorming other non-obvious functional dependencies to discuss, like price depending on plan and season rather than subscription, or pickup points tied to specific weekdays, plus a possible BCNF example with distribution runs having two overlapping candidate keys. I'm also noting derived attributes like remaining quota and end date, composite attributes like name and address, and multivalued attributes like phone numbers or dietary restrictions as things worth covering.
> 
> For multivalued dietary exclusions, I'm thinking those belong in their own table. I'm also considering weak entities like a box collection record identified by subscription and week, or a distribution week weak on season, plus a recursive subscription-renewal relationship that could be mapped with a nullable unique foreign key, and a possible ternary associative entity linking plans, benefit types, and quota.
> 
> Since MySQL CHECK constraints can't reference other tables or CURDATE(), I'm noting that cross-table business rules like renewal eligibility or quota enforcement need to be handled through explicit SQL checks in transactional logic rather than declarative constraints, with triggers mentioned only as optional if covered in the course.
> 
> Actually, a slot table could work elegantly: pre-generate EntitlementSlot rows equal to quota at enrolment, then force each Usage to reference a unique unused slot, so the FK plus UNIQUE constraint itself enforces the quota limit without any trigger logic.
> 
> This feels like a worthwhile hint to leave rather than fully design out. I'm also noting that snapshotting price_paid/quota in Subscription isn't a normalization violation since it's historical data tied to a point-in-time plan, which is a good independent design point — and that date validity (end_date > start_date) can be handled with a simple same-row CHECK, with start_date stored separately if subscriptions can start mid-season.
> 
> I'm also thinking about renewal integrity: a UNIQUE constraint on renewed_from_sub_id prevents double-renewals, plus a CHECK ensuring a subscription can't reference itself as its own renewal. For the work split, I'm sketching that Member A handles requirements/business rules/normalization while Member B handles the ER diagram and relational mapping, but both should cross-review each other's work and be ready to explain the full design live, with deadlines around Oct 12 signup and Oct 26 Stage 1 submission in 2026.
> 
> Since nothing's started yet, I want to lay out a roadmap: first confirm Canvas group and KCube registration and set up a shared workspace (repo, templates, AI usage log); then build a requirement checklist from the rubric, noting ER/relational components carry 3 of 5 marks; then do domain research to frame a fictional organization's roles, events, and scope into a scenario fingerprint; then draft at least six business rules from that scenario.
> 
> Next I'd plan out eight to ten business rules with a template tracking ID, statement, type, and what they affect, followed by four use cases with actors, triggers, and steps, and at least four management questions designed so they can later support the eight queries expected in Stage 2 — joins, group by/having, correlated subqueries, NOT EXISTS, null handling. Then I'd move into building the conceptual ER model by identifying entities, attributes, and relationships through noun-verb analysis, deciding on weak entities, recursion, multivalued and derived attributes, and picking a tool like draw.io with Chen notation.
> 
> For draw.io specifics, I'd note the entity-relation shape library and notation conventions — double rectangles for weak entities, double diamonds for identifying relationships, double lines for total participation, underlines for keys, dashed underlines for partial keys, double-border ovals for multivalued attributes, and dashed ovals for derived ones — plus export settings and how to split large diagrams for legibility. Then I'd walk through mapping the ER model to relational schema using Elmasri's standard seven-step algorithm covering strong/weak entities and all relationship cardinalities, followed by drafting a data dictionary per table with attribute names, MySQL types, key designations, nullability, defaults, and domain constraints.
> 
> I'm now thinking through MySQL type choices (DECIMAL for money, DATE vs DATETIME, ENUM vs VARCHAR+CHECK), noting MySQL's CHECK constraint limitations, and recommending prototyping the DDL in DBeaver against MySQL 8.4 to validate syntax early. From there I'd move into functional dependencies and normalization — listing FDs, computing candidate keys via closure, checking 2NF/3NF/BCNF, and verifying lossless, dependency-preserving decomposition with a worked example — before building a traceability matrix linking requirements to ER constructs and their enforcement mechanisms.
> 
> For the remaining steps, I'm sketching out the work-division plan with risk mitigations, the structure for assembling proposal.pdf with a page budget and consistency checks across ER diagram, schema, dictionary, and rules, plus sample metadata.json and ai_usage.md templates, finishing with packaging and zip submission instructions for both Windows and macOS.
> 
> Given it's a two-person team with the same deliverables as a four-person group, I'm noting the scope needs to stay manageable—probably targeting 6-7 tables—and I'm planning to respond thoroughly in Chinese with English technical terms, using headers, tables, and code samples to keep everything organized despite the length the user wants.
> 
> I'm noting realistic CSA patterns like fixed-week seasons, share sizes, skip weeks with limits, and pickup points to ground the domain research step, then planning to write the Chinese-language answer covering team expectations, Stage 1 rubric weights, and AI usage rules.
> 
> For the roadmap, I'm drafting Step 0 covering administrative setup: Canvas group registration with exact naming and deadline, KCube signup for the session slot, and setting up a shared GitHub repo with a structured folder layout for proposal drafts, diagrams, notes, prototype SQL, and an AI usage log to track contributions and tool usage.
> 
> I'm also thinking about the document collaboration tool—Overleaf's free plan allows one collaborator, which fits a two-person team, or alternatives like Word/Google Docs with track changes—plus setting up a meeting log and starting the AI usage notes early, and finally installing MySQL 8.4.11 with DBeaver per the course setup guide.
> 
> Though Stage 1 doesn't require SQL submission, prototyping the DDL would help validate data types and constraints from the data dictionary, verifying the MySQL version matches 8.4.11. I want to build a self-check checklist from Section 5.1 and Appendix B against the rubric weights, noting that ER diagram, mapping, keys, and data dictionary together account for 60% of the grade, and I should also anticipate Stage 2 requirements like the eight query types, views, transactions, indexes, and negative tests now since the schema gets locked in at Stage 1.
> 
> Now I'm researching real CSA (community-supported agriculture) models — looking at Hong Kong local farms with weekly vegetable basket subscriptions and overseas CSA handbooks — to identify common concepts like season length, share sizes, upfront payment, pickup/delivery, skip-week quotas, renewal priority, and credits, while keeping all actual data fictional and deciding on the organization, roles, core business objects, and distinctive policies to model.
> 
> I'm settling on W04's core being enrolment and renewal with eligibility/validity rules plus benefit/quota usage tracking, deliberately excluding W03's capacity/waitlist logic and W05's inventory concerns to keep scope tight. I'm also sketching an illustrative sample fingerprint table (organization, roles, business object, distinctive policy, excluded processes) marked as an example for the team to adapt with their own decisions, and starting to brainstorm a list of open design questions for the team to resolve.
> 
> Now I'm listing the questions that will shape the business rules: subscription term length (seasonal vs. rolling monthly), package variations (box size, frequency, quota), whether there's one benefit type or several (weekly box, skip-week credits, add-on eggs, farm visit slots), renewal eligibility criteria (time window, payment status, prior usage rate, loyalty priority), validity constraints (pickup location, active subscription period), and how to handle leftover benefits upon cancellation. These feed into step three, drafting at least 6-10 business rules covering cardinality, participation, and uniqueness types.
> 
> I'm working through additional rule categories like value/domain constraints, temporal validity, cross-table eligibility, aggregate quotas, and state transitions. Each rule needs an ID, a precise testable statement, its type, where it's enforced, and how it's tested — favoring measurable language over vague phrasing. I'm drafting sample rules: one requiring each subscription to link to exactly one member and plan with proper foreign key constraints, another limiting members to one subscription per season via a unique constraint, and a third defining renewal eligibility based on timing windows and prior subscription status.
> 
> For that third rule, since MySQL's CHECK constraints can't reference other tables, I note it needs enforcement through an explicit SQL check within the renewal transaction itself, with a test verifying that late renewal attempts insert zero rows. I'm also sketching a quota rule capping skip usages per subscription against the plan's allowance, plus simpler value constraints like positive pricing and bounded box quotas — deciding to fully flesh out three rules with varied types while leaving the rest as prompts, and noting MySQL's broader CHECK constraint limitations around subqueries, date functions, and foreign key cascade interactions.
> 
> Now I'm mapping out relevant MySQL error codes for test planning — duplicate key, FK violations on child/parent deletion, CHECK constraint violations, and null column errors — confirming their exact codes and names. Then I move to designing four operation use cases covering enrollment, renewal, benefit usage recording, and cancellation or entitlement retrieval, using a standard template (actor, trigger, preconditions, flow, affected tables with CRUD, rules checked, failure outcomes), with renewal fully worked out as a sample and the rest just named, while noting renewal should double as the Stage 2 transaction involving inserting a new subscription record.
> 
> Next I'm planning management questions, requiring at least one aggregate query and one spanning three or more tables, following the doc's Question/Tables/Analysis/Decision format, and mapping these forward to Stage 2 techniques like multi-table joins, grouping with having, correlated subqueries, and null handling cases — with the renewal rate per plan fully worked as a sample and other ideas like lapsed members, early quota exhaustion, and revenue by plan sketched only in direction.
> 
> I'm fleshing out MQ1 completely: comparing Spring 2026 subscriptions to Summer 2026 renewals using a self-join on the subscription table via renewed_from, grouping by plan, computing renewal rate as a ratio of counts, and flagging plans below 60% with a synthetic example of 45% for half-share — while being careful to frame the conclusion as correlation, not causation. Then I'm moving into the conceptual ER diagram design step, starting with identifying entities.
> 
> First I'm brainstorming candidate entities and attributes by extracting nouns from the business rules and use cases — Member, Plan, Season, Pickup point, Benefit type, and Payment as likely entities, while flagging "box size" as an attribute of Plan and weekly distribution as a possible weak entity tied to Season, leaving some judgment calls open for the reader to decide. Then I'm sketching relationships with verb phrases, cardinality, and participation constraints, like Member holds Subscription as a 1:N relationship with Member being partial and Subscription total, before considering advanced constructs like a recursive "renews" relationship on Subscription itself.
> 
> I'm filling out the rest of the ER modeling toolkit: weak entities like DistributionWeek identified by Season plus week number, associative entities like PlanEntitlement linking Plan and BenefitType with a quota attribute, multivalued attributes for dietary exclusions, composite attributes for name and address, derived attributes like remaining quota and end date, and a note that specialization is probably unnecessary here unless it adds real value. Then I move into practical draw.io instructions — opening the app, enabling the Entity Relation shape library, and listing out the ER notation shapes like weak entity, key attribute, multivalued and derived ellipses, and relationship diamonds.
> 
> Checking what shapes draw.io's Entity Relation library actually includes, and confirming it covers Chen notation elements like weak entities, identifying relationships, and attribute types alongside crow's foot notation and ER line endings. I'm also noting how to set total participation using double lines via the Format panel's Line settings.
> 
> For double-line edges, editing the style to add `shape=link;` renders a parallel double line in draw.io, which works as an alternative to using min/max cardinality notation. I'd also add cardinality labels by double-clicking edges to type "1"/"N", and for export I'd use File → Export as PNG/PDF/SVG while keeping the .drawio source in the repo.
> 
> Other tool options worth mentioning include ERDPlus for Chen-style diagrams (with caution around trusting its auto-conversion to relational schema), Lucidchart, dbdiagram.io using DBML for crow's foot notation, and DBeaver for physical ER diagrams once DDL exists. For legibility, I'd suggest landscape orientation, readable font sizes, splitting into an overview diagram plus detailed attribute lists if needed, and including a legend. I'm also sketching a sample ER fragment in text notation showing Member-Subscription cardinality relationships to illustrate the concept.
> 
> Now I'm working through the ER-to-relational mapping algorithm step by step: strong entities become tables with chosen primary keys and candidate keys as unique constraints, weak entities get composite keys combining the owner's PK with a partial key, 1:1 relationships place a foreign key on the total-participation side, 1:N puts the FK on the many side, and M:N, multivalued, and n-ary relationships each require their own junction tables with composite keys.
> 
> I'm sketching sample table definitions, like a Subscription table with foreign keys to Member, Plan, Season, and PickupPoint, plus a self-referencing renewal link, alongside a SubscriptionUsage table, and I'm also planning a mapping table that documents each ER construct, its relational result, and notes, with the option to visualize the final schema as an ER diagram in DBeaver after running the prototype DDL.
> 
> Now I'm turning to the data dictionary step, defining for every table the column names, MySQL types, keys, nullability, defaults, constraints, and descriptions—deciding on conventions like unsigned auto-incrementing integer IDs, DECIMAL for money instead of FLOAT, DATE/DATETIME for temporal fields, VARCHAR with CHECK constraints or ENUM for statuses, VARCHAR for phone numbers to preserve leading characters, and TINYINT/BOOLEAN with CHECK for flags, while making sure foreign key types match their referenced primary keys exactly.
> 
> I'm thinking a full sample dataset for the Subscription table (around nine rows) would best illustrate the design, then I'd validate the schema by prototyping CREATE TABLE statements in DBeaver, running them with Execute Script or Execute Statement shortcuts, and testing edge cases like inserting a row that violates a CHECK constraint to confirm it throws the expected MySQL error. I'm weighing whether to show a tiny DDL snippet demonstrating a CHECK constraint limitation (like one referencing CURDATE() failing with a specific error code) to keep things illustrative without overstepping into doing the core implementation myself.
> 
> I'm not fully certain of the exact error number for that CHECK function restriction, so I decide it's safer to just describe that MySQL will reject the table creation and let them note whatever error code appears rather than asserting a specific number. Now I'm shifting to the next step, which covers functional dependencies and normalization.
> 
> For each table I'll derive non-trivial FDs from the business rules themselves, compute candidate keys via attribute closure, determine the normal form, and decompose when violated—checking losslessness and dependency preservation along the way. The clearest way to present this is probably to start from a flat, unnormalized relation resembling the farm's current spreadsheet and walk through the decomposition to 3NF/BCNF step by step.
> 
> For a sign-up sheet relation containing member, email, season, plan, and pickup point attributes, I'm mapping out the functional dependencies the business rules imply: member_id determines name and email, email uniquely identifies the member back, season_id determines its start date, and plan_code determines quota and price—though price might actually depend on the combination of plan and season rather than plan alone, which is a subtler dependency worth highlighting. I'm also noting that the member-season pair determines the chosen plan and pickup point, and that pickup point determines its district.
> 
> From here I'm computing the candidate key as {member_id, season_id} (and equivalently {email, season_id}), showing the relation is in 1NF but violates 2NF due to partial dependencies, then decomposing into Member, Season, Plan, PlanPrice, PickupPoint, and Subscription tables—checking each split is lossless (splitting on a determinant that becomes the new table's key) and dependency-preserving (each FD contained within one resulting table). I want to frame this clearly as a teaching example so students understand they need to rederive the decomposition themselves from their own final rules and tables, rather than copying this structure directly, and I'm thinking about how snapshot/historical attributes like price actually paid fit into this scheme.
> 
> I'm noting that price_paid in Subscription isn't a transitive dependency violation since it's a point-in-time snapshot that can legitimately diverge from the current plan price due to discounts or later price changes—so plan_code→price doesn't hold across time, and I need to explain this nuance rather than ignore it or invent FDs that don't exist. I also want to flag that if a surrogate sub_id key is added, {member_id, season_id} still functions as a UNIQUE candidate key.
> 
> Now I'm building out a traceability matrix with columns for requirement ID, summary, ER construct, relation/constraint, enforcement mechanism, and planned test, using sample rows tied to BR1-BR3 and test IDs consistent with earlier naming conventions, followed by a two-person work division plan covering requirements/normalization/traceability versus ER/mapping/data dictionary/DDL, with mutual cross-review built in.
> 
> I'm extending the division plan into Stage 2 implementation (data/queries vs schema/tests/transactions) and compiling a risks table covering issues like cross-table rules needing SQL checks instead of simple CHECK constraints, scope creep mitigation, workload prioritization for two people, non-reproducible date-dependent queries needing a fixed reference parameter, and potential DDL/FK pitfalls. Then I'm sketching the actual proposal.pdf outline with a page budget—cover page details, scenario scope, requirements, ER model section, and moving into the relational model section.
> 
> For the rest of the outline, I'm budgeting space for the data dictionary (deciding whether to keep it in the main body or appendix), functional dependencies and normalization, the traceability matrix, and the work plan/risks section, followed by references and appendix. I'm also noting tool choices like Overleaf with LaTeX tables and figures, or Word with proper styles, making sure fonts are embedded and diagrams stay legible.
> 
> Now I'm checking consistency across all deliverables—naming conventions for tables and columns should match between the ER diagram, schema, data dictionary, and traceability matrix, using snake_case and singular table names throughout in English. For metadata.json, I'm preparing a sample with stage 1 and team details, validating the JSON structure, and noting that student IDs should be strings while fields like approval_reference should be null rather than quoted. Then for ai_usage.md, I'm drafting a template documenting this conversation with Claude for planning Stage 1.
> 
> For the final packaging step, I'm laying out the folder structure with metadata.json, proposal.pdf, and ai_usage.md inside a properly named folder, then explaining how to zip it correctly on Windows versus macOS—noting that Finder's built-in compress feature adds unwanted __MACOSX and .DS_Store files, so using the terminal zip command is cleaner.
> 
> I'm also noting the submission deadline and the need to verify the upload by downloading and reopening the file, plus a quirky checklist requirement about acknowledging an instructor name that seems to differ from the actual instructor, HUANG Xiao.
> 
> I'll flag that acknowledgement line for the team to double-check against the original document, since it mainly applies to the Stage 2 report rather than the Stage 1 proposal. I'm also noting final design reminders: emphasize the interacting business rules around eligibility, validity, and quota renewal chains for technical depth, while avoiding superficial padding like unnecessary tables, inconsistent capacity values, or non-reproducible date functions in queries.
> 
> Since the user doesn't want a strict timeline, I'll keep dependencies between steps implicit instead, noting that steps 3-5 iterate alongside step 6. I'll open with a brief, non-preachy reminder about academic integrity — that the examples are for format reference only, the actual design must be original, and this conversation should be logged in ai_usage.md. Given the request for maximum detail, I expect this response to run long, so I'll write the proposal samples in English with Chinese explanations, starting with a partial fingerprint example.
> 
> I'm drafting a sample case for a fictional farm co-op selling vegetable-box subscriptions, defining the roles (member, membership officer, pickup coordinator, farm manager), the core business object (a seasonal subscription entitlement), and its key events — enrolment, renewal, and redemption — along with a distinctive policy around renewal windows, payment status, and skip-credit rules.
> 
> I need to swap "Tai Lung" for a clearly fictional name since it's a real government farm, so I'm renaming it "Green Ridge Farm Co-op (fictional)." I'm also sketching exclusions (payment gateway, crop planning, delivery routing, waiting lists, auto reminders, concurrency) and starting to write sample business rules, like one establishing that every subscription belongs to exactly one member and exactly one plan.
> 
> Now I'm drafting more business rules: enforcing one subscription per member per season via a uniqueness constraint, and defining a renewal rule requiring same member, next consecutive season, a specific date window around the prior subscription's end date, no outstanding balance, and a limit of one renewal per subscription — modeled as a recursive 1:1 "renews" relationship with a unique foreign key.
> 
> Since MySQL CHECK constraints can't reference other rows or tables, I'm handling this through a conditional INSERT...SELECT within the renewal transaction, which would simply affect zero rows if a renewal falls outside the valid window. I also note that checking "immediately following season" requires some season ordering mechanism, like a sequence number.
> 
> Beyond that, I'm sketching other rule categories to cover: value constraints (positive price, valid quota range, end date after start date), quota limits on skip usage, validity windows for usage weeks, status transition logic (pending to active to completed/cancelled, with no usage allowed once cancelled), pickup point restrictions, and payment totals not exceeding the subscription price.
> 
> For the renewal use case sample, I'm outlining the actor (membership officer), trigger (member requests renewal), preconditions (existing active/completed subscription, open next season), and main flow steps: look up the previous subscription, check business rules, insert the new subscription record linked to the prior one, record the deposit payment, and handle the rollback case where failed checks mean no rows get inserted — a good candidate for later transaction testing. I'm also noting that the renewal-rate-per-plan query example involves a self-join combined with a left join for null handling, plus grouping and having clauses.
> 
> Now I'm brainstorming candidate entities for the ER model — members, plans, seasons, subscriptions, pickup points, benefit types, plan entitlements, usage/redemption, payments — while flagging produce/box contents and delivery drivers as out of scope, and leaving the final entity decisions open for the team to confirm. I'm also starting a data dictionary table for the Subscription entity, defining columns like the surrogate primary key, member foreign key tied to a composite constraint, and the season reference, along with their types, nullability, and descriptions.
> 
> Still writing data dictionary... I'm catching that referencing an auto-increment column in a CHECK constraint for the renewal self-reference won't actually work in MySQL, so I need to reconsider how to enforce that rule.
> 
> Actually, this self-renewal rule can't even trigger as a constraint violation during insert, since the new sub_id isn't known yet when inserting—so the check would need to happen at the application level or be documented as a logical invariant rather than enforced via CHECK.
> 
> Now I'm drafting the traceability matrix, mapping each business rule to its ER construct, the specific relation or constraint that implements it, how it's enforced in the database, and the planned negative test case to verify it—like checking that subscriptions require a valid member via foreign key, or that the member-season pairing stays unique.
> 
> For BR3 I'm noting the limitation that a direct insert bypassing the stored procedure wouldn't be blocked since there are no triggers, so I'm planning boundary tests around the renewal window and a rollback test for the transaction. Now I'm starting the work plan table assigning tasks like fingerprinting and business rule mapping to leads and reviewers.
> 
> Looking at the stage 2 preview, I'm splitting work so one person handles schema and indexing with negative tests while the other handles data loading and queries, with both collaborating on views, transactions, and the README/presentation.
> 
> I'm also drafting the risk table, flagging that cross-table rules can't be expressed as plain CHECK constraints in MySQL, so I'm mitigating with conditional INSERT…SELECT inside transactions plus documented limitations and dedicated tests for each rule, and I'm noting scope creep into inventory/warehouse areas as another risk to watch.
> 
> I'm fixing a reference date like '2026-11-01' for all date-dependent queries so results stay reproducible, and designing seed data deliberately around edge cases like rejected HAVING groups and NULLs so testing coverage doesn't suffer, plus planning for one member's unavailability by having both review each other's parts.
> 
> Writing metadata JSON...
> 
> Now I'm drafting the AI usage declaration table, logging each tool used, its purpose, which files it touched, whether we accepted or rejected its output, and how we verified it.
> 
> I should use placeholders like "[按实际情况填写]" rather than presuming specifics. For checking FD closure, I could just note doing it manually with the attribute closure algorithm rather than relying on external tools.
> 
> For the DBeaver portion, I'll briefly note creating a connection, setting up the database (e.g. comp2411_g0xx), opening a SQL editor to run scripts, and using the ER Diagram tab from the database view to visualize the schema.
> 
> Export it via the diagram toolbar's save icon as a PNG, and recall that Ctrl+Enter runs a single statement while Alt+X executes the whole script. Important caveat: DBeaver's ER diagram is a physical/relational schema view, not a true Chen conceptual ER model, so it can illustrate the relational schema but shouldn't replace the conceptual ER diagram requirement.
> 
> The acknowledgement name mentioned in the guide looks odd and doesn't match the actual instructor, so I should flag that students verify this against the original PDF and confirm with the TA/instructor before including it verbatim in the Stage 2 report's Acknowledgements section.
> 
> Now I'm drafting an overview table mapping out all 16-17 steps of the roadmap, from administrative setup through domain research, business rules, use cases, ER diagrams, data dictionary, normalization, traceability matrix, and final packaging—noting that steps 3-9 are iterative since the ER diagram often requires revisiting the business rules. I'll write this in Chinese with English examples, keeping the formatting clean.
> 
> I'm also drafting step-by-step instructions for using draw.io to build the ER diagram—opening the app, enabling the Entity Relation shape library, and using entity/attribute/relationship shapes, with workarounds for shapes not available in the default library.
> 
> For primary keys I'll note using Ctrl+U to underline attribute text, and for weak entity partial keys I'll suggest either a special weak key attribute shape or a documented convention like dotted underline since draw.io doesn't support that natively.
> 
> For connections I'll drag from blue edge arrows, mark total participation with double lines via Edit Style adding shape=link, and add cardinality labels like 1/N or (min,max) by double-clicking the line. For export I'll go File → Export as → PNG or PDF with higher zoom, and commit the source .drawio file to Git — that should be sufficient, though I should double-check the notation matches what was used in lectures.
> 
> I also need to use LaTeX arrows for functional dependencies, make sure every business rule maps into the traceability matrix affecting model, SQL, or testing, state the normal form for each final relation per the Stage 1 rubric, keep things within 8-12 pages, and add a "Difficulty rationale" row to the fingerprint explaining things like how renewal eligibility combines temporal, payment, and seasonal factors.
> 
> I'm also considering adding an optional advanced thinking prompt about whether quota enforcement could rely on constraints alone versus pre-generated slots, as a deeper design question for the reader to explore.
> 
> On the reproducibility concern, I want to flag that Stage 2 queries need deterministic results, so avoiding functions like CURDATE() matters and the design should bake in a "reference date" concept as a tip under risks.
> 
> Now I'm ready to draft the actual roadmap document itself, starting with the title.
> 
> AI使用若主要由AI生成会导致整个项目判零分，所以必须把这次对话如实记录进ai_usage.md，第14步有模板可以参考。
> 
> 接下来我要给出完整的概览表和具体步骤，核对一下细节是否准确：Canvas路径按文档应是"People → Group"，KCube那边则是"My Courses → SignUp"，文本回复里要填"Group N"这样的格式。
> 
> 截止时间是Canvas和KCube都在10月12日23:55，第一阶段则是10月26日23:55。我还得整理MySQL的错误代码表，包括1048（NOT NULL违反）、1062（重复键）、1451（无法删除父记录）、1452（外键子记录失败）和3819（CHECK约束违反）。
> 
> 关于CHECK约束的限制，根据Percona和MySQL文档，不能使用子查询、不能引用其他表、不能使用存储函数或用户定义函数、不能使用像CURDATE()/NOW()这类非确定性函数、不能用于AUTO_INCREMENT列，也不能用在带有外键级联操作（ON UPDATE/ON DELETE CASCADE/SET NULL）的列上。
> 
> DBeaver创建数据库的操作是右键点击连接下的"Databases"节点，选择"Create New Database"。现在我要准备一个范式化的英文示例，用代码块展示初始表结构。
> 
> 我在构建一个规范化的例子：从一个未规范化的会员报名表开始，推导出函数依赖关系（会员ID决定姓名邮箱、邮箱决定会员ID、季节ID决定开始日期、套餐代码决定箱子配额、套餐+季节决定价格、会员+季节决定套餐和取货点、取货点决定所在区域），然后计算闭包确定候选键是{会员ID, 季节ID}和{邮箱, 季节ID}，并说明初始关系处于1NF但未达到2NF（因为姓名部分依赖于键），接着开始分解出Member和Season等子表。
> 
> 我继续分解出Plan、PlanPrice、PickupPoint和Subscription等子表，并验证这种分解满足无损连接性（通过二元分解测试）和依赖保持性（每条函数依赖都完整包含在某个子关系中），同时确认每个子关系都达到BCNF标准，因为所有决定因素都是超键。我还提醒自己函数依赖必须来自实际业务规则而非为了分解而人为编造——比如如果价格不随季节变化，FD5就应该简化为套餐代码直接决定价格。最后我在考虑是否要补充讨论价格快照的问题，并打算完整地组织这个例子，尽量详尽但不冗余。
> 


# D17-W04 Stage 1 Roadmap（2人组）

**场景：** Local farm subscription and distribution + Membership or subscription

## 开始前的三点提醒

1. **2人组和4人组要交的东西完全一样**，所以范围要收住。建议设计6–7张有实际作用的表，把精力花在"几条规则互相约束"上，不要靠堆表。Stage 1 共5分，其中 ER 模型、关系映射、键和数据字典占3分，是重点。
2. **下面的英文样例只是为了展示格式和应该写到多具体，不要直接搬进 proposal。** 课程允许用 AI 做解释和提建议，但设计和报告必须是你们自己写的。如果项目"主要由 AI 生成"，整个项目20分全部归零。所以样例我故意只给一部分，剩下的需要你们自己做设计决定。
3. **这次对话本身也要写进 `ai_usage.md`**（第14步有模板）。

---

## 总览

| 步骤 | 内容 | 产出 |
|---|---|---|
| 0 | 行政手续 + 协作环境 + 软件环境 | Canvas/KCube 登记确认、Git 仓库、能用的 MySQL 8.4.11 |
| 1 | 拆解要求，做自检清单 | `checklist.md` |
| 2 | 领域调研 + 场景定位 | Scenario fingerprint 草稿 |
| 3 | 业务规则（≥6条） | Business rules 表 |
| 4 | 操作用例（4个） | Use case 表 |
| 5 | 管理问题（≥4个） | Management questions |
| 6 | 概念设计 ER 图 | `.drawio` 源文件 + 导出的 PNG/PDF |
| 7 | ER→关系映射 | 关系模式 + 映射说明表 |
| 8 | 数据字典 + 原型 DDL 验证 | 每张表的数据字典 |
| 9 | 函数依赖与范式化 | FD、候选键、范式分析 |
| 10 | 可追溯矩阵 | Traceability matrix |
| 11 | 分工计划与风险 | 分工表 + 风险表 |
| 12 | 撰写、排版 proposal.pdf | proposal.pdf（8–12页） |
| 13–15 | metadata.json、ai_usage.md、打包提交 | Stage 1 ZIP |
| 16 | 提交前最终自检 | — |

> 第3–9步会来回修改：画 ER 图时常会发现规则写得不够准，做范式化时也可能发现漏了实体。这很正常，每次改动记在会议笔记里，Stage 2 写 change log 时用得上。

---

## 第0步：行政手续与环境准备

### 0.1 Canvas 分组（截止 10月12日 23:55）
- 两人都要进入 **People → Groups**，加入**同一个** group。加入前把组名完整读一遍，组名里就包含你们的展示时间和教室，两人都必须能到场。
- 把组名**一字不差**地复制下来存好（例如 `Group 37, Nov 25, 15:54-15:59, TU101`），以后 metadata、封面、展示首页都要用。
- 推出 Group ID：Group 37 → `G037`（G加三位数字）。

### 0.2 KCube 登记 Scenario ID
- 由一人登录 KCube，进入 **My Courses → SignUp**，登记 `D17-W04`。**Text response 填 `Group 37`**（换成你们的组号）。
- 把确认页截图存进仓库的 `notes/` 目录。如果被别的组抢先，就换一个还空着的组合。

### 0.3 协作环境
- **Git 仓库**：在 GitHub 建一个 Private 仓库，把对方加为 collaborator。指南第3.3和第8节都把"working history"当作贡献和 AI 使用情况的证据，所以每次提交要有意义（例如 `Add BR1-BR4 draft`），不要最后一次性上传。
- 建议目录结构：
  ```
  comp2411-project/
    stage1/
      proposal/        # Overleaf 源码或 .docx
      diagrams/        # .drawio 源文件 + 导出图
      notes/           # 会议记录、领域调研、截图
      prototype_sql/   # 用来验证数据字典的草稿 DDL（Stage 1 不提交）
      metadata.json
      ai_usage.md
  ```
- **写作工具**（二选一）：
  - **Overleaf**（LaTeX）：表格多时排版好看，可以同步到 GitHub。免费版协作人数有限，2人组一般够用。
  - **Word / Google Docs**：打开修订模式，最后导出 PDF。
- **会议记录** `notes/meetings.md`：每次讨论写3–5行，记下"决定了什么、为什么"。这些在 Stage 2 写 change log 和 contribution 时都会用到。

### 0.4 软件环境
Stage 1 不用提交 SQL，但**建议现在就装好**，第8步要用它验证数据字典。
1. 按 `COMP2411_DBeaver_MySQL_Setup.pdf` 安装 MySQL Community Server **8.4.11** 和 DBeaver Community。
2. 在 DBeaver 里新建连接，在 SQL 编辑器执行：
   ```sql
   SELECT VERSION();
   ```
   预期输出：`8.4.11`
3. 本地新建一个练习库，例如 `comp2411_g037`（在 Databases 节点上右键 → Create New Database）。

---

## 第1步：拆解要求，做 Stage 1 自检清单

把指南第5.1节、附录 B 和 Stage 1 评分表整理成一个可以逐项打勾的清单，放在 `checklist.md`：

| # | 要求 | 位置 | 负责人 | 状态 |
|---|---|---|---|---|
| 1 | 封面：Title、Group ID、完整 Canvas 组名、Scenario ID、team size、成员姓名和学号 | 封面 | | ☐ |
| 2 | Fingerprint：business object、workflow fit、scope、exclusions、difficulty rationale | §1 | | ☐ |
| 3 | ≥6条业务规则，覆盖 cardinality、participation、uniqueness、value | §2 | | ☐ |
| 4 | 4个用例（create/change/retrieve） | §2 | | ☐ |
| 5 | ≥4个管理问题，其中至少1个聚合、至少1个涉及≥3张表 | §2 | | ☐ |
| 6 | ER 图：实体、属性、候选键/主键、有名字的关系、基数、参与度 | §3 | | ☐ |
| 7 | 用到的高级构造都写了理由 | §3 | | ☐ |
| 8 | 映射说明（M:N、弱实体等） | §4 | | ☐ |
| 9 | **每张表**的数据字典 | §5 | | ☐ |
| 10 | FD、候选键、初始范式、3NF/BCNF、无损连接、依赖保持 | §6 | | ☐ |
| 11 | 可追溯矩阵 | §7 | | ☐ |
| 12 | 分工计划 + 主要实现风险 | §8 | | ☐ |
| 13 | metadata.json、ai_usage.md、ZIP 命名和目录结构 | — | | ☐ |

**Stage 2 的要求要现在就考虑进去**，因为 Scenario ID 和 fingerprint 在 Stage 1 提交后就锁定了。Stage 2 需要：8个查询（多表连接、GROUP BY/HAVING、相关子查询或 NOT EXISTS、NULL 处理）、1个 view、1个能演示提交和回滚的事务、1个有理由的索引，以及 negative tests。设计时要确保这些都"有东西可做"。

---

## 第2步：领域调研与场景定位

### 2.1 调研真实的 CSA（社区支持农业）模式
- **搜索关键词**：`CSA member handbook skip week`、`community supported agriculture share renewal`、`香港 有機菜 每週 菜籃 訂閱`
- **我查到的常见做法**（可作参考）：
  - 按季订阅：一季固定若干周，通常预付。
  - 份额分大小：full share / half share。
  - 每周到指定地点自取或配送。
  - "跳过周"有次数上限：例如一季最多跳过2周，跳过的那份折成积分；也有农场允许暂停5周。
  - 跳过要在截止时间前申请。
  - 可以加购（鸡蛋、花等）。
  - 香港本地也有农场用 CSA 模式做每周菜篮订阅，取货点在市区，或者直接到农场取。
- 把来源和要点记在 `notes/domain_research.md`，正文用到的放进 References。**数据库里只能用虚构数据。**

### 2.2 先回答这些设计问题
你们的回答就是独创性的来源，评分看的是"独立的设计决定"，不是题材是否少见。

1. **订阅期**：按季（例如一季12周）还是按月滚动？订阅可以在季中开始吗？
2. **套餐差异**：箱子大小？每周还是隔周？每季多少箱？
3. **权益类型**：只有"每周菜箱"一种，还是多种（菜箱 + 跳过额度 + 加购额度 + 农场参观名额）？
4. **入会/续订资格**：有没有续订时间窗口？欠费能不能续？是否只能续到紧接着的下一季？老会员有没有优先权？
5. **有效性**：权益是否只能在订阅有效期内、在指定取货点使用？取消之后还能用吗？
6. **状态**：订阅有哪些状态？哪些状态之间可以转换？

### 2.3 和相邻 focus 划清界限
W04 的核心是**入会/续订 + 资格与有效期规则 + 权益或配额的使用记录**。
- 不要做成 W03（容量和等候名单）或 W05（库存和补货），否则两个人的工作量会失控。
- 在 Excluded processes 里明确写出来。

### 2.4 Fingerprint 样例（只示范格式和写到多具体）

| Field | Example (illustrative) |
|---|---|
| Group ID | G037 |
| Full Canvas group name | *(从 Canvas 原样复制)* |
| Scenario ID | D17-W04 |
| Organization name and type | *Green Ridge Farm Co-op* (fictional), a small organic farm in the New Territories selling seasonal vegetable-box subscriptions to households |
| Principal users/roles | Member; Membership officer (enrols, renews, records payments); Pickup-point coordinator (records collections/skips); Farm manager (reads reports) |
| Business object and core event | **Object:** a member's seasonal subscription, i.e. a time-bounded entitlement to defined quotas. **Events:** enrolment, renewal, redemption of an entitlement (collect or skip a weekly box) |
| Distinctive policy or constraint | *(例如：续订窗口 + 欠费限制；跳过的箱子扣"跳过额度"而不是"箱子额度"……由你们自己定)* |
| Management questions | *(见第5步)* |
| Excluded processes | Online payment gateway; crop planning and harvest inventory; delivery routing; capacity/waiting lists; automatic reminders and scheduling; concurrent users |
| Workflow fit and scope rationale | A subscription is naturally a validity-bounded entitlement, so W04's enrolment/renewal/quota rules map directly onto it. Main challenge: rules that span several tables (renewal eligibility, quota balance) cannot be expressed as MySQL CHECK constraints… |
| Difficulty rationale | e.g. "Moderate–high: renewal eligibility combines a date window, payment state and season order; redemption combines validity period, status and per-benefit quotas." |

---

## 第3步：业务规则（至少6条，建议8–10条）

### 3.1 写法要求
- **每条规则必须影响模型、SQL 或测试**（指南原文）。写完之后问自己：这条规则在 ER 图哪里体现？用什么约束或 SQL 实现？用哪个测试验证？
- **要可以测试**：
  - ❌ "Members should pay on time."
  - ✅ "A renewal may only be created between 21 days before and 7 days after the end date of the previous subscription."
- **类型要覆盖全**：cardinality、participation、uniqueness、value/domain，再加上 W04 特有的 eligibility（资格）、validity（有效期）、quota（配额）、status transition（状态转换）。

### 3.2 先了解 MySQL 8.4 的 CHECK 限制
这直接决定每条规则用什么方式实现。CHECK 约束**不能**：
- 引用其他表或使用子查询；
- 使用 `CURDATE()`、`NOW()` 这类不确定函数；
- 使用存储函数或用户自定义函数；
- 引用 AUTO_INCREMENT 列；
- 引用带 ON DELETE/ON UPDATE 引用动作（CASCADE、SET NULL 等）的外键列。

所以跨表的规则（资格、配额余额）只能做成**显式 SQL 检查**（例如在事务里用带条件的 `INSERT … SELECT … WHERE`），或者写成 documented limitation。

**常见错误码**（后面规划测试要用）：

| 错误码 | 含义 |
|---|---|
| 1048 | NOT NULL 列插入了 NULL |
| 1062 | 违反 UNIQUE / 主键重复 |
| 1451 | 删除仍被引用的父表行 |
| 1452 | 外键指向不存在的行 |
| 3819 | 违反 CHECK |

### 3.3 样例（3条不同类型，其余自己写）

| ID | Rule | Type | Model / SQL / Test impact |
|---|---|---|---|
| BR1 | Every subscription is held by exactly one member, for exactly one plan in exactly one season; a member may hold zero or more subscriptions over time. | Cardinality + participation | Member 1:N Subscription with total participation of Subscription → `member_id NOT NULL` + FK; test: insert with non-existent member → 1452 |
| BR2 | A member may hold at most one subscription per season. | Uniqueness | Candidate key {member_id, season_id} → `UNIQUE`; test: second subscription for same member and season → 1062 |
| BR3 | A renewal must (a) belong to the same member, (b) be for the season immediately after the previous one, (c) be created between 21 days before and 7 days after the previous subscription's end date, and (d) only if the previous subscription has no outstanding balance. A subscription can be renewed at most once. | Eligibility (cross-table, temporal) | Recursive 1:1 "renews" relationship; `renewed_from_sub_id UNIQUE` FK; (a)–(d) checked by a conditional INSERT in the renewal transaction; boundary tests at day +7 and day +8 |

### 3.4 其余规则可以往这些方向想（只给方向）
- 数值约束：价格 ≥ 0、配额范围、结束日期 > 开始日期
- 配额：每个订阅的 SKIP 次数 ≤ 套餐规定的跳过额度
- 有效期：权益的使用日期必须在订阅有效期内
- 状态转换：例如 PENDING → ACTIVE → COMPLETED/CANCELLED，已取消的订阅不能再记录使用
- 取货点：只能在订阅指定的取货点领取
- 付款：累计付款不超过约定价格

> **进阶思考（关系到技术深度分）：** 配额能不能靠约束保证，而不是只靠 SQL 检查？比如入会时把每份权益"展开"成编号 1..N 的权益行，使用记录引用这些行并加 UNIQUE，会怎么样？优点和代价分别是什么？这类权衡写进 proposal 就是很好的设计理由。

---

## 第4步：四个操作用例

### 4.1 要求
四个用例都要涉及 create、change 或 retrieve 数据，最好覆盖 W04 的核心：
1. 入会
2. 续订
3. 记录权益使用（领取或跳过）
4. 取消订阅，或查询剩余权益

### 4.2 模板和样例（UC2）

| Field | UC2 — Renew a subscription (illustrative) |
|---|---|
| Actor | Membership officer |
| Trigger | A member asks to continue into the next season |
| Preconditions | Previous subscription exists with status ACTIVE or COMPLETED; next season exists |
| Main flow | 1. Look up the previous subscription and its outstanding balance (R) 2. Check BR3 (a)–(d) 3. Insert the new subscription with `renewed_from_sub_id` (C) 4. Insert the first payment (C) |
| Tables affected | subscription (R, C), payment (C), season (R) |
| Rules checked | BR2, BR3, value constraints |
| Failure outcome | Any failed check → no new rows; the whole operation is rolled back |

> 续订这个用例天然就是"多条相关的写操作"，可以直接作为 Stage 2 的事务演示：TXC 走成功提交，TXR 让付款插入违反 CHECK 后回滚。现在就这样规划。

---

## 第5步：管理问题（至少4个）

### 5.1 要求
- 至少1个是聚合问题，至少1个需要3张及以上的表。
- 按指南的四段格式写：Question / Tables / Analysis / Decision supported。
- **为 Stage 2 留后路**：让这些问题能自然地拆出相关子查询、`NOT EXISTS`、`HAVING`、LEFT JOIN 加 NULL 处理等查询。

### 5.2 样例（MQ1）
- **Question:** For subscriptions in the Spring 2026 season, what proportion of each plan's subscribers renewed into Summer 2026, and which plans had a renewal rate below 60%?
- **Tables:** Plan, Season, Subscription (self-referenced through `renewed_from_sub_id`)
- **Analysis:** Join Subscription to Plan and Season and filter to Spring 2026. LEFT JOIN Subscription again on `renewed_from_sub_id`. GROUP BY plan; renewal rate = renewed count / subscriber count; HAVING rate < 0.60.
- **Decision supported:** Flag plans whose box size or price may deserve review. For example, 9 of 20 half-share subscribers renewing gives 45% in the synthetic data; this does not explain why members did not renew.

这一个问题就同时涉及三表连接、自连接、LEFT JOIN（NULL 处理）和 GROUP BY + HAVING。

### 5.3 其他方向（只给一句话）
- 各取货点的领取率或"缺领"比例
- 上一季有订阅、本季没有订阅的流失会员（`NOT EXISTS`）
- 季末还剩大量未用权益的订阅
- 各套餐各季的收入

**注意**：不要从虚构数据推出因果结论。

---

## 第6步：概念设计 ER 图（3分里的大头）

### 6.1 找实体
从规则和用例里把名词挑出来，逐个判断它是实体、属性还是排除在范围外。下面是**候选清单，需要你们自己判断**：

| 名词 | 可能的处理 | 需要你们想清楚的问题 |
|---|---|---|
| Member | 实体 | — |
| Plan | 实体 | 价格是固定的，还是每季不同？ |
| Season | 实体 | — |
| Subscription | 实体（核心业务对象） | — |
| Pickup point | 实体 | — |
| Benefit type（箱子、跳过、加购…） | 实体？ | 只有一种权益时值得单独建表吗？ |
| Plan × Benefit 的配额 | 关联实体（M:N 带属性）？ | — |
| 权益使用记录 | 实体或弱实体？ | 用什么来标识一条记录？ |
| Payment | 实体 | — |
| 箱内蔬菜品种 | 排除？ | 属于库存，偏向 W05 |

### 6.2 关系
- 关系用动词命名（holds、renews、redeemed at…）。
- 每个关系都标明基数（1:1 / 1:N / M:N，或者 (min,max)）和参与度（全部/部分）。
- 例：Member *holds* Subscription，1:N；Member 是部分参与，Subscription 是全部参与。

### 6.3 这个场景里可能用得上的高级构造
用了就要在正文写理由，不要为了显得复杂而硬加。

| 构造 | 本场景的可能用法 |
|---|---|
| 递归关系 | Subscription *renews* Subscription（1:1，两个角色：previous / renewal） |
| 弱实体 | 例如季内的"周"（Season + week_no），或者使用记录 |
| 关联实体 | 套餐与权益类型之间的配额 |
| 多值属性 | 会员的饮食禁忌、多个电话 |
| 复合属性 | 姓名（first/last）、地址（district/street） |
| 派生属性 | 剩余配额 = 配额 − 已用；结束日期 |

### 6.4 工具：draw.io 的具体用法
1. 打开 https://app.diagrams.net（也有桌面版）→ Create New Diagram → Blank，保存到本机或 GitHub，文件格式是 `.drawio`。
2. 左下角 **+ More Shapes** → 勾选 **Entity Relation** → Apply。左侧会出现 ER 图形库。
3. **画法**（以课上讲的记法为准，图旁边加图例）：
   - 实体用矩形，弱实体用双线矩形，关系用菱形，标识关系用双线菱形。
   - 如果库里没有某种属性图形：派生属性用普通椭圆，在右侧 Format 面板把边框改成 dashed；多值属性用双边框椭圆。
   - 主键属性：选中文字按 Ctrl+U 加下划线。弱实体的部分键可以在图例里说明（例如虚下划线或标注 partial key）。
4. **连线**：从图形边缘的蓝色箭头拖到目标图形。
   - 全部参与要画双线：选中连线 → 右键 Edit Style → 加上 `shape=link;`
   - 基数：双击连线，输入 `1`、`N` 或 `(1,1)`
5. **导出**：File → Export as → PNG（Zoom 设 200–300%）或 PDF。`.drawio` 源文件要提交到 Git。

**其他工具**：
- **ERDPlus**：可以画 Chen 记法，也能自动转出关系模式。自动转换的结果必须自己核对，并且能解释。
- **DBeaver 的 ER Diagram 标签页**：画的是物理表结构，**不能替代**概念 ER 图，只适合放在第7步当关系模式图。

### 6.5 图要看得清
- 横向页面，打印出来字号不小于约9pt。
- 图太大时，拆成"总览图（只有实体和关系）"加"分区详图（带属性）"。

### 6.6 ER 自检
- [ ] 每个实体都有主键，其他候选键也标出来了
- [ ] 每个关系都有名字、基数和参与度
- [ ] 弱实体有标识关系和部分键
- [ ] 图里的每个元素都能对应到某条规则或某个用例
- [ ] 图例和课上讲的记法一致

---

## 第7步：ER→关系映射

### 7.1 按课上的映射算法逐步做
1. **强实体** → 一张表。选主键：代理键（`INT UNSIGNED AUTO_INCREMENT`）或自然码（如 `plan_code`）。其他候选键做成 UNIQUE（如 email）。
2. **弱实体** → 一张表，主键 = 所属实体的主键 + 部分键。
3. **1:1** → 外键放在全部参与的一侧，并加 UNIQUE。
4. **1:N** → 外键放在 N 那一侧。
5. **M:N** → 新建一张表，复合主键。
6. **多值属性** → 新建一张表。
7. **派生属性** → 一般不存；如果要存，写清楚理由。

### 7.2 写法和样例

关系模式（PK 用下划线或加粗，FK 用 → 标出）：
```
subscription(sub_id, member_id→member, season_id→season, plan_code→plan,
             point_id→pickup_point, start_date, end_date, status, price_agreed,
             renewed_from_sub_id→subscription [UNIQUE, NULL allowed])
             CK: {member_id, season_id}
```

映射说明表：

| ER construct | Relational result | Note |
|---|---|---|
| Recursive 1:1 *renews* | `renewed_from_sub_id` FK to the same table + UNIQUE | NULL = first-time subscription, a legitimate missing value |

---

## 第8步：数据字典 + 原型 DDL 验证

### 8.1 选 MySQL 类型的原则
- **金额**用 `DECIMAL(8,2)`，不要用 FLOAT。
- **日期**用 `DATE`，时间戳用 `DATETIME`。
- **电话**用 `VARCHAR(20)`，不要用 INT（会丢掉开头的 0 和 `+852`）。
- **状态**用 `VARCHAR + CHECK IN(...)` 或 `ENUM`，两种都可以，写明为什么选这种。
- **外键列的类型必须和被引用列完全一致**（例如两边都是 `INT UNSIGNED`）。

### 8.2 数据字典样例（一张表）

| Column | MySQL type | Key | Null | Default | Constraint / domain | Description |
|---|---|---|---|---|---|---|
| sub_id | INT UNSIGNED AUTO_INCREMENT | PK | NO | — | — | Surrogate identifier |
| member_id | INT UNSIGNED | FK→member; part of CK | NO | — | ON DELETE RESTRICT | Holder (BR1) |
| season_id | SMALLINT UNSIGNED | FK→season; part of CK | NO | — | UNIQUE(member_id, season_id) (BR2) | Season |
| plan_code | CHAR(4) | FK→plan | NO | — | — | Chosen plan |
| start_date | DATE | — | NO | — | CHECK (end_date > start_date) | Validity start |
| end_date | DATE | — | NO | — | — | Validity end |
| status | VARCHAR(10) | — | NO | 'PENDING' | CHECK (status IN ('PENDING','ACTIVE','COMPLETED','CANCELLED')) | Lifecycle state |
| price_agreed | DECIMAL(8,2) | — | NO | — | CHECK (price_agreed >= 0) | Price snapshot at enrolment |
| renewed_from_sub_id | INT UNSIGNED | FK→subscription; UNIQUE | YES | NULL | — | Previous subscription (BR3) |

> **原型验证能发现什么**：如果想用 `CHECK (renewed_from_sub_id <> sub_id)` 实现"不能续订自己"，MySQL 会拒绝建表，因为 sub_id 是 AUTO_INCREMENT 列。这正是写原型 DDL 的价值：提前发现某条规则只能做成 SQL 检查或写成 limitation，并如实写进可追溯矩阵。

### 8.3 在 DBeaver 里验证
1. 在练习库里打开 SQL 编辑器，把数据字典逐表写成 `CREATE TABLE` 草稿（自己写），放在 `prototype_sql/`。
2. **Alt+X** 执行整个脚本，**Ctrl+Enter** 执行当前语句。把报错记下来并修正数据字典。
3. 故意插入一行违反 CHECK 的数据，确认返回 3819。
4. 可选：在左侧数据库节点上双击 → 打开 **ER Diagram** 标签页 → 导出图片，作为关系模式图放进 proposal。

---

## 第9步：函数依赖与范式化（1分）

### 9.1 流程
1. 从**业务规则**推出每张表的非平凡 FD。不能为了分解而编造 FD；真实存在的 FD 也不能漏。
2. 用属性闭包（attribute closure）求候选键。
3. 判断初始范式。
4. 不满足就分解到 3NF，适合的话到 BCNF。
5. 说明分解是无损连接的、依赖是保持的。

**推荐的写法**：先给出一张"农场现在用的报名表格"那样的扁平关系，演示怎样分解；然后对每张最终表列出 FD 和候选键，并说明它为什么满足 BCNF（每个决定因素都是超键）。

### 9.2 演示例子（推理方式可以参考，FD 必须用你们自己的规则重新推）
```
Initial: SignUp(member_id, member_name, email, season_id, season_start,
                plan_code, box_quota, price, point_id, point_district)

FD1 member_id → member_name, email
FD2 email → member_id                       (email unique per member)
FD3 season_id → season_start
FD4 plan_code → box_quota
FD5 {plan_code, season_id} → price          (price set per plan per season)
FD6 {member_id, season_id} → plan_code, point_id   (BR2)
FD7 point_id → point_district

{member_id, season_id}+ = all attributes  → candidate key
{email, season_id}+     = all attributes  → candidate key
Initial NF: 1NF only (FD1 is a partial dependency on the key)

Decomposition:
R1 member(member_id, member_name, email)      CK: email
R2 season(season_id, season_start)
R3 plan(plan_code, box_quota)
R4 plan_price(plan_code, season_id, price)
R5 pickup_point(point_id, point_district)
R6 subscription(member_id, season_id, plan_code, point_id)

Lossless: each split uses X→Y where X becomes the key of the new relation
          (R1∩R2 → R1 or R1∩R2 → R2 holds at every step).
Preserving: every FD1–FD7 lies within a single Ri.
BCNF: every determinant in each Ri is a superkey.
```

**两个要点**：
- **FD 由规则决定**。如果你们的规则是"价格不随季节变化"，FD5 就应该写成 `plan_code → price`。
- **快照属性不构成传递依赖**。例如 subscription 里存 `price_agreed`，因为套餐价格以后可能改，`plan_code → price_agreed` 并不成立。把这一点写出来，就是一个很好的"独立设计理由"。

---

## 第10步：可追溯矩阵

**每一条 BR 都必须出现在矩阵里**；测试编号沿用 Stage 2 的命名（POS、N、TXC、TXR）。

| Req | ER construct | Relation / constraint | Enforcement | Planned test |
|---|---|---|---|---|
| BR1 | Member 1:N Subscription, total participation | `member_id NOT NULL`, FK | DB constraint | N01: insert with member_id 999 → 1452; N02: delete a member who has subscriptions → 1451 |
| BR2 | CK {member, season} | `UNIQUE uq_member_season` | DB constraint | N03: duplicate → 1062; POS: same member, different season → success |
| BR3 | Recursive *renews* 1:1 | UNIQUE FK; window and balance checked in renewal SQL | UNIQUE/FK = constraint; (a)–(d) = SQL check; **limitation:** a direct INSERT that skips the renewal script is not blocked | Boundary: day +7 → 1 row; day +8 → 0 rows; TXR01 rollback |

---

## 第11步：分工计划与风险

### 11.1 分工样例（2人）

| Task | Lead | Reviewer |
|---|---|---|
| Fingerprint, BR, UC, MQ | A | B |
| ER diagram | B | A |
| Mapping, data dictionary, prototype DDL | B | A |
| FDs and normalization | A | B |
| Traceability matrix | A + B | — |
| Assembly, metadata, ai_usage, ZIP | A | B 核查 |
| **Stage 2 预案：** schema、indexes、negative tests | B | A |
| **Stage 2 预案：** seed data、Q01–Q08、evidence | A | B |
| **Stage 2 预案：** view、transaction、README、presentation | A + B | — |

**一定要交叉审阅。** 现场改题时老师可能点任何一个人操作，所以两个人都必须讲得清楚整个设计。

### 11.2 风险样例

| Risk | Mitigation |
|---|---|
| 跨表规则没法写成 CHECK | 在事务里用条件 INSERT 实现，写明限制，每条都安排测试 |
| 范围扩展到库存或等候名单 | 在 fingerprint 里明确排除 |
| 查询依赖"今天"，结果无法复现 | 不用 `CURDATE()`，在数据和查询里用固定的参考日期（例如 `'2026-11-01'`） |
| 种子数据没覆盖 HAVING 被筛掉的组、NULL、边界值 | 按测试矩阵反推需要哪些数据 |
| 外键类型不匹配导致建表失败 | 第8步提前用原型验证 |

---

## 第12步：撰写 proposal.pdf（建议正文8–12页）

| 章节 | 建议页数 |
|---|---|
| 封面（不计页数）：Title、G037、完整 Canvas 组名、D17-W04、Team size 2、两人姓名和学号 | — |
| 1 Scenario fingerprint & scope | 1–1.5 |
| 2 Business rules / Use cases / Management questions | 2–2.5 |
| 3 ER model（图 + 构造说明和理由） | 2 |
| 4 Relational schema & mapping | 1–1.5 |
| 5 Data dictionary（太长可以部分放附录，正文注明） | 1.5–2 |
| 6 FDs & normalization | 1.5 |
| 7 Traceability matrix | 1 |
| 8 Work plan & risks | 0.5 |
| References / Appendix | — |

**写作建议**：
- **命名统一**：ER 图、关系模式、数据字典、矩阵里用同一套名字，建议 snake_case、单数表名。
- **Overleaf**：表格可以用 `booktabs` / `longtable`，图片用 `\includegraphics[width=\linewidth]{er.pdf}`。
- **Word**：用标题样式生成目录，最后另存为 PDF。
- 导出后把图放大检查，确认文字清晰。

---

## 第13步：metadata.json

```json
{
  "group_id": "G037",
  "canvas_group_name": "（从 Canvas 原样复制）",
  "scenario_id": "D17-W04",
  "stage": 1,
  "team_size": 2,
  "members": [
    {"name": "Student A", "student_id": "REPLACE_A"},
    {"name": "Student B", "student_id": "REPLACE_B"}
  ],
  "dbms": "MySQL Community Server",
  "dbms_version": "8.4.11",
  "database_name": "comp2411_g037",
  "approval_reference": null
}
```

**注意**：
- 学号是字符串（带引号）。
- `null` 不加引号。
- `team_size` 必须等于 members 的人数。

**验证 JSON 是否合法**：在终端执行 `python -m json.tool metadata.json`，能正常打印出格式化内容就说明合法。也可以用 VS Code（有错会标红）或 jsonlint.com。

---

## 第14步：ai_usage.md

```markdown
# AI Usage Declaration — G037, Stage 1

| # | Tool | Purpose | Affected files/sections | Accepted / rejected | How we checked |
|---|------|---------|------------------------|---------------------|----------------|
| 1 | Claude (Anthropic), chat | Requested a step-by-step Stage 1 plan and examples of documentation formats (rule table, data dictionary layout, metadata format) | [按实际情况填写] | [按实际情况填写：哪些采纳、哪些改写或拒绝] | [例如：逐项对照课程指南第5、9节；在 MySQL 8.4.11 中验证草稿 DDL] |
```

之后每次用 AI（例如调试、问概念）都追加一行，如实填写。

---

## 第15步：打包与提交（截止 10月26日 23:55）

### 15.1 目录结构
```
COMP2411_2026_G037_Stage1/
  metadata.json
  proposal.pdf
  ai_usage.md
```
ZIP 里必须**只有这一个顶层目录**，名字和 ZIP 文件名（去掉 .zip）一致，大小写敏感。

### 15.2 压缩
- **Windows**：右键该文件夹 → 压缩为 ZIP 文件，文件名应为 `COMP2411_2026_G037_Stage1.zip`。
- **macOS**：Finder 自带的压缩会带上 `__MACOSX` 和 `.DS_Store`，建议用终端：
  ```bash
  zip -r COMP2411_2026_G037_Stage1.zip COMP2411_2026_G037_Stage1 -x "*.DS_Store"
  unzip -l COMP2411_2026_G037_Stage1.zip
  ```
  预期 `unzip -l` 只列出：文件夹本身、`metadata.json`、`proposal.pdf`、`ai_usage.md`。

### 15.3 提交
1. 由一人上传到 Canvas 的 Stage 1 assignment。
2. 确认提交成功和文件名。
3. 下载回来重新打开一遍检查。
4. 发给另一位成员存档。

---

## 第16步：提交前最终自检
- [ ] 两人都在同一个 Canvas group；Group ID 在 ZIP 名、metadata、封面上一致
- [ ] KCube 登记了 D17-W04，Text response 填了组号
- [ ] ≥6条 BR、4个 UC、≥4个 MQ（含聚合问题和三表问题）
- [ ] ER 图、关系模式、数据字典、矩阵四者一致；**每张表**都有数据字典
- [ ] FD 都来自规则；说明了候选键、初始范式、3NF/BCNF、无损连接和依赖保持
- [ ] 每条 BR 在矩阵里都写了实现方式（约束、SQL 检查或 limitation）和测试
- [ ] 数据全是虚构的；没有任何密码
- [ ] 两个人都能独立讲清整个设计

---

## 另外一个需要确认的地方

指南第10节最后一条要求在**最终 report**（属于 Stage 2）的 Acknowledgements 里感谢 "Prof. Yuawqv Fuimfct"，并且拼写保持原样。这个名字不是封面上的讲师（HUANG Xiao），看起来也不像真实姓名，可能是放进 PDF 里的特殊标记。建议打开原始 PDF 确认这一条确实可以看到，不确定就直接问助教。如果确认是正式要求，就在 Stage 2 的 report 里照原样加一个简短的 Acknowledgements 部分。

如果后面某一步（比如 FD 推导或 ER 记法）卡住了，可以把你们自己的草稿发过来，我可以帮你们找问题、解释概念。记得把这些交流也写进 `ai_usage.md`。

Learn more:
- <http://dev.mysql.com/doc/refman/5.1/en/create-table-foreign-keys.html>
- <https://dev.mysql.com/doc/refman/8.3/en/create-table-foreign-keys.html?:~:text=Altering_a_table_returns_an%20removed_before_dropping_the_index.>
- <https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html?:~:text=Foreign_key_checking_is_controlled%20it_does_for_InnoDB_tables.>
- <https://www.percona.com/blog/how-to-use-check-constraint-in-mysql-8/>
- <https://docs.oracle.com/cd/E17952_01/mysql-8.4-en/create-table-foreign-keys.html>
- <https://r-farmhk.com/>
- <http://jrorganicsfarm.com/handbook>
- <https://amber-baker-83an.squarespace.com/community-supported-agriculture>
- <https://www.brimwoodfarm.com/csa>
- <https://www.ams.usda.gov/local-food-directories/csas>