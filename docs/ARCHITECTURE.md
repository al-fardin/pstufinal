# Architecture Baseline v1

Status: **APPROVED**. Source: human-approved Architecture V2, with the Human Lead's later clarifications: two humans; cover the recovered PDF without cutting requirements for time; distinguish confirmed core from participant-described extensions. This baseline freezes architectural boundaries, **not final API contracts**.

**Frozen at this baseline:** the two feature IDs and boundaries, vertical ownership, F01-to-F02 dependency direction, feature-folder preservation, shared/data ownership, integration-layer role, repository layout, progressive Git model, mock strategy, test layers, and Lead/owner/integrator responsibilities.

**Still provisional until the walking skeleton and separate contract freeze:** exact API fields/statuses, identity/session mechanism, amount representation, runtime and database engine, ports, environment names, and minor wiring. Refinements must respect the frozen boundaries; a major change uses `RULES.md`'s Architecture Change Request.

## System and scope

A single repository contains a user-facing application, one authoritative backend, and one transactional persistent database for simulated BDT. Users create accounts, receive one demo balance grant, view balances, send money, create and view requests, and fulfill requests. Invalid operations, retries, and concurrency must not corrupt balances or request state. The recovered PDF cites BDT 100,000 as a finalist's starting-balance interpretation; the organizer's original question is unavailable.

The PDF also describes due-date requests and multi-party bill splitting through a participant report. Track and design for these as **participant-described extended capabilities**, without claiming their unspecified rules are official. There is no AI/ML requirement. Real banking, cards, gateways, deposits, withdrawals, settlement, KYC, and real-money custody are outside the recovered core.

## Feature catalog and boundaries

Feature count follows cohesive capabilities, **not team size**. The two-person team is expected to work on the two approved feature modules.

### F01 — Accounts and Wallet

- **Purpose / owner:** Identity, account provisioning, and balance reading. Likely owner: Human Lead as a vertical feature owner.
- **Owns:** Registration and the minimum identity/session mechanism needed to identify the caller; one-time demo balance grant; account lookup; persisted balance view. Own UI, API, validation, service, data access, tests, and any feature-local mock.
- **Out of scope:** Sending funds, request lifecycle, and later balance movement. No particular password/login scheme is an organizer requirement.
- **Consumes:** Shared database, HTTP/error conventions, and candidate data contracts.
- **Provides:** Candidate `AuthContext`, `AccountLookup`, and `WalletBalance` interfaces for F02 and UI.
- **External dependency / mock:** Database runtime; no other feature required to demonstrate its real vertical path.
- **Integration:** Export frontend and backend routes and identity/account provider. Integrator registers exports and binds the provider; no relocation.

### F02 — Money Movement

- **Purpose / owner:** Keep all balance-changing operations and request fulfillment under one coherent transactional authority. Likely owner: other human as a vertical feature owner.
- **Owns:** Direct send, money request creation, payer's pending list, fulfillment, transaction and retry handling, persisted state, correctness under concurrent operations; own UI, API, validation, domain/data code, mocks, tests. Due-date requests and bill splitting are tracked within this capability as participant-described extensions; their unspecified rules remain provisional.
- **Out of scope:** Account creation, initial grant, identity issuance, real-money integrations.
- **Consumes:** F01's candidate `AuthContext` and `AccountLookup`, shared wallet schema, database transaction facility, HTTP/error conventions.
- **Provides:** Candidate `Transfer` and `MoneyRequest` results and feature routes.
- **External dependency / mock:** Database runtime; contract-valid F01 account/identity fake allows independent development. Real F01 integration is required before combined acceptance.
- **Integration:** Register frontend and backend routes; bind real F01 provider; apply F02-owned schema additions in the agreed order. No business-logic rewrite.

## Dependency direction

`F01 AuthContext / AccountLookup -> F02`. F02 may use the approved interface or a contract-valid fake, never F01 internals. Both use central HTTP/database conventions. F01 never imports F02. A missing identity rejects protected writes; an unknown target rejects before money or request state changes. Provider delay does not block F02's own vertical development.

## Data ownership and invariants

- Lead controls the canonical `users` and `wallets` schema and migration ordering. F01 creates a user plus one wallet/grant atomically and reads balance. F02 alone changes wallet balances after provisioning and owns `transfers` and `money_requests` schema/data.
- A request starts pending and creates no money movement. Fulfillment validates payer and state, moves funds once, and marks the request completed **in one database transaction owned by F02**.
- Debit and credit both commit or both roll back. Rejected operations leave balances and request state unchanged. Retries do not repeat financial effects; concurrent writes cannot accept negative balances or double-spending. After grants, total simulated value is conserved.
- Shared ID type, amount unit/range, error shape, request states, identity semantics, and DB transaction choice are contract candidates. Their exact fields and runtime binding are validated in the walking skeleton, then frozen separately.

## Shared versus feature-local

Shared/controlled: contracts, core user/wallet representation, HTTP conventions, runtime and environment definition, app shell, root routing, package dependencies, migration runner. Feature-local: pages, routes exported for registration, validation, domain rules, data access, feature fakes, and feature tests. `src/integration/` contains route/provider binding, configuration, adapters, and cross-feature tests, not feature business rules.

## Folder preservation and repository structure

Feature implementation stays in its own folder after integration. Integration imports, registers, binds, routes, configures, adapts, composes, and tests; it does not copy, flatten, relocate, duplicate, or rewrite feature internals. Business-rule changes return to the feature owner.

```text
docs/                 architecture, AI context, rules, decisions, state, integration plan
contracts/            provisional shared contract candidates; final freeze later
src/shared/           minimal common runtime and types
src/features/F01-accounts-wallet/    complete F01 vertical implementation
src/features/F02-money-movement/     complete F02 vertical implementation
src/integration/      route and provider composition only
tests/integration/    cross-feature tests
tests/e2e/            critical user flows
```

The Git model is `feature/FXX-*` for feature work, optional `integrate/FXX-*` for temporary compatibility checks, `integration` for the latest verified combined system, and `main` for the last known-good demo-safe state. The next stage is the walking skeleton. No production feature or skeleton has been implemented by this baseline.
