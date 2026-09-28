# PSTU Money Movement — Requirements Brief

Source: `reference/PSTU_Hackathon_Final_Question_Recovered.pdf`, a reconstruction from public sources, **not** the organizer-issued original. If the original is obtained, compare it and update this brief before treating any discrepancy as settled. This brief records the problem; it does not declare final API contracts or a technology stack.

## Recovered core

| ID | Requirement | Completion evidence |
|---|---|---|
| FR-01 | A user can create an application account and receive a demo starting balance once. The reconstructed PDF cites BDT 100,000 from a public finalist implementation. | A new account shows its persisted grant; duplicate/retried creation cannot grant again. |
| FR-02 | A user can view their current persisted balance. | Reload/read-back shows the authoritative value. |
| FR-03 | A user can send a valid simulated BDT amount to another valid user. | Sender debited, recipient credited, result persists. |
| FR-04 | A user can request money from another valid user. | Request is pending; no balances change on creation. |
| FR-05 | The designated payer can see pending requests addressed to them. | Another user cannot act as the payer. |
| FR-06 | The designated payer can fulfill a valid pending request. | Funds move from payer to requester once; request becomes completed. |
| FR-07 | Accounts, balances, requests, and completion state persist. | Refresh/read-back preserves all committed results. |

## Correctness rules

| ID | Rule |
|---|---|
| CR-01 | Backend is authoritative for money movement and request-state changes. |
| CR-02 | Reject invalid users, invalid amounts, insufficient funds, and invalid request states. |
| CR-03 | Debit and credit are atomic: both happen or neither happens. |
| CR-04 | Duplicate submissions and retries cannot move the same money twice. |
| CR-05 | Concurrent sends and fulfillments cannot accept double spending or a negative balance. |
| CR-06 | Pending requests do not change balances; completed requests cannot be fulfilled again. |
| CR-07 | Rejected operations cannot partially change balances or request state. |
| CR-08 | Total simulated value is conserved after account grants; the one-time starting grant is the exception. |

An identity/session mechanism, persistent database, exact amount representation, transactional write path, retry identity, and validation are implementation necessities for these rules. Their exact contracts are decided through the walking skeleton and subsequent contract freeze; the recovered question does not prescribe a login method or database engine.

## Golden demonstration from the recovered PDF

Alice and Bob each start with BDT 100,000. Alice sends BDT 2,500 to Bob, leaving 97,500 and 102,500. Bob requests BDT 1,200 from Alice; balances do not change. Alice sees and fulfills the request once. Final balances are Alice **96,300** and Bob **103,700**, total **200,000**; the request is completed. Refresh preserves that state. Demonstrate at least one invalid, duplicate, retry, or concurrent attempt without corruption.

## Participant-described extended scope

The PDF separately reports peer-to-peer transfers, smart due-date requests, multi-party bill splitting, and a high-concurrency fintech scenario from a runner-up account. Direct transfers and concurrency correctness are already in the recovered core. Due dates and bill splitting remain tracked within F02's capability, but the PDF gives no precise expiry, split-allocation, rounding, or partial-payment rules. Do not silently invent those as official rules; record a chosen assumption or compare with the organizer's original before implementing them.

## Explicitly outside the recovered core

Real banks, cards, payment gateways, deposits, withdrawals, settlement, KYC integrations, and real-money custody. A receipt mentioned as part of another team's solution in the PDF's source list is not itself a stated requirement. No AI/ML requirement appears in the recovered core.

The historical event's six-hour build window is context, not a reason to remove a recovered requirement from this project's scope.
