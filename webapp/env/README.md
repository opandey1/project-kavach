# Web Application Test Environment

This directory contains the reproducible Docker environment for **Workstream B** of Project KAVACH. It provisions deterministically pinned versions of Damn Vulnerable Web Application (DVWA) and OWASP Juice Shop.

> **Security notice.** DVWA and OWASP Juice Shop are *intentionally vulnerable applications* used for security training and assessment. They must not be exposed beyond `localhost` — no corporate Wi-Fi, no ngrok tunnels, no port-forwarded routers. The Compose file binds both services to localhost only; do not edit those bindings.

## Reproducibility Target

This environment must be reachable in **under 15 minutes from a clean clone**, assuming a working internet connection. The first `docker compose up -d` pulls roughly 1.5 GB of images; subsequent starts take a few seconds.

## Prerequisites

| Component | Minimum version | Verify with |
|---|---|---|
| Docker Engine (or Docker Desktop) | ≥ 20.10.13 | `docker --version` |
| Docker Compose plugin | v2.x | `docker compose version` |
| Free host ports | `8080` and `3000` | `lsof -i :8080 -i :3000` (should return nothing) |
| Docker memory allocation | ≥ 4 GB | Docker Desktop → Settings → Resources |

## Bring-Up

From the repository root:

```bash
cd webapp/env
docker compose up -d
```

Confirm both containers are running and healthy:

```bash
docker compose ps
```

Expected: two services (`kavach-dvwa`, `kavach-juiceshop`) with `STATUS` ending in `(healthy)` after roughly 30–60 seconds. If status remains `(starting)` for several minutes, see Troubleshooting below.

## Verify Image Digests

To confirm the running containers match the pinned digests in `docker-compose.yml`:

```bash
docker compose images
```

The `DIGEST` column should match the `@sha256:...` value in the Compose file for each service. This is what makes the environment truly reproducible six months from now.

## Verification & Initial Setup

### OWASP Juice Shop

Navigate to **http://localhost:3000**. The homepage and scoreboard load immediately, no further configuration required.

### DVWA

1. Navigate to **http://localhost:8080**.
2. On first run, you will land on the setup page automatically. On subsequent runs you will see the login page; to re-initialise the database at any time, manually visit `http://localhost:8080/setup.php`.
3. On the setup page, scroll to the bottom and click **Create / Reset Database**.
4. After initialisation, log in with the default DVWA credentials: `admin` / `password`.
5. Set the security level to **Low** initially (DVWA → DVWA Security → Low → Submit). Escalate to Medium and High through Iteration 3 as exploitation work progresses; the filter-bypass reasoning gets more interesting at higher levels.

## Teardown

To stop the environment and remove containers, networks, and anonymous volumes:

```bash
docker compose down -v
```

The `-v` flag clears anonymous volumes. The pinned image digests ensure the next `docker compose up -d` brings back a bit-identical environment.

## Image Provenance

| Service | Image | Maintained? |
|---|---|---|
| DVWA | `vulnerables/web-dvwa` | Frozen since 2019. Pinned by digest for reproducibility. Alternative: `digininja/dvwa` (official). |
| Juice Shop | `bkimminich/juice-shop` | Actively maintained by the OWASP Juice Shop project. |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `docker compose ps` shows `(unhealthy)` after a few minutes | Healthcheck tool unavailable in the image | Edit the relevant `healthcheck.test` in `docker-compose.yml` to use an available tool, or set `disable: true` on the healthcheck. The container itself will still function. |
| Port `8080` or `3000` already in use | Another process is bound to the host port | Stop the conflicting process, or remap (e.g., `"8081:80"`) and update the verification URLs accordingly. |
| First-run pull > 15 min | Slow connection | Pre-pull while you work on other artefacts: `docker compose pull` |
| DVWA returns to `setup.php` on every login attempt | Database not initialised | On the setup page, click **Create / Reset Database**, then retry. |
| `docker compose` not recognised | Docker installed but Compose plugin missing | Install the Compose plugin per Docker's docs, or use the legacy `docker-compose` binary if you have it. |
