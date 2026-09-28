# Development Rules — Architecture Baseline v1

1. **One repository is authoritative.** Repository docs/contracts and current project state override assumptions from a previous AI chat.
2. **Vertical ownership.** A feature owner handles its relevant frontend, backend, API, domain logic, validation, data access, mock, and tests. Do not split ownership into all frontend versus all backend.
3. **Feature folders persist.** Do not move, flatten, copy, or duplicate feature implementation during integration. Do not edit another owner's feature internals without coordinating with that owner.
4. **Dependency direction is fixed.** F02 consumes F01's published identity/account lookup interface. Neither feature imports another feature's private implementation. F01 has no F02 dependency.
5. **Shared changes are controlled.** The Lead reviews shared schema, contracts, root app, environment, dependencies, and migration runner. Candidate API fields are not finally frozen until after the walking skeleton. No unilateral breaking change while another person is working.
6. **Mocks must follow the same candidate contract as the real provider.** Their fields, meaning, version, and error behavior are checked against the real implementation before integration acceptance.
7. **A handoff requires a real feature vertical path.** The owner tests their own UI -> real API -> real feature logic/database, documents exports/dependencies, and supplies feature tests. A mock may stand in only for another unfinished feature.
8. **Integration is additive.** The Integrator registers routes, binds providers, adds configuration/adapters and cross-feature tests. Feature business-rule repairs return to the Feature Owner; contract/architecture conflicts return to the Lead Architect.
9. **Git safety.** No direct feature development on `main`. `main` holds the last known-good demo; `integration` holds the latest verified combined state; use feature branches and temporary integration branches as appropriate. No branch has been created by this baseline.
10. **Problem provenance.** Preserve all recovered core rules. Keep participant-described due dates/bill splitting visible but label unconfirmed semantics. Do not add real-money systems, receipts, AI models, or other behavior as if required by the question.

## Architecture Change Request

Major changes to feature boundaries/count, dependency direction, shared data ownership, folder or Git model need an explicit request. Minor feature-internal implementation choices do not.

```text
ARCHITECTURE CHANGE REQUEST
Request ID:
Requested by:
Current architecture:
Requested change:
Reason:
Why current architecture cannot support the requirement:
Features affected:
Contracts affected:
Active work affected:
Integration impact:
Migration impact:
Alternative solutions considered:
Risk if rejected:
Risk if approved:
```

The Lead Architect AI reviews the request; the **Human Lead** gives final approval. Record an approved change in `DECISIONS.md` and update affected documents together.
