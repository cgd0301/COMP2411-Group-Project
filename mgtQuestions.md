MQ1 
Question: For the Spring 2026 season, how many subscriptions were sold per plan type, and what is each plan type's total refund amount (skips, failed deliveries, cancellations) and net income after all refunds?
Tables: season, subscription, add_on, product, refund
Analysis: Join subscription to season and filter to season_name = 'spring' AND year = 2026 (cancelled subscriptions are included, because they were sold and then refunded). For each subscription, compute its subscription fee (12 deliveries for weekly, 6 for biweekly, × allocated_cost), its add-on income (SUM(weight × price_per_kg) over its add_on rows joined to product) and its refund total (SUM(amount) over its refund rows) in separate derived tables, so that joining add-ons and refunds does not multiply rows; use COALESCE(..., 0) for subscriptions with no add-ons or no refunds. GROUP BY plan_type: subscription count = COUNT(*), total refund = SUM(refund total), net income = SUM(subscription fee + add-on income − refund total).
Decision supported: Quantify how much the refund policies actually cost per plan type in a season, informing whether the number of refundable skips (2 per subscription) or the allocated cost per delivery (200 / 240 HKD) should be reviewed. The figures describe synthetic data only; they do not explain why refunds occurred.

MQ2 
Question: For the Spring 2026 season, per plan type, which add-on products generate the largest add-on income from successful deliveries?
Tables: season, subscription, delivery, add_on, product
Analysis: Join subscription → season (filter to Spring 2026) → delivery → add_on (on subscription_id and week_no) → product, keep only deliveries with status = 'success' (add-ons of skipped, failed or cancelled deliveries are refunded), GROUP BY plan_type and product, and compute income as SUM(weight × price_per_kg) and total weight as SUM(weight). Order products by income within each plan type; the top product of each plan type is the one whose income equals the maximum income of that plan type (correlated subquery).
Decision supported: Identify the most demanded add-on products per plan type, to decide which products the farm should grow in larger quantities for add-on sales next season. The figures describe synthetic data only.

MQ3 
Question: Which delivery weeks of Spring 2026 had the highest skip rates and the highest failure rates?
Tables: season, subscription, delivery
Analysis: Join delivery to subscription and season, filter to Spring 2026 and exclude cancelled deliveries (they were not skipped or attempted, but cancelled with their subscription). GROUP BY week_no and use conditional aggregation: skips = SUM(status = 'skipped'), failures = SUM(status = 'failed'), attempted = SUM(status IN ('success', 'failed')). Skip rate = skips ÷ COUNT(*) of the week; failure rate = failures ÷ attempted (NULLIF avoids division by zero). Rates rather than counts are compared because even weeks only contain weekly subscribers' deliveries, while odd weeks also contain biweekly ones.
Decision supported: Weeks with high failure rates flag possible supply or staffing problems to investigate; weeks with high skip rates inform harvest and planning volumes. The rates describe patterns in the synthetic data; they do not explain why customers skipped or why deliveries failed.

MQ4 
Question: For the Spring 2026 season, which products are most frequently chosen by customizable plan subscribers, and are they among the season's 6 farmer's choice products?
Tables: season, subscription, chosen_products, product
Analysis: Start from product joined to season (filter to Spring 2026, so all 10 products of the season are listed), and LEFT JOIN chosen_products → subscription, so products never chosen still appear and are counted as 0. GROUP BY product (name, is_farmers_choice), count how many subscriptions chose it with COUNT(chosen_products.subscription_id), and compute the pick rate as that count ÷ the number of customizable subscriptions of the season (scalar subquery). Only customizable subscriptions have chosen_products rows, since farmer's choice subscriptions choose no types. Rank by count with ORDER BY; the most popular products are those whose count equals the maximum count (subquery).
Decision supported: Use actual customer preferences to review which 6 products are flagged as the farmer's choice box for the next season, e.g. a non-farmer's-choice product chosen by most customizable subscribers. The pick rates describe synthetic data only.

MQ5
Question: For subscriptions in the Spring 2026 season that were not cancelled, what proportion of each plan type's subscribers renewed into Summer 2026, and which plan type had a renewal rate below 60%?
Tables: season, subscription (used twice: Spring 2026 and Summer 2026)
Analysis: Join subscription to season and filter to Spring 2026 with status <> 'cancelled' (only an active or finished previous subscription makes a renewal). LEFT JOIN subscription again (with season, filtered to Summer 2026) on the same customer_id, so customers who did not renew appear with NULL; at most one match exists per customer because of UNIQUE (customer_id, season_id). GROUP BY the Spring 2026 plan_type; renewal rate = COUNT(summer subscription_id) ÷ COUNT(spring subscription_id), since COUNT ignores the NULLs; HAVING renewal rate < 0.60.
Decision supported: Flag plan types with a renewal rate below 60% for a review of their renewal offer (the 20% discount) or product mix before the next subscription window opens. A low rate in synthetic data flags where to look; it does not explain why customers did not renew.
