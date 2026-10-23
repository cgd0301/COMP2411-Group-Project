G085 / D17-W04

Organization name and type:
Farmlander Farm, a local farm operating a Community Supported Agriculture (CSA)
style subscription service.

Principal users/roles:
Farm staff, who manage seasons and products, batch-generate deliveries, record
delivery outcomes (success / skip / failure), process refunds and add-on orders;
and subscribed customers, who enrol, renew, pick the customizable plan's product
types at subscription time, skip deliveries, and place add-on orders.

Business objects and core events:
A seasonal CSA subscription (spring / summer / autumn; each season has a fixed
12-week delivery window, D-6 to D+77 D is defined as the first planning seasonal delivery day). Core events: enrolment for the next
season's vegetable box; Generation of all delivery records on the first day of a season (subscription range);
recording each delivery's outcome; three kinds of refund, all computed at the
subscription's (possibly discounted) allocated cost per delivery — (a) a
refundable skip, at most 2 per subscription, further skips allowed but without
refund; (b) a failed delivery, refunded immediately and NOT consuming a skip
quota; (c) cancellation — before the season the fee already charged is refunded
in full; during the season the refund is min(remaining refundable skips,
pending deliveries) × allocated cost, plus add-on fees already paid on planned
deliveries; after the season a subscription cannot be cancelled. Add-on orders
are placed per delivery, restricted to the products the farm grows that season,
charged as Σ weight(kg) × unit price. No mid-season join, no prorated price.

Distinctive policy or constraint:
The enrolment window is the previous season (winter→spring, spring→summer,
summer→autumn); a customer holds at most one subscription per season, and a
cancelled subscription still occupies that slot. A renewal whose previous
subscription is active or finished gets 20% off the allocated cost per delivery
(farmer's choice 200 HKD, customizable 240 HKD; renewal 160/192 HKD). Plan type
and frequency are fixed at enrolment. Each season the farm grows exactly 10
products; add-on purchases are limited to the plan's products (farmer's choice:
6 fixed types; customizable: 8 types chosen from the 10 at subscription time).
Cross-entity refund integrity: a refund always belongs to a single subscription;
a skip or failed refund is tied to exactly one delivery of that same
subscription; a cancellation refund is tied to no delivery. The timing rules are enforced by explicit in-transaction SQL checks The association between refund and delivery is enforced through declarative constraints. 


Management questions:
Q1: Per plan type, how many subscriptions were sold in Spring 2026, what is the
net income after refunds, and what is the total refund amount?
Q2: Per plan type, which products generate the largest add-on income from
successful deliveries?
Q3: Which delivery weeks have the highest skip rates and failure rates?
Q4: Which products are most frequently chosen by customers subscribing to the
customizable plan?
Q5: For subscriptions in the Spring 2026 season that were not cancelled, what proportion of each plan type's subscribers renewed into Summer 2026, and which plan type had a renewal rate below 60%?

Excluded processes:
No delivery assignment / routing; no real payment processing (only fee and
refund amounts are recorded, no payment channel); no farm production management
beyond the 10 products grown per season.

Workflow fit and scope rationale:
A CSA subscription works naturally like a membership: customers pay up front
and receive a vegetable box each week, so our database rules come from the
farm's daily operational questions. Main challenges: the three refund kinds
(skip / failed delivery / in-season cancellation) all price at the same
allocated cost per delivery (which also closes the renewal-discount arbitrage),
and the renewal discount depends on the previous season's subscription status
rather than any stored balance. The ER design has 8 tables (6 entity tables —
customer, season, subscription, delivery, product, refund — plus 2 M:N junction
tables for "choose" and "add-on"); each table supports at least one business
rule, and every rule can be demonstrated with manual SQL checks.