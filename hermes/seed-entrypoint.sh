#!/bin/sh
# Overlay entrypoint: seed the DeepSeek Hermes config into the hermes child's
# HOME (=/paperclip, a volume that shadows anything baked into the image there),
# then chain to Paperclip's original entrypoint. Runs as root at container start
# (the stock entrypoint drops to the node user via gosu afterwards).
set -e

HERMES_HOME="${PAPERCLIP_HOME:-/paperclip}"
CFG_DIR="$HERMES_HOME/.hermes"
if [ ! -f "$CFG_DIR/config.yaml" ]; then
  mkdir -p "$CFG_DIR"
  cp /opt/hermes-seed/config.yaml "$CFG_DIR/config.yaml"
  # Own it by the runtime user (node, uid/gid from USER_UID/USER_GID, default 1000).
  chown -R "${USER_UID:-1000}:${USER_GID:-1000}" "$CFG_DIR" 2>/dev/null || true
  echo "hermes-seed: wrote $CFG_DIR/config.yaml (DeepSeek)"
else
  echo "hermes-seed: $CFG_DIR/config.yaml already present, leaving as-is"
fi

exec docker-entrypoint.sh "$@"
