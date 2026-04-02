# code-server-container

A small [code-server](https://github.com/coder/code-server) image based on [LinuxServer.io](https://linuxserver.io/)’s build, extended with Python, Node, build tooling, and the [Cursor Agent CLI](https://cursor.com/docs/cli/overview) for browser-based development.

## What’s added on top of the base image

| Category | Packages / tools |
|----------|------------------|
| **Python** | `python3`, `python3-pip`, `python3-venv`, `python3-dev` |
| **Node** | `nodejs`, `npm`, **nodemon** (global: `npm install -g nodemon`) |
| **Compilers / build** | `build-essential` (gcc, g++, make, and related tools for native npm/Python wheels) |
| **Cursor** | Cursor Agent CLI via the official installer (`curl` → `~/.local/bin`) |

The LinuxServer base already includes **git**, **sudo**, **nano**, and the code-server app itself.

## Important configuration

### Port

- Default **web UI**: **8443** (not 8080). Map it when you run the container, e.g. `-p 8443:8443`.

### Directories and user

| Item | Notes |
|------|--------|
| **`/config`** | Main persistent volume. Holds code-server data, extensions, SSH keys under `/config/.ssh`, etc. |
| **`/config/workspace`** | Default folder opened in the editor (LinuxServer `DEFAULT_WORKSPACE`; this image sets `WORKDIR` here). |
| **`HOME`** | **`/config`**. Cursor Agent installs into `/config/.local` (`agent` / `cursor-agent` on `PATH`). |
| **Process user** | **`abc`** (LinuxServer standard). Map host ownership with **`PUID`** / **`PGID`**. |

### Git over SSH (`setup-git-ssh`)

If you use **Git over SSH** with a **passphrase-protected** private key, run **`setup-git-ssh`** once after each container start (it is installed as `/usr/local/bin/setup-git-ssh`). The script starts or reuses `ssh-agent` with a stable socket under `~/.ssh`, writes `~/.ssh/agent.env`, and runs **`ssh-add`**. New **bash** terminals load that environment automatically until the container restarts (via `/etc/profile.d/99-git-ssh-agent.sh` and `bash.bashrc`). If integrated Git still fails, open a new terminal or reload the window once (the script prints the same hint).

**Arguments / key paths:** With **no arguments**, `ssh-add` uses SSH’s **default** private key locations and names (typically `~/.ssh/id_ed25519`, `~/.ssh/id_rsa`, and similar). If your key is **not** in one of those defaults—for example it lives elsewhere or uses a custom filename—pass the **private key file path(s)** explicitly (same as `ssh-add`; multiple paths are allowed):

```bash
setup-git-ssh /config/.ssh/my_custom_key
```

### Typical LinuxServer environment variables

Use the [upstream parameters](https://github.com/linuxserver/docker-code-server#parameters) as needed, for example:

- `PUID`, `PGID` — align with your host user for volume permissions  
- `TZ` — timezone  
- `PASSWORD` or `HASHED_PASSWORD` — web UI auth (optional; omit both for no password)  
- `SUDO_PASSWORD` — optional sudo in the integrated terminal  
- `DEFAULT_WORKSPACE` — override the default folder (defaults to `/config/workspace`)  
- `PROXY_DOMAIN` — if you use subdomain reverse-proxying  

### Building this image

There is **no** publish of a prebuilt image to a registry. **GitHub Actions** runs a `docker build` (no push) on each push/PR and a short **smoke test** (`agent`, `python3`, `node`, `nodemon`, `gcc` present; Python/Node `--version`). That does not start code-server in the browser — only checks the image layers. You still build where you run (locally or Portainer); Cursor’s installer runs in CI only to verify the Dockerfile.

**Locally:**

```bash
docker build -t code-server-container:local .
```

**Portainer:** create a stack or use **Images → Build a new image** with this repository as the build context (or clone the repo and point the build context at the folder containing the Dockerfile). Use the same [LinuxServer-style](https://github.com/linuxserver/docker-code-server#usage) `ports`, `environment`, and `volumes` for `/config` as in their docs.

## License

### This repository

The **Dockerfile**, **GitHub Actions workflow**, and **documentation** in this repository are released under the [**MIT No Attribution (MIT-0)**](LICENSE) license — a permissive license with no attribution requirement (similar intent to **0BSD** or the **Unlicense**, but with a conventional warranty disclaimer).

### Included software (built image)

The **container image** layers many third-party components. This repository’s MIT-0 license applies only to the files *in this repo*, not to those components. Approximate licensing for the main pieces:

| Component | License / terms |
|-----------|-----------------|
| **code-server** | [MIT](https://github.com/coder/code-server/blob/main/LICENSE) (Coder Technologies Inc.) |
| **nodemon** (npm) | [MIT](https://github.com/remy/nodemon/blob/master/LICENSE) |
| **Node.js** | [MIT](https://github.com/nodejs/node/blob/main/LICENSE) (and bundled deps with various licenses) |
| **npm** | [Artistic-2.0](https://github.com/npm/cli/blob/latest/LICENSE) (see npm’s own notices for bundled code) |
| **Python** | [PSF License](https://docs.python.org/3/license.html) |
| **GCC / binutils / make** (`build-essential`, etc.) | Mostly **GPL** and **LGPL** (GNU toolchain) |
| **Debian/Ubuntu packages** | Per-package (GPL, LGPL, Apache-2.0, MIT, BSD, etc.) — see `/usr/share/doc/*/copyright` in the image |
| **LinuxServer.io** packaging | Their [Dockerfile sources](https://github.com/linuxserver/docker-code-server) are under **GPL-3.0**; the base image also includes Ubuntu and s6-overlay under their respective terms |
| **Cursor Agent CLI** | **Proprietary** — installed at image build time from Cursor’s public installer; [Cursor / Anysphere terms](https://cursor.com/terms) apply when you **use** the product |

**What this repository provides:** the **Dockerfile** only automates the same **public** `curl … | bash` flow from [cursor.com/install](https://cursor.com/install). This project does **not** ship Cursor binaries as repo files, does **not** grant Cursor subscriptions, and does **not** help bypass their licensing. When you build an image yourself, the installer is fetched from Cursor’s servers; **actual use** of the CLI (accounts, models, etc.) is between you and Cursor.

This repo does **not** publish a prebuilt image to a registry. If you later publish a **prebuilt** image elsewhere that contains the installed CLI, that is a separate redistribution — handle that under Cursor’s terms. For a **FOSS-only** image, remove the Cursor `RUN` from the Dockerfile.
