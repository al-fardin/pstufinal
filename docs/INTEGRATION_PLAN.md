# Progressive Integration Plan

Status: high-level plan only. No feature-specific handoff or integration has happened.

## Flow and gates

1. Build and validate the walking skeleton in the next stage: real UI -> real backend -> contract-valid fake -> schema-valid UI response, including error, runtime, routing, environment, and database assumptions. **Do not freeze final contracts before this passes.**
2. Agree on final shared contracts separately, then owners build on `feature/FXX-*` in the same repository. Each owner proves their own real UI/API/domain/database path; mocks only replace other unfinished features.
3. Require a feature handoff with exports, dependency/contract versions, configuration, schema additions, passing feature tests, and a short working demo.
4. Integrate one feature at a time where practical on `integrate/FXX-*`: run compatibility and mock/real contract checks first, then make small additive route/provider/configuration changes. Preserve feature folders.
5. Run cross-feature and regression tests after each merge. Promote verified combined work to `integration`; pass a release/demo gate before advancing `main`. Keep `main` at the last known-good state.

## Expected order

- Baseline -> F01: register account/wallet UI/API and identity provider; verify one-time grant and persisted balance.
- Integrated F01 -> F02: verify real `AuthContext`/`AccountLookup` against F02's fake contract; register money-movement UI/API and bind F01; verify send, request, fulfillment, invalid/insufficient operations, retry, concurrent writes, refresh, and value conservation.
- Participant-described due-date and bill-splitting behavior stays tracked inside F02's capability. Resolve unspecified semantics with the actual source or an explicit assumption before coding those rules; never silently invent an organizer requirement.

## Failure routing

| Failure class | Primary owner |
|---|---|
| Route registration, provider binding, integration-only adapter or regression wiring | Integrator |
| Feature validation, API implementation, money/request business rule | Feature Owner |
| Shared candidate contract conflict, architecture boundary, shared schema, migration runner | Lead Architect, with Human Lead approval for major change |
| Environment/runtime mismatch | Lead for shared config; Feature Owner for feature-local setup |

If integration requires rewriting feature logic, return it to the Feature Owner. A significant boundary or dependency change uses the Architecture Change Request in `RULES.md`.
