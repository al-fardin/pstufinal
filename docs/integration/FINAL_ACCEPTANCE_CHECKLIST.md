# FINAL ACCEPTANCE CHECKLIST

## Architecture

- [ ] Order Service separated
- [ ] Inventory Service separated
- [ ] Order DB separated
- [ ] Inventory DB separated
- [ ] No cross-service DB access

## Contract

- [ ] v1.0.0
- [ ] OpenAPI matches implementation
- [ ] Error semantics respected
- [ ] Correlation ID propagated
- [ ] operationId persisted/reused

## Order

- [ ] create
- [ ] list
- [ ] get
- [ ] ship
- [ ] timeout
- [ ] uncertain state
- [ ] retry
- [ ] SHIPPED

## Inventory

- [ ] stock read
- [ ] adjustment
- [ ] atomic multi-item transaction
- [ ] insufficient-stock protection
- [ ] deduplication
- [ ] APPLIED
- [ ] ALREADY_APPLIED

## Reliability

- [ ] deterministic latency
- [ ] bounded timeout
- [ ] unrelated requests continue
- [ ] crash after commit
- [ ] response lost
- [ ] retry same operationId
- [ ] no double decrement

## Health

- [ ] Order /health
- [ ] Order DB
- [ ] Inventory dependency
- [ ] Inventory /health
- [ ] Inventory DB
- [ ] unhealthy -> 503

## Metrics

- [ ] Order metrics
- [ ] Inventory metrics
- [ ] Prometheus
- [ ] Grafana

## Alert

- [ ] rolling window = 30 seconds
- [ ] <= 1 sec -> GREEN
- [ ] > 1 sec -> RED

## Automation

- [ ] CI starts system
- [ ] tests automatic
- [ ] load generated
- [ ] affected orders recorded
- [ ] expected faults do not abort full flow

## Frontend

- [ ] Order page
- [ ] Order detail
- [ ] Inventory page
- [ ] Reliability page
- [ ] timeout visible
- [ ] health visible
- [ ] stock behavior visible

## Cloud

- [ ] deployed outside local machine
- [ ] service networking works
- [ ] persistence works
- [ ] smoke test passes
