# ADR 0001: Data Authority and Offline Model

Status: Accepted on 2026-08-17

The custom HTTPS API is the global domain authority. Drift/SQLite is the local
UI source of truth. Firebase provides identity and platform services but is not
a second generic domain store.

Local mutations and durable outbox entries commit atomically. Synchronization
uses persisted idempotency keys, entity versions, cursors, and tombstones.
Disjoint changes may merge; overlapping base/local/remote values remain durable
until domain logic or a user resolves them.

This avoids dual writes while allowing process-restart-safe offline behavior.
