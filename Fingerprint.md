G7/ /D17-W04
Organization name and type:
Farmlander Farm/ this is a local farm operating a Community Supported Agriculture(CSA) style subscription.
Principal users/roles:
Staff form the farm doing some operation like managing seasons,plans,recording payments,refounding, and add-on orders/ as well as subscribed customers doing things like enroling, renewing, customizing, skiping, add-on orders.
Business object and core event:
a seasonal CSA style subscription(spring/summer/autumn seasons, each having 12 weeks). The core event is enrolment for delivery from local farm,with prorated price for mid-season joins, recording each delivery as well as refundable skip(max 2), and add-on purchase.
Distinctive policy or constraint:
prorated price for mid-season enrolment which remains scheduled delivery of the plan./there is a refund for the remaining delivery times in the end of the season at the plan's per delivery price./ add-on purchases are restricted to the categories included in the subscibers' plan type (farmer's choice customer can only choose 6 fixed types, customizable customer can choose 8 types to add on that they choose when subscribes for the plan)./ the cancellation is allowed without refund.
Management questions:
Q1:How many subscriptions(per plan type) were sold in the past season, and what is the net income after refunding?/Q2: Based on the plan type, which product categories have the biggest add-on income?/Q3: which delivery weeks have the highest skip rates?/Q4:Which product is most frequently picked in customizable plan.
Excluded processes:
no delivery assignment; no real payment process; no farm production management;
Workflow fit and scope rationale：
Because a CSA style subscription works like membership naturally: customers pay then they get the vegetable box, just like the farmer harvesting, so that's why the rules of our DB are from the daily real questions; For main challenges, a skip creates a refund, which changes the customers' balance for the renew check; and our design has 8 tables, and each table supports one rule(at least) as well as all rules can be shown with manual SQL checks.
