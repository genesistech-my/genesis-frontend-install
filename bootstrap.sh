#!/usr/bin/env bash
# Genesis Console — bootstrap installer (public wrapper; contains no product code).
# Fetches the private app repo and runs its installer.
#
# Run on a Proxmox VE host:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
#
# Optional env: GENESIS_TOKEN (GitHub token), GENESIS_REF (tag/branch, default latest release).
set -euo pipefail

REPO="genesistech-my/genesis-frontend"
REF="${GENESIS_REF:-v0.12.2}"
WORK="$(mktemp -d /tmp/genesis-console.XXXXXX)"
cleanup(){ rm -rf "$WORK"; }
trap cleanup EXIT

command -v pct >/dev/null 2>&1 || { echo "ERROR: run this on a Proxmox VE host (pct not found)"; exit 1; }
if ! command -v git >/dev/null 2>&1; then
  echo ">> Installing git…"; apt-get update -q >/dev/null 2>&1 && apt-get install -y -q git >/dev/null 2>&1
fi

echo "=== Genesis Console bootstrap (ref: $REF) ==="
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

echo ">> Launching installer…"
cd "$WORK/app"
bash ./install.sh
