# ADR-0001 (product) — Adopt the recursive-refinement ASDLC

- **Status:** Accepted (2026-06-18)
- **Deciders:** operator + Claude
- **Relates to:** the Constitution (`../AGENTS.md`).

## Context
paperclip is built by **dogfooding itself** — we run a paperclip instance and use it to
plan and execute its own construction, following the program's Agentic SDLC. We need a
single, explicit statement of *how* work flows here so the Conductor/Critic and every agent
share one model.

## Decision
paperclip is developed via the **recursive-refinement ASDLC**:

1. **Charter → REFINE → build.** Each scope is chartered (the *how* decided as ADRs,
   riskiest-unknown first, just-in-time) before slices are built. The goal tree is the design
   spine; **Definition of Ready / Definition of Done are states** (Constitution Art. 2–3).
2. **Roles** (Constitution Art. 6): **Generator** (worker agent — Hermes/DeepSeek and other
   harnesses), **Critic** (independent, different model family), **Conductor**
   (deterministic gate).
3. **Evidence-gated** (Art. 2) — no `done` without attached evidence + green Brakes.
4. **Autonomy ceiling L3** (Art. 4) — humans at the gates; never L4.
5. The **Constitution (`AGENTS.md`)** is the law the Critic/Conductor cite.

## Consequences
- A consistent, enforceable loop the dogfooding runs on.
- Requires the **Conductor + Brakes** to actually exist to be more than convention → see
  ADR-0002 (build them first).
- Until then, agent-produced slices are **human-verified** (Art. 5).

## Alternatives considered
- **Ad-hoc / vibe building** — rejected: the spike showed agents claim `done` prematurely;
  without the evidence gate the output isn't trustworthy.
- **A bespoke process** — rejected: we already designed the recursive-refinement ASDLC; reuse it.
