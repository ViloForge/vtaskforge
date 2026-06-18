# vtaskforge — Product Architecture Decision Records

These are **vtaskforge's *product* ADRs** — decisions about *this codebase* (how it's built,
its internal architecture). They are **distinct from the program ADRs** in the umbrella
(`ViloForge/viloforge-asdlc/docs/adr/`, which cover environments / fork strategy / org).

The behavioral law is the **Constitution** in `../AGENTS.md`.

**Format:** one decision per file, `ADR-NNNN-slug.md`, status `Proposed → Accepted →
Superseded`. Immutable once Accepted; to change one, write a superseding ADR and re-gate the
slices that cite it. Charter **just-in-time** — don't pre-write ADRs for unbuilt features.

| ADR | Title | Status |
|-----|-------|--------|
| 0001 | Adopt the recursive-refinement ASDLC (how we build vtaskforge) | Accepted |
| 0002 | First build target — the reliability spine (evidence gate + Brakes) | Accepted |
