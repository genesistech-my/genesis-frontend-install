# Genesis Console — Installer

One-command installer for the **Genesis Console** appliance. Run it on a **Proxmox VE host**:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/genesistech-my/genesis-frontend-install/main/bootstrap.sh)"
```

You'll be prompted for a GitHub token with read access to the (private) app repo, then a
short wizard creates the appliance LXC, installs it, and prints the URL + first-run admin login.

Pin a version with `GENESIS_REF` (e.g. `GENESIS_REF=v0.3.0`).

This repository is a thin public wrapper and contains **no product code** — the application
lives in the private `genesistech-my/genesis-frontend` repository.

© 2026 Genesis Tech Solution (M) Sdn Bhd.
