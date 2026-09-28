# PHASE 0 CONTRACT FREEZE

Contract Version: v1.0.0  
Status: FROZEN  
Change Policy: Joint approval required for any integration-sensitive change.

## 1. Goal

Build two independently implementable vertical slices around a frozen protocol:

- Member 1: Order vertical slice.
- Member 2: Inventory + reliability vertical slice.

After Phase 0, neither member needs the other member's code to implement and self-test.

## 2. Frozen Technology Baseline

- Node.js 24.x
- TypeScript
- Fastify backend
- Prisma ORM
- PostgreSQL
- React + Vite frontend
- Vitest
- k6
- Docker Compose
- Prometheus
- Grafana
- GitHub Actions

## 3. Service Boundaries

### Order Service owns

- Order creation and validation
- Order persistence
- Order state machine
- Shipment orchestration
- Inventory HTTP client
- operationId generation and persistence
- timeout/uncertain-outcome handling
- Order health and metrics

Order Service MUST NOT directly access Inventory DB.

### Inventory Service owns

- Product stock
- Inventory persistence
- Transactional stock adjustment
- operationId deduplication
- Deterministic latency fault
- crash-after-commit fault
- Inventory health and metrics

Inventory Service MUST NOT directly access Order DB.

## 4. Database Boundary

Order Service -> Order DB only.

Inventory Service -> Inventory DB only.

No shared database tables.

## 5. Network Contract

Frontend: http://localhost:5173

Order Service: http://localhost:3001

Inventory Service: http://localhost:3002

Order PostgreSQL host port: 5433

Inventory PostgreSQL host port: 5434

Prometheus: http://localhost:9090

Grafana: http://localhost:3000

API prefix: /api/v1

## 6. Correlation Contract

Header: X-Correlation-Id

- Caller may supply it.
- Receiving service generates a UUID when absent.
- Order forwards it to Inventory.
- Logs contain it.
- Correlation ID is not the idempotency identity.

## 7. Inventory Operation Identity

Field: operationId

Format: UUID

Rules:

1. Order Service creates operationId before the first adjustment attempt.
2. Order persists the operationId.
3. One logical inventory adjustment has exactly one operationId.
4. A retry of the same logical adjustment reuses that operationId.
5. Inventory persists successful operationIds.
6. The same operationId never creates the stock side effect twice.

ONE LOGICAL INVENTORY OPERATION = ONE BUSINESS EFFECT.

## 8. Order States

Externally visible states:

- READY_TO_SHIP
- INVENTORY_PENDING
- INVENTORY_UNCERTAIN
- SHIPPED
- FAILED

INVENTORY_UNCERTAIN means the Order Service did not receive a definitive acknowledgement.

It does NOT prove that Inventory failed to modify stock.

## 9. Create Order

POST /api/v1/orders

Input:

- customerId
- items[]
  - productId
  - quantity

Successful create status:

READY_TO_SHIP

Creation does not adjust stock.

## 10. Ship Order

POST /api/v1/orders/{orderId}/ship

Behavior:

1. Load Order.
2. Reuse existing operationId or create and persist one.
3. Move to INVENTORY_PENDING.
4. Call Inventory adjustment endpoint.
5. APPLIED -> SHIPPED.
6. ALREADY_APPLIED -> SHIPPED.
7. INSUFFICIENT_STOCK -> FAILED.
8. Timeout/network reset/no definitive acknowledgement -> INVENTORY_UNCERTAIN.
9. Retrying INVENTORY_UNCERTAIN reuses the same operationId.
10. Re-shipping SHIPPED must be safe.

## 11. Inventory Adjustment

POST /api/v1/inventory/adjustments

Request:

- operationId
- orderId
- correlationId
- items[]
  - productId
  - quantity

Successful outcomes:

- APPLIED
- ALREADY_APPLIED

Business rejection:

- INSUFFICIENT_STOCK

ALREADY_APPLIED is successful idempotent resolution.

## 12. Timeout

Order -> Inventory timeout:

2000 ms

Injected Inventory latency:

5000 ms

TIMEOUT != DEFINITE BUSINESS FAILURE.

A timeout only means that Order did not receive a definitive response within the allowed time.

Resulting Order state:

INVENTORY_UNCERTAIN

Contract v1 performs no automatic background retry.

## 13. Retry

Explicit retry is permitted from INVENTORY_UNCERTAIN.

Retry:

- uses the same orderId,
- reuses the same operationId,
- accepts APPLIED or ALREADY_APPLIED as success.

## 14. Error Envelope

Normal HTTP errors:

{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "retryable": false,
    "correlationId": "uuid",
    "details": {}
  }
}

Frozen codes:

