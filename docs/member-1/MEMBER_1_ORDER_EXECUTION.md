# MEMBER 1 â€” ORDER VERTICAL SLICE

Contract Version: v1.0.0

Read first:

1. docs/phase0/PHASE_0_CONTRACT_FREEZE.md
2. contracts/openapi/order-service.v1.yaml
3. contracts/openapi/inventory-service.v1.yaml
4. contracts/fixtures/*
5. .env.example

## Mission

Independently implement the complete Order vertical slice.

Do not implement the real Inventory Service.

Develop against a mock Inventory provider matching the frozen contract.

## Ownership

Member 1 owns:

- services/order-service/**
- frontend/app-shell/**
- frontend/features/orders/**
- load-tests/**
- .github/workflows/**
- Order tests
- Order metrics

Do not modify Member 2 implementation areas.

## Backend Requirements

- Fastify + TypeScript
- Prisma + PostgreSQL
- Create/List/Get Order
- Ship Order
- Persist operationId
- Inventory HTTP client
- 2000 ms timeout
- INVENTORY_UNCERTAIN
- retry same operationId
- /health
- /metrics
- correlation-aware logs

## Frontend Requirements

Routes:

- /orders
- /orders/:orderId

Show:

- create order
- list/detail
- shipment action
- READY_TO_SHIP
- INVENTORY_PENDING
- INVENTORY_UNCERTAIN
- SHIPPED
- FAILED
- user-friendly timeout/failure messages

## Required Mock Inventory Scenarios

- APPLIED
- ALREADY_APPLIED
- INSUFFICIENT_STOCK
- 5000 ms latency
- no definitive response
- service unavailable

## Required Metrics

- order_http_request_duration_seconds
- order_http_requests_total
- order_inventory_calls_total
- order_inventory_timeouts_total

## Load Test

Own k6 tests for:

- healthy concurrency
- deterministic latency
- affected-order recording
- unaffected traffic continuing
- generating latency for the rolling 30-second alert

## Definition of Done

- [ ] Order service starts independently
- [ ] Order DB migration works
- [ ] Create/List/Get work
- [ ] Ship + APPLIED works
- [ ] ALREADY_APPLIED is success
- [ ] Timeout is bounded
- [ ] Timeout -> INVENTORY_UNCERTAIN
- [ ] Retry reuses operationId
- [ ] Insufficient stock -> FAILED
- [ ] Frontend works
- [ ] Metrics work
- [ ] Health works
- [ ] Load test works
- [ ] Contract tests pass
- [ ] CI passes
- [ ] Frozen contract unchanged
