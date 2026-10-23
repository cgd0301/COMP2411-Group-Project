# subscription

1. Functional Dependency
  - subscription_id -> customer_id
  - subscription_id -> season_id
  - subscription_id -> status
  - subscription_id -> plan_type, frequency
  - subscription_id -> allocated_cost
  - subscription_id -> submission_date, cancellation_date
  - subscription_id -> remaining_refundable_skip
  - submission_date -> season_id
  - customer_id, season_id -> subscription_id, status, plan_type, frequency, allocated_cost, submission_date, cancellation_date, remaining_refundable_skip

2. Candidate Key
  - subscription_id
  - customer_id, season_id
  - customer_id, submission_date

3. Normalization
  - Lossless: The discarded decomposition is lossless
  - Preserving: The discarded decomposition is not dependency preserving
  - BCNF/3NF: Satisfies 3NF but not BCNF, because the functional dependency of submission_date -> season_id is not a trivial dependency and submission_date is not a super key. However, {season_id} - {submission_date} = {season_id} belongs to the candidate keys, which suggests that the table satisfies the 3NF. The reason why we choose to keep 3NF rather than further decompose it to BCNF is the further decomposition will sacrifice the dependency preserving. There will be two tables, R1{submission_date, season_id} and R2{R - season_id}, after BCNF decomposition. Though the decomposition is lossless due to the fact that submission_date is the super key of R1, it will discard (customer_id, season_id) -> subscription_id. Therefore, we choose to keep as 3NF. 



# refund 

1. Functional Dependency
  - refund_id -> subscription_id
  - refund_id -> amount
  - refund_id -> type
  - refund_id -> refund_date
  - refund_id -> week_no
  - subscription_id, week_no -> refund_id
  - subscription_id, type, refund_date -> refund_id

2. Candidate Key
  - refund_id
  - subscription_id, type, refund_date (For each subscription, there would be only one refund of specific type on a specific refund date)

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: Satisfies BCNF (and therefore 3NF), because the left-hand side of every non-trivial functional dependency is a super key: refund_id is a candidate key, and {subscription_id, type, refund_date} is also a candidate key. The second candidate key holds because the skipping windows of different deliveries do not overlap and a delivery can be skipped only once (at most one skip refund per day), a failed refund is issued on the day after its unique delivery day (at most one failed refund per day), and a subscription can be cancelled at most once (at most one cancellation refund). In the dependency subscription_id, week_no -> refund_id , the subscription and week_no are the super key of  the refund, which can not be primary key because the week_no can be null.


# chosen_products

1. Functional Dependency
  - only trivial dependency

2. Candidate Key
  - subscription_id, product_id

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: Satisfies BCNF (and therefore 3NF), because the table only has trivial functional dependencies. Every attribute belongs to the only candidate key {subscription_id, product_id}, so there is no non-trivial functional dependency whose left-hand side is not a super key.

# customer

1. Functional Dependency
  - customer_id -> name
  - customer_id -> email
  - customer_id -> street, building, room
  - email -> customer_id
  - email -> name
  - email -> street, building, room

2. Candidate Key
  - customer_id
  - email

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: Satisfies BCNF (and therefore 3NF), because the left-hand side of every non-trivial functional dependency (customer_id or email) is a candidate key, and hence a super key. The address (street, building, room) and name do not determine any other attribute, since several customers may share the same address or name.


# season

1. Functional Dependency
  - season_id -> season_name, year, first_planning_day (primary key)
  - season_name, year -> season_id, first_planning_day (CK1)
  - first_planning_day -> season_id, season_name, year (CK2)

2. Candidate Key
  - season_id ({season_id}+ = all attributes; chosen as primary key)
  - season_name, year ({season_name, year}+ = all attributes)
  - first_planning_day ({first_planning_day}+ = all attributes)

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: Every determinant (season_id / {season_name, year} / first_planning_day) is itself a candidate key, hence a superkey. season is in BCNF.


# product

1. Functional Dependency
  - product_id -> season_id, name, is_farmers_choice, price_per_kg (primary key)
  - season_id, name -> product_id, is_farmers_choice, price_per_kg

2. Candidate Key
  - product_id ({product_id}+ = all attributes; only key)
  - season_id, name

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: The product_id is a super key of product. Since it is assumed that there will not be products in a identical name in a season, the season_id and name are also the super key of product. Therefore, product satisfies BCNF.


# delivery (weak entity)

1. Functional Dependency
  - subscription_id, week_no -> status (primary key)

2. Candidate Key
  - subscription_id, week_no ({subscription_id, week_no}+ = all attributes; chosen as primary key)

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: subscription_id and week_no forms the primary key of delivery. Therefore, the delivery satisfies BCNF.


# add_on (M:N junction, relationship attribute weight)

1. Functional Dependency
  - subscription_id, week_no, product_id -> weight (primary key)
  - No other FD holds:
    - {subscription_id, week_no} does NOT determine weight (one delivery can carry several add-on products, each with its own weight)
    - product_id does NOT determine weight (the same product is weighed differently on different orders)
    - weight does NOT determine anything

2. Candidate Key
  - subscription_id, week_no, product_id ({subscription_id, week_no, product_id}+ = all attributes)

3. Normalization
  - Lossless: No decomposition needed, not applicable
  - Preserving: No decomposition needed, not applicable
  - BCNF/3NF: The pair {subscription_id, week_no} is a composite FOREIGN KEY to delivery, but it is not a determinant inside add_on - so there is no partial dependency on the key. The sole determinant is the whole key, a superkey. add_on is in BCNF.


# Design-rationale notes (independent justifications)

  - Snapshot/current-value columns do NOT create transitive dependencies here: price_per_kg lives in product (the current catalogue price); the price actually charged on an order is computed at order time, so product_id -> price holds only inside product, and no copy of it is stored in add_on.
  - delivery_date() is derived (first_planning_day + 7 × (week_no − 1)) and is NOT stored, so it generates no FD in delivery.
  - "Exactly 10 products per season" and "0..8 chosen products" are cross-row business rules; they are enforced by in-transaction SQL checks, not by FDs.
