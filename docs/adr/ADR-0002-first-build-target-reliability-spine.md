# ADR-0002 (product) — First build target: the reliability spine (evidence gate + Brakes)

- **Status:** Accepted (2026-06-18)
- **Deciders:** operator + Claude
- **Relates to:** ADR-0001 (product); the Constitution Art. 2/5.

## Context
paperclip today ≈ vanilla Paperclip + the Hermes overlay. The spike proved agents *can*
complete tasks, but also that they **claim `done` prematurely** and that data-driven gates
can't see cold paths — i.e. **agent execution is not yet trustworthy**. ADR-0001 mandates an
evidence gate and Brakes, but **those don't exist yet** in the codebase. We can't safely
dogfood (let agents build paperclip) until the thing that makes agent output trustworthy is
in place.

## Decision
The **first feature we build is the reliability spine** (VISION Tier A):

1. **Deterministic Conductor — the evidence gate:** a slice cannot transition to `done`
   without (a) attached evidence and (b) green Brakes (build/types/lint/tests). Implements
   Constitution Art. 2.
2. **Brakes:** run the project's checks and gate transitions on their result; reject **with a
   reason** (Art. 7).

**Bootstrapping sequence:** the early slices the agents help build *are the features that
make agent-built slices trustworthy*. Until the gate lands, **every agent PR is
human-verified** (Art. 5). Once it lands, later slices gate themselves — trust grows as it's
built.

This sequences the backlog: ADR-0002's scope = **Phase 4's first issues** (created on the
dogfooding board).

## Consequences
- Highest-risk-first (per design-first discipline): we build the trust mechanism before
  leaning on agent autonomy.
- The first-class **ADR entity**, the **independent Critic** as a gate, the **PO chat**, and
  **pi-in-container** (VISION Tier A/B) come **after** the spine — chartered just-in-time when
  we reach them, not pre-designed here.

## Alternatives considered
- **Build a flashy feature first (e.g. the ADR entity or PO chat)** — rejected: without the
  evidence gate we couldn't trust the agents building it; we'd be hand-verifying everything
  anyway, so build the gate first and compound.