- VALIDATION_ERROR
- ORDER_NOT_FOUND
- ORDER_NOT_SHIPPABLE
- INSUFFICIENT_STOCK
- INVENTORY_TIMEOUT
- INVENTORY_UNAVAILABLE
- INVENTORY_DB_UNAVAILABLE
- INTERNAL_ERROR

A crash-after-commit fault may terminate/reset the connection before a normal error envelope exists.

## 15. HTTP Semantics

- Create Order success: 201
- Get/List success: 200
- Ship confirmed: 200
- Ship uncertain: 202
- Validation: 400
- Not found: 404
- Business conflict: 409
- Dependency unavailable: 503
- Health unhealthy: 503

## 16. Health

Every service exposes:

GET /health

Order dependencies:

- Order database
- Inventory Service

Inventory dependencies:

- Inventory database

Healthy: HTTP 200

Unhealthy: HTTP 503

Static 200 without dependency verification is prohibited.

## 17. Test-Only Fault Contract

Fault injection requires:

APP_MODE=test

AND:

FAULT_INJECTION_ENABLED=true

Header:

X-Test-Fault-Mode

Allowed:

- none
- latency
- crash_after_commit

### latency

Inventory waits exactly INVENTORY_LATENCY_MS.

Frozen default:

5000 ms

### crash_after_commit

Inventory:

1. validates,
2. transactionally applies stock mutation,
3. persists operationId,
4. commits,
5. terminates/fails before a normal HTTP success response.

After restart, retrying the same operationId must not decrement again.

Production mode must not activate test faults.

## 18. Transaction Rule

For one adjustment:

- all products are validated,
- sufficient stock is checked,
- stock changes and operation record are committed transactionally.

Business validation failure causes no partial stock mutation.

## 19. Metrics

Order:

- order_http_request_duration_seconds
- order_http_requests_total
- order_inventory_calls_total
- order_inventory_timeouts_total

Inventory:

- inventory_adjustments_total
- inventory_duplicate_operations_total
- inventory_fault_injections_total

Both services expose:

/metrics

## 20. Dashboard

Required calculation:

rolling average Order response time over the previous 30 seconds.

Average <= 1 second:

GREEN

Average > 1 second:

RED

Reference PromQL:

rate(order_http_request_duration_seconds_sum[30s])
/
rate(order_http_request_duration_seconds_count[30s])

## 21. Frontend Ownership

One frontend application.

Member 1:

- frontend/app-shell/**
- frontend/features/orders/**

Member 2:

- frontend/features/inventory/**
- frontend/features/reliability/**

Routes:

- /orders
- /orders/:orderId
- /inventory
- /reliability

## 22. Repository Ownership

Member 1:

- services/order-service/**
- frontend/app-shell/**
- frontend/features/orders/**
- load-tests/**
- .github/workflows/**
- Order tests
- Order metrics

Member 2:

- services/inventory-service/**
- frontend/features/inventory/**
- frontend/features/reliability/**
- monitoring/**
- infrastructure/**
- Inventory tests
- Inventory fault injection

Shared/frozen:

- contracts/**
- docs/phase0/**
- CONTRACT_VERSION
- .env.example

## 23. Canonical Scenarios

### T01 NORMAL

Create Order.
Ship Order.
Inventory changes exactly once.
Order becomes SHIPPED.

### T02 LATENCY

Inventory delay = 5000 ms.
Order timeout = 2000 ms.
Order becomes INVENTORY_UNCERTAIN.
Order remains responsive.

### T03 DUPLICATE

Same operationId twice.

First -> APPLIED.

Second -> ALREADY_APPLIED.

Stock changes once.

### T04 COMMIT THEN CRASH

Inventory commits stock change and operationId.

Inventory fails before response.

Order cannot confirm outcome.

Inventory restarts.

Retry same operationId.

No second decrement.

### T05 INVENTORY DB DOWN

Inventory /health returns 503.

Database dependency is unhealthy.

### T06 LOAD ISOLATION

Some Inventory calls are intentionally slow.

Affected orders are identifiable.

Unrelated traffic continues.

### T07 LATENCY DASHBOARD

Rolling 30-second average Order response time > 1 second:

RED.

After recovery:

GREEN.

## 24. Development Model

CONTRACT
-> MOCK/FIXTURE
-> INDEPENDENT IMPLEMENTATION
-> SELF TEST
-> CONTRACT TEST
-> FINAL INTEGRATION

Member 1 develops against a mock Inventory provider.

Member 2 develops independently as the real Inventory provider.

## 25. Change Policy

Version: v1.0.0

Status: FROZEN

Any integration-sensitive change requires:

1. explicit proposal,
2. approval by both members,
3. version update,
4. both GPT contexts updated.

## 26. Exit Gate

Phase 0 is complete only when:

- this contract exists,
- both OpenAPI files exist,
- fixtures exist,
- environment names are frozen,
- ownership is frozen,
- validation passes,
- the contract is committed before independent implementation begins.
