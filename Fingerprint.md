G7/ /D17-W04
Organization name and type:
Farmlander Farm/ this is a local farm operating a Community Supported Agriculture(CSA) style subscription.
Principal users/roles:
Staff form the farm doing some operation like managing seasons,plans,recording payments,refounding, and add-on orders/ as well as subscribed customers doing things like enroling, renewing, choosing the customizable plan's product types when subscribing, skiping, add-on orders.
Business object and core event:
a seasonal CSA style subscription(spring/summer/autumn seasons, each having 12 weeks). The core event is enrolment for delivery from local farm, recording each delivery, a refundable skip (at most 2; a further skip is allowed without a refund), and add-on purchase. There is no mid-season join and no prorated price.
Distinctive policy or constraint:
the subscription window is the previous season (winter for spring, spring for summer, summer for autumn). A renewal whose previous subscription is active or finished gets 20% off the allocated cost per delivery (farmer's choice 200 HKD, customizable 240 HKD). Add-on purchases are limited to the plan's products (farmer's choice: 6 fixed types; customizable: 8 types chosen from 10 when subscribing). Cancellation before the season refunds the fee already charged; during the season the refund is limited to the remaining refundable skips and add-ons already on planned deliveries; after the season the subscription cannot be cancelled.
Management questions:
Q1:How many subscriptions(per plan type) were sold in the past season, and what is the net income after refunding and the total refund amount?/Q2: Based on the plan type, which products have the biggest add-on income of successful deliveries?/Q3: which delivery weeks have the highest skip rates and failure rates?/Q4:Which product is most frequently selected when customers subscribe to the customizable plan./Q5: What proportion of each plan's subscribers renewed into the next season, and which plan had a renewal rate below 60%?
Excluded processes:
no delivery assignment; no real payment process; no farm production management;
Workflow fit and scope rationale：
Because a CSA style subscription works like membership naturally: customers pay then they get the vegetable box, just like the farmer harvesting, so that's why the rules of our DB are from the daily real questions; For main challenges, a skip refund, a failed-delivery refund and an in-season cancellation refund all use the subscription's allocated cost per delivery, and a renewal discount depends on the previous season's status rather than on a balance; and our design has 8 tables, and each table supports one rule(at least) as well as all rules can be shown with manual SQL checks.
