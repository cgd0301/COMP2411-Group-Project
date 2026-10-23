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

2. Candidate Key
  - subscription_id


# refund 

1. Functional Dependency
  - refund_id -> subscription_id
  - refund_id -> amount
  - refund_id -> type
  - refund_id -> refund_date
  - subscription_id, type, refund_date -> refund_id

2. Candidate Key
  - refund_id
  - subscription_id, type, refund_date


# chosen_products

1. Functional Dependency
  - subscription_id, product_id -> subscription_id, product_id

2. Candidate Key
  - subscription_id, product_id

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
