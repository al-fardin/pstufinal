# MEMBER 2 â€” INVENTORY & RELIABILITY VERTICAL SLICE

Contract Version: v1.0.0

Read first:

1. docs/phase0/PHASE_0_CONTRACT_FREEZE.md
2. contracts/openapi/inventory-service.v1.yaml
3. contracts/fixtures/*
4. .env.example

## Mission

Independently implement Inventory + reliability.

Do not implement Order Service business logic.

Provide the frozen Inventory contract exactly.

## Ownership

Member 2 owns:

- services/inventory-service/**
- frontend/features/inventory/**
- frontend/features/reliability/**
- monitoring/**
- infrastructure/**
- Inventory tests
- Inventory database
- fault injection

## Backend Requirements

- Fastify + TypeScript
- Prisma + PostgreSQL
- product/stock model
- operation record
- atomic stock adjustment
- operationId uniqueness
- idempotent duplicate handling
- stock GET endpoint
- dependency-aware /health
- /metrics
- deterministic latency
- crash-after-commit
- correlation-aware logs

## Idempotency

Same operationId:

First -> APPLIED.

Retry -> ALREADY_APPLIED.

Stock changes once.

## Crash After Commit

Test mode flow:

1. validate
2. check stock
3. update stock
4. persist operationId
5. commit
6. fail before success response

After restart, retry same operationId without another decrement.

## Frontend

Routes:

- /inventory
- /reliability

Display:

- stock
- operation history/outcome
- service health
- DB health
- fault state
- duplicate-protection evidence

## Monitoring

Own:

- Prometheus
- Grafana
- Inventory dashboard
- health visualization
- Order latency-panel integration point

Metrics:

- inventory_adjustments_total
- inventory_duplicate_operations_total
- inventory_fault_injections_total

## Definition of Done

- [ ] Inventory starts independently
- [ ] Inventory DB migration works
- [ ] Stock read works
- [ ] APPLIED works
- [ ] Duplicate -> ALREADY_APPLIED
- [ ] Duplicate does not decrement twice
- [ ] Multi-item transaction atomic
- [ ] Insufficient stock has no partial decrement
- [ ] 5000 ms latency works
- [ ] crash-after-commit works
- [ ] restart works
- [ ] retry after crash safe
- [ ] /health checks DB
- [ ] DB-down -> unhealthy
- [ ] metrics work
- [ ] frontend works
- [ ] provider contract tests pass
- [ ] monitoring works
- [ ] Frozen contract unchanged
