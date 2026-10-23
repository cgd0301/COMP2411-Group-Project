# Rules
1. Subscription (of a season)
   - subscription range: a season (12 weeks, 12 planned delivery days (Delivery planning day), start: 6 days before first delivery day; end: the last planning delivery day (both included))
   - The subscription becomes active on the first day of the subscription range to the end day of the subscription range (both included)
   - Subscription condition: subscription window for each season is the season before that (e.g. winter for spring, spring for summer, summer for autumn, since winter is not counted as a season for subscription, autumn will not open for winter subscription)
   - A subscription can be cancelled before its subscription season begins with full refundability, can be cancelled during its subscription season with limited fundability, but can not be canelled after its season ends since the subscription is finished at that time.
   - There are 2 plan types for a seasonal subscription, including farmers' choice subscription and customizable subscription.
   - There are 2 frequency types for each types of subscription: weekly (once a week), biweekly (once two week; For each season, the first Delivery Planning Date is an actual subscription delivery date, the second is not, and the pattern continues alternately thereafter.) (Two frequency shares the same planning delivery days, however, biweekly frequency will not have actual delivery on some of the planning deivery days)
   - The frequency and plan of subscription are immutable once the subscription is submitted
   - Each subscription is for exactly one season: the spring, summer or autumn (exclusive) of one year; a season is identified by its name and year
   - There are 4 status of subscription of each season: planned, active, finished and cancelled
      1. planned: the subscription season does not start, the customer has subscribed for this season and has not cancelled it
      2. active: the season for this subscription has started, customer does not cancel the subscription
      3. finished: the subscription season ends, the customer does not cancel the subscription
      4. cancelled: the subscription has been cancelled by customer

2. Customer
   - A customer could have multiple subscription. However, they can have at most one subscription for a specific season.
   - Each customer has a unique email.


3. Delivery
   - Each delivery has 1 statuse, can be success, failed, skipped, planned, cancelled (cancelled would only happen if the customer cancells the subscription)
   - On the first day of the subscription range, every subscription of this season that is not cancelled gets all its deliveries with status planned (weekly: all 12 planning days; biweekly: the 1st, 3rd, 5th, 7th, 9th and 11th); before that day a subscription has no delivery
   - Each delivery has exactly one corresponding delivery day; a delivery is identified by its subscription and its week number (1 to 12), and its delivery day = first planning day + 7 × (week number − 1)
   - Monday is set to be the delivery planning day for each week. (Delivery can only happen on Monday, whether each customer has delivery on that day depends on their subscription status, subscription plan and frequency type, whether they choose to skip that day; A Delivery Planning Day does not imply that every customer has a delivery scheduled on that date.)
   - If customers do not choose to skip the delivery and their subscription status is active for this season, the status of the delivery will be kept as planned until the delivery day, If subscription status is cancelled for this season, the status of every planned delivery whose delivery day is after the cancellation date will be set to cancelled; a planned delivery on or before the cancellation date keeps waiting for its result
   - The day after the delivery day, for delivery (whose status is planned) planned to happen on that delivery day and not skipped by customers, the status will be changed to either success or failed from planned

   - Skipping delivery
      1. For a delivery, from the next day of previous planned delivery day to yesterday of the planned delivery day, customers can choose to skip the delivery. (refundability is defined in the refundability rules)
      2. Since there is not previous delivery day of the first delivery day of a season, for that day, customer could make a skip for the delivery on that day from 6 days ago to yesterday of that day
      3. A delivery whose status has become success/failed/cancelled can not be skipped
      4. Once skipped, the status of the delivery will be changed to skipped, and can not be modified to success/failed/planned later

   - Add-on purchase on delivery
      1. For a delivery, from the next day of last delivery day of planned delivery day to yesterday of the planned delivery day, customers can choose to purchase add-on products (customer can determine the weight (at least 0.1 kg) of each type (1 to 8) of products that can be choosen in the add-on purchase for the customer). 
      2. The types of choosable products is limited to their plan's product types (for farmers' choice plan), or the product types they choose for their plan (for customizable plan). 
      3. Since there is not previous delivery day of the first delivery day of a season, for that day, customer could make add-on purchase from 6 days ago to yesterday of that day.

