MQ1 
Question: For the Spring 2026 season, how many subscriptions were sold per plan, and what is each plan's net income after all refunds (skips, failed deliveries, cancellations) and its total refund amount?
Tables: Plan, Season, Subscription, Payment
Analysis: Join Subscription to Plan and Season, filter to Spring 2026, and GROUP BY plan for the subscription count. Join Payment on subscription_id and SUM its signed amounts (refunds are stored as negative payment rows, so a plain SUM yields the net income directly). Combine both in one grouped result using COUNT(DISTINCT subscription_id) to avoid double counting subscriptions that have multiple payment rows.
Decision supported: Quantify how much the refund policies actually cost per plan per season, informing whether the refund of skip limit or plan prices should be reviewed. The figures describe synthetic data only; they do not explain why refunds occurred.

MQ2 
Question: Based on the plan type, which products generate the biggest add-on income of successful delivery?
Tables: Subscription, Plan, Delivery, DeliveryItem, Product
Analysis: logic: Join Subscription → Plan → Delivery → DeliveryItem → Product, keep only add-on rows, GROUP BY plan type and product category, and compute revenue as SUM(quantity × unit_price). Order categories by revenue within each plan type.
Decision supported: Identify highly demanded add-on products per plan type; decide whether to expand the add-on catalogue. 

MQ3 
Question: Which delivery weeks of Spring 2026 had the highest skip rates and the highest failure rates?
Tables: Delivery, Subscription, Season
Analysis: Join Delivery to Subscription and Season, filter to Spring 2026, GROUP BY week_no, and use conditional aggregation: skips = COUNT of status 'SKIPPED', failures = COUNT of status 'FAILED', rates computed over all scheduled deliveries of the week.
Decision supported: Weeks with high failure rates flag possible supply or staffing problems to investigate; weeks with high skip rates inform harvest and planning volumes. The rates describe patterns in the synthetic data.

MQ4 
Question: Which products are most frequently picked by Customizable plan subscribers in their subscription?
Tables: DeliveryItem, Delivery, Subscription, Plan, Product
Analysis: logic: Join DeliveryItem → Delivery → Subscription → Plan → Product, filter to non add-on rows of Customizable plans, GROUP BY product, and rank by COUNT of appearances (and total weight). Use ORDER BY with LIMIT, or a subquery selecting products whose pick count equals the maximum.
Decision supported: Use actual member preferences to review the fixed composition of the Farmer's Choice box for the next season.

MQ5
Question: For subscriptions in the Spring 2026 season, what proportion of each plan's subscribers renewed into Summer 2026, and which plan had a renewal rate below 60%?
Tables: Plan, Season, Subscription
Analysis: Join Subscription to Plan and Season and filter to Spring 2026. LEFT JOIN Subscription again on renewed_from_sub_id, so non renewed subscriptions appear with NULL. GROUP BY plan; renewal rate = renewed count ÷ subscriber count; HAVING rate < 0.60.
Decision supported: Flag plans with a renewal rate below 60% for a review of their renewal offer or product mix before the next subscription window opens. A low rate in synthetic data flags where to look; it does not explain why members did not renew.