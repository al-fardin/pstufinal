# Architecture Decisions

Baseline: **v1 APPROVED**. These are architecture decisions, not a final freeze of API fields, ports, or database engine.

| ID | Decision | Reason | Alternatives considered | Status |
|---|---|---|---|---|
| AD-01 | One shared repository and composed application | Avoid copying incompatible projects together | Separate projects | Approved |
| AD-02 | F01 Accounts and Wallet; F02 Money Movement | Keep account provisioning distinct; keep send and fulfillment under one transactional owner | Frontend/backend split; separate transfer/request feature owners | Approved |
| AD-03 | Complete vertical ownership inside permanent feature folders | Each owner can prove their UI, API, and logic together | Move code to global frontend/backend folders at merge | Approved |
| AD-04 | F02 depends only on F01's published identity/account lookup contract | Permit parallel work with a conforming fake | Import F01 internals or reverse dependency | Approved |
| AD-05 | Lead controls user/wallet schema; F01 provisions once; F02 owns later money changes and movement records | Explicit write authority and atomic fulfillment | Independent wallet schemas; cross-feature fulfillment writes | Approved |
| AD-06 | Integrator composes features through registrations, bindings, and tests | Keep integration small and avoid rewriting features | Merge feature source into one implementation | Approved |
| AD-07 | `main` is demo-safe; `integration` is verified combined work; feature branches feed progressive integration | Limit late integration and protect a working demo | Develop directly on main; merge everything at the end | Approved |
| AD-08 | Provisional candidate contracts until the walking skeleton validates the real UI/backend seam; final freeze is separate | Expose wiring mistakes before parallel coding | Declare final fields frozen at architecture approval | Approved |
| AD-09 | No AI/ML composition; extended due-date and bill-split semantics remain explicitly unconfirmed | The recovered core has no model requirement; participant report lacks detailed rules | Invent model or treat extensions as confirmed official rules | Approved |

Source note: the recovered PDF is a study reconstruction; the organizer-issued original takes precedence if obtained. No requirements are discarded solely because of the historical six-hour build window.