4. Price
   - the price of each delivery is counted as : allocated subscription cost per delivery + fee of add-on purchase for that delivery
   - allocated subscription cost per delivery for farmers' choice plan is 200 HKD, for customizable plan is 240 HKD
   - subscription fee for a season = planned delivery times for the season under specified frequency * allocated subscription cost per delivery for specified plan (if a customer have subscribed for the last subscribing season, (like autumn for spring, spring for summer, summer for autumn), and the status of the subscription is active/finished, there will be a 20 percent-off on the allocated subscription cost per delivery for that season)
   - add-on purchase fee = add up (for each product, weight * price per weight)
   - Cancellation of the subscription should counted refunding first and updatethe refundable skipping to zero then update the delivery status

5. Refundability
   - for each seasonal subcription, the owner of the subscription enjoys 2 times of refundable skipping during that season (every skipping will consumer a refundable skipping time, which means minus 1 (the refundable skipping time should be >= 0))
   - if the refundable skipping time is 0, the delivery can still be skipped, but there customer will not be refunded the allocated subscription cost per delivery for specified plan and the fee of add-on purchase
   - refunding fee for a skipping delivery = allocated subscription cost per delivery for specified plan (20 percent off discount for a renewal subscription) + fee of add-on purchase for that delivery (if a customer does not require an add-on purchase for that delivery, the fee of add-on purchase is 0; Refunding fee will be issued on the same day when the skipping requirement is submitted)
   - refunding fee for a failed delivery = allocated subscription cost per delivery for specified plan (20 percent off discount for a renewal subscription) + fee of add-on purchase for that delivery; it is refunded on the day after the delivery day, when the delivery is changed to failed, and it does not use a refundable skipping time
   - refunding fee for subscription during its season: min(left refundable skipping time, number of delivery in "planned" status whose delivery day is after the cancellation date) * allocated subscription cost per delivery for specified plan (20 percent off discount for a renewal subscription) + add-on fee for those deliveries
   - Each refund record belongs to exactly one subscription and has a type: skip, failed or cancellation. A skip or failed refund refers to exactly one delivery of the same subscription (a delivery has at most one refund); a cancellation refund refers to no delivery


6. Plan
   - Farmer's choice plan: 6 types of products (can not choose for types of products, and types of products will not change during the whole season)
   - Customizable choice plan: 8 types selected from total of 10 types of products of its own season when subscribing, (types are chosen and subscription is submitted, the types of products is immutable since the subscription range starts)


7. Agriculture product
   - Each product belongs to exactly one season; each season has exactly 10 products, 6 of which are flagged as farmers' choice
   - Spring
   Farmers' Choice: Spinach 32 HKD/kg, Lettuce 22 HKD/kg, Pak Choi 20 HKD/kg, Chinese Kale 28 HKD/kg, Choy Sum 35 HKD/kg, Broccoli 30 HKD/kg  
   Customizable: Spinach 32 HKD/kg, Lettuce 22 HKD/kg, Pak Choi 20 HKD/kg, Chinese Kale 28 HKD/kg, Choy Sum 35 HKD/kg, Broccoli 30 HKD/kg, Carrots 15 HKD/kg, Snow Peas 48 HKD/kg, Asparagus 58 HKD/kg, Strawberries 85 HKD/kg

   - Summer
   Farmers' Choice: Tomatoes 25 HKD/kg, Cucumbers 18 HKD/kg, Eggplants 22 HKD/kg, Green Beans 32 HKD/kg, Bell Peppers 38 HKD/kg, Sweet Corn 25 HKD/kg  
   Customizable Plan: Tomatoes 25 HKD/kg, Cucumbers 18 HKD/kg, Eggplants 22 HKD/kg, Green Beans 32 HKD/kg, Bell Peppers 38 HKD/kg, Sweet Corn 25 HKD/kg, Watermelon 12 HKD/kg, Hairy Gourd 16 HKD/kg, Okra 42 HKD/kg, Bitter Melon 28 HKD/kg

   - Autumn
   Farmers' Choice: Cabbage 18 HKD/kg, Cauliflower 26 HKD/kg, Pumpkin 14 HKD/kg, Sweet Potatoes 18 HKD/kg, White Radish 12 HKD/kg, Napa Cabbage 16 HKD/kg  
   Customizable Plan: Cabbage 18 HKD/kg, Cauliflower 26 HKD/kg, Pumpkin 14 HKD/kg, Sweet Potatoes 18 HKD/kg, White Radish 12 HKD/kg, Napa Cabbage 16 HKD/kg, Kale 35 HKD/kg, Leeks 32 HKD/kg, Taro 25 HKD/kg, Winter Melon 15 HKD/kg
