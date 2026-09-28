# AI Context — PSTU Money Movement

- **Project:** Simulated BDT money movement app from a recovered PSTU National Hackathon 2026 final-round question. This is not the organizer-issued original.
- **Users:** Registered app users who hold demo balances, send funds, request funds, and fulfill requests addressed to them.
- **Core MVP:** Create account and one-time grant; view persistent balance; send; create request without movement; see incoming pending requests; payer fulfills; persist state. Reject invalid users/amounts/states and insufficient funds; atomic movement; safe retry/concurrency; conserve value after grants.
- **Participant-described extensions:** Due-date requests and multi-party bill splitting. They are included in scope tracking, but their exact behavior is unconfirmed. No invented rule may be labeled official.
- **Architecture:** One repo, one app/backend/database, two vertical features. `F01-accounts-wallet` owns accounts, minimum identity, initial grant, balance reads; `F02-money-movement` owns send, requests, fulfillment, and subsequent balance writes. Count is based on boundaries, not the two humans.
- **Dependencies:** F02 consumes F01's candidate identity/account-lookup interfaces; can develop against a conforming fake. No reverse dependency or access to F01 internals.
- **Shared components:** Candidate contracts, core user/wallet schema, HTTP and error conventions, transaction/runtime setup, root app composition. Exact contract fields are **not finally frozen**.
- **Baseline:** Architecture v1 **APPROVED**, derived from human-approved V2 and later scope clarifications. Docs in this repository override AI chat recollection.
- **Rules:** Own real feature frontend + backend + logic + tests; keep implementation inside `src/features/FXX-*/`; integrate by small registrations/bindings; do not silently change shared contracts or other feature internals; preserve demo-safe `main`.
- **Do not change without approval:** Feature count/IDs/boundaries, dependency direction, data ownership, folder preservation, integration philosophy, and Git model. Use the Architecture Change Request in `RULES.md` for major changes.
- **Current stage:** `ARCHITECTURE_APPROVED`. Next: **build and validate walking skeleton**, then separately freeze contracts before parallel feature implementation. No feature code or skeleton exists from this baseline step.
