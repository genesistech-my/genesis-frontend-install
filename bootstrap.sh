#!/usr/bin/env bash
# Genesis Console — bootstrap (public wrapper; contains no product code).
# Fetches the private app repo and INSTALLS a new appliance or UPDATES an existing one.
#
# Install a new console (default):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
#
# Update an already-deployed console (preserves users, 2FA, config, audit):
#   GENESIS_ACTION=update GENESIS_CTID=<CTID> \
#     bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
#
# Optional env:
#   GENESIS_TOKEN  GitHub token with read access to the private app repo
#   GENESIS_REF    tag/branch to deploy (default: latest release below)
#   GENESIS_ACTION install | update   (default: install)
#   GENESIS_CTID   container to update (update mode; prompted if omitted)
set -euo pipefail

REPO="genesistech-my/genesis-frontend"
REF="${GENESIS_REF:-v0.21.0}"
ACTION="${GENESIS_ACTION:-install}"
WORK="$(mktemp -d /tmp/genesis-console.XXXXXX)"
cleanup(){ rm -rf "$WORK"; }
trap cleanup EXIT

command -v pct >/dev/null 2>&1 || { echo "ERROR: run this on a Proxmox VE host (pct not found)"; exit 1; }
if ! command -v git >/dev/null 2>&1; then
  echo ">> Installing git…"; apt-get update -q >/dev/null 2>&1 && apt-get install -y -q git >/dev/null 2>&1
fi

case "$ACTION" in install|update) ;; *) echo "ERROR: GENESIS_ACTION must be 'install' or 'update'"; exit 1;; esac
echo "=== Genesis Console bootstrap ($ACTION, ref: $REF) ==="

# ---- update mode: resolve which container to update ----
if [ "$ACTION" = update ]; then
  CTID="${GENESIS_CTID:-}"
  if [ -z "$CTID" ]; then
    echo "Detected Genesis Console containers on this host:"
    found=0
    for id in $(pct list 2>/dev/null | awk 'NR>1{print $1}'); do
      if pct exec "$id" -- test -f /opt/genesis-frontend/gf.env >/dev/null 2>&1; then
        echo "  - CT $id"; found=1
      fi
    done
    [ "$found" = 1 ] || echo "  (none detected — the container may be stopped; enter its ID manually)"
    read -rp "Container ID to update: " CTID
  fi
  [ -n "$CTID" ] || { echo "ERROR: a container ID is required for update"; exit 1; }
  pct status "$CTID" >/dev/null 2>&1 || { echo "ERROR: container $CTID not found on this host"; exit 1; }
fi

# ---- fetch the pinned version from the private repo ----
TOKEN="${GENESIS_TOKEN:-${GH_TOKEN:-}}"
if [ -z "$TOKEN" ]; then
  echo "The app repo is private. Paste a GitHub token with read access to $REPO."
  read -rsp "GitHub token: " TOKEN; echo
fi
[ -n "$TOKEN" ] || { echo "ERROR: a token is required"; exit 1; }

echo ">> Fetching app ($REF)…"
git clone --depth 1 --branch "$REF" \
  "https://x-access-token:${TOKEN}@github.com/${REPO}.git" "$WORK/app" >/dev/null 2>&1 \
  || { echo "ERROR: fetch failed — check the token's access and that ref '$REF' exists"; exit 1; }

cd "$WORK/app"
if [ "$ACTION" = update ]; then
  echo ">> Updating CT $CTID to $REF (users, 2FA, config and audit are preserved)…"
  bash ./update.sh "$CTID"
else
  echo ">> Launching installer…"
  bash ./install.sh
fi
