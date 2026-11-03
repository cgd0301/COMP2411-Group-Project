# Limitations

- A biweekly subscription's even-week delivery inserted directly, bypassing the generation INSERT ... SELECT, is not blocked.
- An add-on line inserted directly, bypassing the INSERT ... SELECT, is not checked against the subscription's plan.
