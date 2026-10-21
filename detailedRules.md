# Rules
1. Subscription (of a season)
   - subscription range: a season (12 weeks, 12 planned delivery days (Delivery planning day), start: 6 days before first delivery day; end: the last planning delivery day (both included))
   - The subscription becomes active on the first day of the subscription range to the end day of the subscription range (both included)
   - Subscription condition: subscription window for each season is the season before that (e.g. winter for spring, spring for summer, summer for autumn, since winter is not counted as a season for subscription, autumn will not open for winter subscription)
   - A subscription can be cancelled before its subscription season begins with full refundability, can be cancelled during its subscription season with limited fundability, but can not be canelled after its season ends since the subscription is finished at that time.
   - There are 2 plan types for a seasonal subscription, including farmers' choice subscription and customizable subscription.
   - There are 2 frequency types for each types of subscription: weekly (once a week), biweekly (once two week; For each season, the first Delivery Planning Date is an actual subscription delivery date, the second is not, and the pattern continues alternately thereafter.) (Two frequency shares the same planning delivery days, however, biweekly frequency will not have actual delivery on some of the planning deivery days)
   - The frequency and plan of subscription are immutable once the subscription is submitted
   - There are is a season attribute for a subscription: can be spring, summer and autumn (exclusive)
   - There are 4 status of subscription of each season: planned, active, finished and cancelled
      1. planned: the subscription season does not start, the customer has subscribed for this season and not choose to skip
      2. active: the season for this subscription has started, customer does not cancel the subscription
      3. finished: the subscription season ends, the customer does not cancel the subscription
      4. cancelled: the subscription has been cancelled by customer

2. Customer
   - A customer could have multiple subscription. However, they can have at most one subscription for a specific season.


3. Delivery
   - Each delivery has 1 statuse, can be success, failed, skipped, planned, cancelled (cancelled would only happen if the customer cancells the subscription)
   - At the beginning of this season, status of every planned delivery for each subscriber of this season will be set to planned
   - Each delivery has exactly one corresponding delivery day
   - Monday is set to be the delivery planning day for each week. (Delivery can only happen on Monday, whether each customer has delivery on that day depends on their subscription status, subscription plan and frequency type, whether they choose to skip that day; A Delivery Planning Day does not imply that every customer has a delivery scheduled on that date.)
   - If customers do not choose to skip the delivery and their subscription status is active for this season, the status of the delivery will be kept as planned until the delivery day, If subscription status is cancelled for this season, the status of all the planned delivery will be set to cancelled
   - The day after the delivery day, for delivery (whose status is planned) planned to happen on that delivery day and not skipped by customers, the status will be changed to either success or failed from planned

   - Skipping delivery
      1. For a delivery, from the next day of previous delivery day of planned delivery day to yesterday of the planned delivery day, customers can choose to skip the delivery. (refundability is defined in the refundability rules)
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
   - for each seasonal subcription, the owner of the subscription enjoys 2 times of refundable skipping during that season
   - if the refundable skipping time is 0, the delivery can still be skipped, but there customer will not be refunded the allocated subscription cost per delivery for specified plan and the fee of add-on purchase
   - refunding fee for a skipping delivery = allocated subscription cost per delivery for specified plan (20 percent off discount for a renewal subscription) + fee of add-on purchase (if a customer does not require an add-on purchase for that delivery, the fee of add-on purchase is 0)
   - refunding fee for subscription during its season: min(left refundable skipping time, number of delivery in "planned" status) * allocated subscription cost per delivery for specified plan (20 percent off discount for a renewal subscription) + add-on fee for delivery in "planned status"

6. Plan
   - Farmer's choice plan: 6 types of products (can not choose for types of products, and types of products will not change during the whole season)
   - Customizable choice plan: 8 types selected from total of 10 types of products when subscribing, (types are chosen and subscription is submitted, the types of products is immutable since the season starts)


7. Agriculture product
   - Spring
   Farmers' Choice: Spinach 32 HKD/kg, Lettuce 22 HKD/kg, Pak Choi 20 HKD/kg, Chinese Kale 28 HKD/kg, Choy Sum 35 HKD/kg, Broccoli 30 HKD/kg  
   Customizable: Spinach 32 HKD/kg, Lettuce 22 HKD/kg, Pak Choi 20 HKD/kg, Chinese Kale 28 HKD/kg, Choy Sum 35 HKD/kg, Broccoli 30 HKD/kg, Carrots 15 HKD/kg, Snow Peas 48 HKD/kg, Asparagus 58 HKD/kg, Strawberries 85 HKD/kg

   - Summer
   Farmers' Choice: Tomatoes 25 HKD/kg, Cucumbers 18 HKD/kg, Eggplants 22 HKD/kg, Green Beans 32 HKD/kg, Bell Peppers 38 HKD/kg, Sweet Corn 25 HKD/kg  
   Customizable Plan: Tomatoes 25 HKD/kg, Cucumbers 18 HKD/kg, Eggplants 22 HKD/kg, Green Beans 32 HKD/kg, Bell Peppers 38 HKD/kg, Sweet Corn 25 HKD/kg, Watermelon 12 HKD/kg, Hairy Gourd 16 HKD/kg, Okra 42 HKD/kg, Bitter Melon 28 HKD/kg

   - Autumn
   Farmers' Choice: Cabbage 18 HKD/kg, Cauliflower 26 HKD/kg, Pumpkin 14 HKD/kg, Sweet Potatoes 18 HKD/kg, White Radish 12 HKD/kg, Napa Cabbage 16 HKD/kg  
   Customizable Plan: Cabbage 18 HKD/kg, Cauliflower 26 HKD/kg, Pumpkin 14 HKD/kg, Sweet Potatoes 18 HKD/kg, White Radish 12 HKD/kg, Napa Cabbage 16 HKD/kg, Kale 35 HKD/kg, Leeks 32 HKD/kg, Taro 25 HKD/kg, Winter Melon 15 HKD/kg
