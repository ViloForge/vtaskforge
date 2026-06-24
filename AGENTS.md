# AGENTS.md — paperclip

> **paperclip** is a **control plane for AI-agent companies** — a
> **fork of [Paperclip](https://github.com/paperclipai/paperclip)**, with
> **Hermes agents** as the workers, running an Agentic SDLC (charter → recursive `REFINE` →
> build, at autonomy **L3**).
>
> - **Origin:** `ViloForge/paperclip` (public **native fork** of `paperclipai/paperclip`).
>   **Upstream sync:** `upstream = paperclipai/paperclip`; pull deliberately ("Sync fork" /
>   `git fetch upstream && git merge upstream/master`). Keep the Paperclip `LICENSE` (MIT).
> - **Product ADRs** in `docs/adr/`: ADR-0001 (adopt the ASDLC), ADR-0002 (first build target
>   = the reliability spine), ADR-0003 (package the Hermes worker into the image). More added
>   just-in-time as we build.
> - **Replaces** the old Django/DRF app (now `ViloForge/vtaskforge-legacy`, archived).
> - **Principles (non-negotiable):** charter-before-build · gate-on-evidence-not-self-report ·
>   structural-rules-need-a-Brake.
>
> *The **Constitution** (below) is the behavioral law for this repo. Under it is the inherited
> Paperclip contributor guide — still accurate for the codebase we forked.*

---

# Constitution (paperclip)

The behavioral law for **every agent and human** doing work in paperclip. The **Conductor**
and **Critic** cite these articles; violating one **blocks the transition to `done`**.
Grounded in the recursive-refinement ASDLC and the `vfwms-forge` prior art.

### Article 1 — The three non-negotiables
1. **Charter before build.** Decide the *how* (stack, architecture, interfaces) **before**
   building, recursively and just-in-time, riskiest-unknown first. An agent never picks the
   stack per-slice; it builds against an Accepted charter decision (ADR).
2. **Gate on evidence, never self-report.** "Done" is a claim until evidence proves it.
3. **Structural rules need a deterministic Brake.** A behavioral judge (Critic) cannot see a
   structural violation (a dropped dependency, dedup, SOLID); enforce those with a
   whole-codebase Brake (lint/build/test), not prose.

### Article 2 — Definition of Done (evidence-gated)
A slice is `done` **only** when: (a) its acceptance criteria are met; (b) **evidence is
attached** (passing tests / audit output / the artifact itself); and (c) the relevant
**Brakes are green** (build, types, lint, tests). A "done" with no attached evidence does
**not** satisfy DoD — the Conductor rejects it. *(Spike lesson: agents claim done
prematurely; the hardened prompt-template that PATCHes then GET-verifies status is mandatory
for worker agents.)*

### Article 3 — Definition of Ready
Do **not** start a slice until: scope is bounded, acceptance criteria **and the one
disconfirming test** are written, and every charter decision it depends on is **Accepted**.
Unready → push back; never guess the missing piece.

### Article 4 — Autonomy ceiling = L3
Agents act autonomously **within a slice** up to **L3** (conditional autonomy). Humans hold
the **gates**: charter ratification, high-risk/irreversible actions, merges to protected
branches, anything touching prod. **Never L4** (no silent autonomous shipping). When blocked
or uncertain, **stop and surface** — do not fabricate a result.

### Article 5 — Verify, don't trust
Never relay a tool's or agent's "passed/verified/done" as fact. **A result not in observed
output does not exist.** Before any load-bearing claim, run its **disconfirming test** and
read the ground truth.

### Article 6 — Roles
- **Generator** — the worker agent (e.g. Hermes/DeepSeek) that produces the slice.
- **Critic** — an *independent* judge (different model family) that scores the slice against
  this Constitution + the charter. It is a *behavioral* layer, so it pairs with Brakes.
- **Conductor** — *deterministic*: gates every transition on evidence + green Brakes, and
  **routes rejects with a reason**.

### Article 7 — Reject carries a reason
Every rejection states **what failed** and **what evidence would satisfy it**. No silent rejects.

### Article 8 — Secrets & blast radius
Secrets are **never** baked into images or commits (runtime injection only) and are masked in
logs. Destructive/outward ops are **gated**. Isolate an agent (sandbox) when its blast radius
warrants it.

### Amendment
This Constitution is itself charter. Amend an article only via a **product ADR** that
supersedes it, then **re-gate** the slices that cite it.

---

# AGENTS.md (Paperclip — inherited)

Guidance for human and AI contributors working in this repository.

## 1. Purpose

Paperclip is a control plane for AI-agent companies.
The current implementation target is V1 and is defined in `doc/SPEC-implementation.md`.

## 2. Read This First

Before making changes, read in this order:

1. `doc/GOAL.md`
2. `doc/PRODUCT.md`
3. `doc/SPEC-implementation.md`
4. `doc/DEVELOPING.md`
5. `doc/DATABASE.md`

`doc/SPEC.md` is long-horizon product context.
`doc/SPEC-implementation.md` is the concrete V1 build contract.

## 3. Repo Map

- `server/`: Express REST API and orchestration services
- `ui/`: React + Vite board UI
- `packages/db/`: Drizzle schema, migrations, DB clients
- `packages/shared/`: shared types, constants, validators, API path constants
- `packages/adapters/`: agent adapter implementations (Claude, Codex, Cursor, etc.)
- `packages/adapter-utils/`: shared adapter utilities
- `packages/plugins/`: plugin system packages
- `doc/`: operational and product docs

## 4. Dev Setup (Auto DB)

Use embedded PGlite in dev by leaving `DATABASE_URL` unset.

```sh
pnpm install
pnpm dev
```

This starts:

- API: `http://localhost:3100`
- UI: `http://localhost:3100` (served by API server in dev middleware mode)

Quick checks:

```sh
curl http://localhost:3100/api/health
curl http://localhost:3100/api/companies
```

Reset local dev DB:

```sh
rm -rf data/pglite
pnpm dev
```

## 5. Core Engineering Rules

1. Keep changes company-scoped.
Every domain entity should be scoped to a company and company boundaries must be enforced in routes/services.

2. Keep contracts synchronized.
If you change schema/API behavior, update all impacted layers:
- `packages/db` schema and exports
- `packages/shared` types/constants/validators
- `server` routes/services
- `ui` API clients and pages

3. Preserve control-plane invariants.
- Single-assignee task model
- Atomic issue checkout semantics
- Approval gates for governed actions
- Budget hard-stop auto-pause behavior
- Activity logging for mutating actions

4. Do not replace strategic docs wholesale unless asked.
Prefer additive updates. Keep `doc/SPEC.md` and `doc/SPEC-implementation.md` aligned.

5. Keep repo plan docs dated and centralized.
When you are creating a plan file in the repository itself, new plan documents belong in `doc/plans/` and should use `YYYY-MM-DD-slug.md` filenames. This does not replace Paperclip issue planning: if a Paperclip issue asks for a plan, update the issue `plan` document per the `paperclip` skill instead of creating a repo markdown file.

6. Attach inspectable generated artifacts.
When your task produces a user-inspectable deliverable file, follow the Paperclip skill's "Generated Artifacts and Work Products" workflow before final disposition. In this repo, prefer the self-contained skill helper at `skills/paperclip/scripts/paperclip-upload-artifact.sh` so the file is available through the Paperclip API, create/update an artifact work product when the file is the deliverable, link the uploaded artifact in the final issue comment, and then set status. Do not rely on local filesystem paths as the only access path. If an important file intentionally remains workspace-only, create/update a work product with `metadata.resourceRef.kind: "workspace_file"` and a workspace-relative path, then name that work product and path in the final comment. Treat browse/search as a fallback for recovering workspace files, not the preferred deliverable path. See `doc/AGENT-ARTIFACTS.md` for details and `.mp4`/`.webm` examples.

## 6. Database Change Workflow

When changing data model:

1. Edit `packages/db/src/schema/*.ts`
2. Ensure new tables are exported from `packages/db/src/schema/index.ts`
3. Generate migration:

```sh
pnpm db:generate
```

4. Validate compile:

```sh
pnpm -r typecheck
```

Notes:
- `packages/db/drizzle.config.ts` reads compiled schema from `dist/schema/*.js`
- `pnpm db:generate` compiles `packages/db` first

## 7. Verification Before Hand-off

Default local/agent test path:

```sh
pnpm test
```

This is the cheap default and only runs the Vitest suite. Browser suites stay opt-in:

```sh
pnpm test:e2e
pnpm test:release-smoke
```

Run the browser suites only when your change touches them or when you are explicitly verifying CI/release flows.

For normal issue work, run the smallest relevant verification first. Do not default to repo-wide typecheck/build/test on every heartbeat when a narrower check is enough to prove the change.

Run this full check before claiming repo work done in a PR-ready hand-off, or when the change scope is broad enough that targeted checks are not sufficient:

```sh
pnpm -r typecheck
pnpm test:run
pnpm build
```

If anything cannot be run, explicitly report what was not run and why.

## 8. API and Auth Expectations

- Base path: `/api`
- Board access is treated as full-control operator context
- Agent access uses bearer API keys (`agent_api_keys`), hashed at rest
- Agent keys must not access other companies

When adding endpoints:

- apply company access checks
- enforce actor permissions (board vs agent)
- write activity log entries for mutations
- return consistent HTTP errors (`400/401/403/404/409/422/500`)

## 9. UI Expectations

- Keep routes and nav aligned with available API surface
- Use company selection context for company-scoped pages
- Surface failures clearly; do not silently ignore API errors

## 10. Pull Request Requirements

When creating a pull request (via `gh pr create` or any other method), you **must** read and fill in every section of [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md). Do not craft ad-hoc PR bodies — use the template as the structure for your PR description. Required sections:

- **Thinking Path** — trace reasoning from project context to this change (see `CONTRIBUTING.md` for examples)
- **What Changed** — bullet list of concrete changes
- **Verification** — how a reviewer can confirm it works
- **Risks** — what could go wrong
- **Model Used** — the AI model that produced or assisted with the change (provider, exact model ID, context window, capabilities). Write "None — human-authored" if no AI was used.
- **Checklist** — all items checked

## 11. Definition of Done

A change is done when all are true:

1. Behavior matches `doc/SPEC-implementation.md`
2. Typecheck, tests, and build pass
3. Contracts are synced across db/shared/server/ui
4. Docs updated when behavior or commands change
5. PR description follows the [PR template](.github/PULL_REQUEST_TEMPLATE.md) with all sections filled in (including Model Used)

## 11. Fork-Specific: HenkDz/paperclip

This is a fork of `paperclipai/paperclip` with QoL patches and an **external-only** Hermes adapter story on branch `feat/externalize-hermes-adapter` ([tree](https://github.com/HenkDz/paperclip/tree/feat/externalize-hermes-adapter)).

### Branch Strategy

- `feat/externalize-hermes-adapter` → core has **no** `hermes-paperclip-adapter` dependency and **no** built-in `hermes_local` registration. Install Hermes via the Adapter Plugin manager (`@henkey/hermes-paperclip-adapter` or a `file:` path).
- Older fork branches may still document built-in Hermes; treat this file as authoritative for the externalize branch.

### Hermes (plugin only)

- Register through **Board → Adapter manager** (same as Droid). Type remains `hermes_local` once the package is loaded.
- UI uses generic **config-schema** + **ui-parser.js** from the package — no Hermes imports in `server/` or `ui/` source.
- Optional: `file:` entry in `~/.paperclip/adapter-plugins.json` for local dev of the adapter repo.

### Local Dev

- Fork runs on port 3101+ (auto-detects if 3100 is taken by upstream instance)
- `npx vite build` hangs on NTFS — use `node node_modules/vite/bin/vite.js build` instead
- Server startup from NTFS takes 30-60s — don't assume failure immediately
- Kill ALL paperclip processes before starting: `pkill -f "paperclip"; pkill -f "tsx.*index.ts"`
- Vite cache survives `rm -rf dist` — delete both: `rm -rf ui/dist ui/node_modules/.vite`

### Fork QoL Patches (not in upstream)

These are local modifications in the fork's UI. If re-copying source, these must be re-applied:

1. **stderr_group** — amber accordion for MCP init noise in `RunTranscriptView.tsx`
2. **tool_group** — accordion for consecutive non-terminal tools (write, read, search, browser)
3. **Dashboard excerpt** — `LatestRunCard` strips markdown, shows first 3 lines/280 chars

### Plugin System

PR #2218 (`feat/external-adapter-phase1`) adds external adapter support. See root `AGENTS.md` for full details.

- Adapters can be loaded as external plugins via `~/.paperclip/adapter-plugins.json`
- The plugin-loader should have ZERO hardcoded adapter imports — pure dynamic loading
- `createServerAdapter()` must include ALL optional fields (especially `detectModel`)
- Built-in UI adapters can shadow external plugin parsers — remove built-in when fully externalizing
- Reference external adapters: Hermes (`@henkey/hermes-paperclip-adapter` or `file:`) and Droid (npm)
