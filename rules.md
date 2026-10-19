# Rules

[BR1]

1. Rule
   Every subscription is held by exactly one member, for exactly one plan in one season. A member could hold at most one subscription.
2. Type
   Cardinality + Participation
3. Model/SQL/Test impact

- Member 1:1 subscription with customer
- Test: insert subscription with non-existent member, member with multple subscriptions

[BR2]

1. Rule
   A Subscription
   (1) must be made during the current corresponding season or one week before that season starts
   (2) must be renewed manually (auto-renewal is not allowed)
   (3) seasons could be spring (2026-3-2T00:00:00 to 2026-5-24T23:59:59), summer (2026-5-25T00:00:00 to 2026-8-16T23:59:59)and winter (2026-8-17T00:00:00 to 2026-11-8T23:59:59) (each season's subscription could only be made during that season or at most one week before that season starts). There is not winter season for subscription due to the fallow season.
   (4) becomes effective from the next day of the time when the customer subscribes (if the subscription is made for current season period) or from the start day of next season period (if the subscription is to book for next season period during the last week before next season period)
   (5) ends at the last day of corresponding season of the subscription. (Spring 2026-5-24T23:59:59; Summer 2026-8-16T23:59:59; Autumn 2026-11-8T23:59:59)
   (5) once confirmed, could not be changed in the furture.
   (6) could be cancelled, which disables the subscription status immediately. However, no refundable fee.
2. Type
   Not sure
3. Model/SQL/Test impact
   Not sure

[Br3]

1. Rule
   A Delivery
   (1) date: for weekly frequency customers: Monday; for byweekly
   (2) could be skipped at most twice by customers with refundable fee of single delivery, - counted by standardized seasonal subscription plan price (exclude extra add-on fee) / number of delivery for a standardized seasonal round of subscription (skipping more than 2 times will no longer refund, but still could be cancelled)
   (3) assumed to be fulfilled once the subscription of the customer becomes effective

[Br4]

1. Rule
   A Plan
   (1) has two Types:

- Farmer's choice: fixed 6 types of seasonal argricultural products with each respective fiexed weight
- Customizable: the composition of each delivery box could be adjusted, including weight and types of agricultural products (number of types could be from 0 to 8, each corresponding weight up-bound would be decided accrodingly)
  (2) has 2 frequencies for each plan:
- weekly plan will delivered on Monday
- byweekly plan will be delivered on Monday at odd-numbered weeks starting from this season (start week of this season should be week 1)

[Br5]

1. Rule
   The price
   (1) For subscription

- total susbcribing price for a season = the maximum number of deliveries available during the season (assuming no deliveries are skipped) \* standardized price per delivery (farms' choice = 40; customized choice = 50)
- For subscriptions that begin mid-season, the subscription fee is prorated based on the maximum number of deliveries remaining in the season.
  (2) Extra add-on purchase fee for each delivery
- Farmer's choice plan subscribers, they can pay extra to receive additional items from the fixed categories included in their plan. (extra fee = product weight \* corresponding type of product price per weight)
- Customized plan subscribers, they can pay extra to receive additional items from the categories that they choose for this delivery. (Same computation method as farmer's choice)
