# Genesis Console — Installer

One-command bootstrap for the **Genesis Console** appliance. Run it on a **Proxmox VE host**.

## Install a new console

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
```

You'll be prompted for a GitHub token with read access to the (private) app repo, then a
short wizard creates the appliance LXC (Debian 13), installs it, and prints the URL + first-run
admin login. If the Debian 13 template isn't on the host, it's downloaded automatically.

## Update an already-deployed console

Updates the app code in place and **preserves users, 2FA, connector config, and the audit log**:

```bash
GENESIS_ACTION=update GENESIS_CTID=<CTID> \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
```

Omit `GENESIS_CTID` to be shown the Genesis Console containers detected on the host and pick one.

## Options

| Env var | Purpose | Default |
|---|---|---|
| `GENESIS_ACTION` | `install` or `update` | `install` |
| `GENESIS_CTID` | container to update (update mode) | prompted |
| `GENESIS_TOKEN` | GitHub read token (skips the prompt) | prompted |
| `GENESIS_REF` | version tag/branch to deploy | latest release |

Example — pin a version and pre-supply the token, non-interactively:

```bash
GENESIS_ACTION=update GENESIS_CTID=119 GENESIS_REF=v0.12.3 GENESIS_TOKEN=github_pat_xxx \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
```

This repository is a thin public wrapper and contains **no product code** — the application
lives in the private `genesistech-my/genesis-frontend` repository.

© 2026 Genesis Tech Solution (M) Sdn Bhd.
