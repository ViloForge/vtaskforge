#!/bin/sh
# Overlay entrypoint: seed the DeepSeek Hermes config into the hermes child's
# HOME (=/paperclip, a volume that shadows anything baked into the image there),
# then chain to Paperclip's original entrypoint. Runs as root at container start
# (the stock entrypoint drops to the node user via gosu afterwards).
set -e

HERMES_HOME="${PAPERCLIP_HOME:-/paperclip}"
CFG_DIR="$HERMES_HOME/.hermes"
RUN_UID="${USER_UID:-1000}"
RUN_GID="${USER_GID:-1000}"

# Ensure the hermes config + log dirs exist on EVERY boot (not just first
# create). /paperclip is a persistent volume that outlives the pod and can
# carry root-owned dirs from earlier boots; the server runs as the node user
# (gosu, uid 1000), so a root-owned .hermes/logs makes the hermes child fail
# with EACCES creating .hermes/logs/<run>. Idempotent + cheap.
mkdir -p "$CFG_DIR/logs"
if [ ! -f "$CFG_DIR/config.yaml" ]; then
  cp /opt/hermes-seed/config.yaml "$CFG_DIR/config.yaml"
  echo "hermes-seed: wrote $CFG_DIR/config.yaml (DeepSeek)"
else
  echo "hermes-seed: $CFG_DIR/config.yaml already present, leaving as-is"
fi
# Always re-assert ownership to the runtime user. This entrypoint runs as root
# before the stock entrypoint gosu's down to node, so the chown succeeds and
# any persisted root-owned files no longer block writes.
chown -R "${RUN_UID}:${RUN_GID}" "$CFG_DIR" 2>/dev/null || true

exec docker-entrypoint.sh "$@"
