# ADR-0003 (product) — Package the Hermes worker into the paperclip image

- **Status:** Accepted (2026-06-23)
- **Deciders:** operator + Claude
- **Relates to:** ADR-0001 (Hermes is the Generator).

## Context
The `hermes_local` adapter (`hermes-paperclip-adapter`) drives Hermes by **spawning the
`hermes` CLI as a child process** inside the paperclip server and parsing its stdout;
session resumption is a `--resume <sessionId>` token. The adapter is process-local and
filesystem-coupled — Hermes must be co-located with the server (`HOME=/paperclip/.hermes`)
and **cannot** be reached over a socket. Today the Dockerfile bakes Hermes via
`pip install hermes-agent==0.16.0` from PyPI, pinning to an *upstream* release. We are now
developing our own fork (`ViloForge/hermes-agent`) and publishing its image to GHCR, so a
PyPI version pin is the wrong source of truth.

## Decision
paperclip packages Hermes **into its own image at build time** via a **multi-stage graft**
from the published hermes-agent image:

1. The Dockerfile replaces the PyPI install with
   `COPY --from=ghcr.io/viloforge/hermes-agent:<pinned-digest>` of the self-contained Hermes
   venv (`/opt/hermes/.venv`), placing `hermes` on `PATH`.
2. Hermes is **pinned by image digest**, not a version string — reproducible and signable.
3. The `hermes_local` adapter and the `HOME=/paperclip/.hermes` seed entrypoint are
   **unchanged**; Hermes stays co-located in the same container.
4. paperclip's own image is built and released from GitHub to `ghcr.io/viloforge/paperclip`
   (CI: `.github/workflows/docker.yml`), pinned by digest in the deployment.

## Consequences
- One deployable image (paperclip + Hermes co-located); the deployment pulls a single
  `ghcr.io/viloforge/paperclip` image.
- Hermes and paperclip release on **independent cadences**; a Hermes bump is a one-line
  digest update + a paperclip image rebuild.
- No PyPI publish is needed to ship Hermes changes; the fork's GHCR image is the source of truth.
- Runtime coupling remains (Hermes is embedded); the image carries Hermes's python3.13 venv,
  so image size grows.

## Alternatives considered
- **Keep the PyPI pin (`hermes-agent==0.16.0`)** — rejected: ties our worker to an upstream
  release and requires a PyPI publish for every fork change; defeats developing our own fork.
- **Network service / sidecar (Option B)** — Hermes as its own pod, driven over its first-class
  `/v1/runs` API. Rejected *for now*: requires a net-new `hermes_remote` adapter + topology
  rework, dropping the proven `hermes_local` / `hermes-paperclip-adapter`. Hermes is built for
  this, so it remains the principled end-state to revisit if Hermes must scale or be shared
  independently.
