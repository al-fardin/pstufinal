# FINAL INTEGRATION EXECUTION

Contract Version: v1.0.0

Integration begins only after both members pass their Definition of Done.

No new architecture is invented here.

## Preconditions

- [ ] Member 1 complete
- [ ] Member 2 complete
- [ ] Member 1 contract tests pass
- [ ] Member 2 contract tests pass
- [ ] Both use v1.0.0
- [ ] Frozen contract unchanged

## Happy Path

Frontend
-> Order Service
-> Inventory Service
-> Inventory DB

Expected:

- Order created
- READY_TO_SHIP
- ship triggered
- APPLIED
- stock changes once
- SHIPPED

## Deterministic Latency

Inventory latency: 5000 ms.

Order timeout: 2000 ms.

Expected:

- bounded response
- INVENTORY_UNCERTAIN
- unrelated traffic continues

## Commit-Before-Response Crash

Initial stock: 10

Quantity: 1

Expected:

10 -> 9 -> operation persisted -> COMMIT -> response lost/crash.

Order -> INVENTORY_UNCERTAIN.

Inventory restarts.

Retry same operationId.

Inventory -> ALREADY_APPLIED.

Final stock = 9.

Stock MUST NOT become 8.

## Health Failure

Break Inventory DB.

Expected:

Inventory /health -> 503.

Order /health reflects unhealthy Inventory dependency.

Restore and verify recovery.

## Load

Verify:

- concurrent orders
- deterministic slow requests
- affected order IDs recorded
- healthy traffic continues
- expected faults do not abort the test flow

## Monitoring

30-second rolling Order average <= 1 second -> GREEN.

30-second rolling Order average > 1 second -> RED.

Verify recovery to GREEN.

## Frontend

Verify real integrated routes:

- /orders
- /orders/:orderId
- /inventory
- /reliability

## CI

Final CI:

1. build
2. start infrastructure
3. migrate
4. start services
5. wait for health
6. contract tests
7. backend tests
8. frontend build/tests
9. happy-path E2E
10. latency scenario
11. duplicate scenario
12. crash-after-commit scenario
13. load tests
14. collect logs/results
15. cleanup

## Cloud

Deploy a small-scale environment outside localhost.

Verify frontend, Order, Inventory, databases, networking, health and normal Order flow.

## Final Rule

Integration may fix implementation defects.

Integration may not silently modify frozen v1.
