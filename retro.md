## Iteration 1 — friction log

### Docker DNS in VirtualBox NAT
First `docker compose up -d` failed with "failed to resolve reference" —
wording suggested a registry/image problem, but bottom of the stack trace
revealed a DNS timeout on systemd-resolved. VirtualBox NAT's DNS proxy was
unresponsive. Fixed by setting upstream DNS to 8.8.8.8/1.1.1.1 in
/etc/systemd/resolved.conf and restarting systemd-resolved. Lesson: read
Docker errors bottom-up.

### DVWA healthcheck chicken-and-egg
Configured wget --spider against /login.php for the DVWA healthcheck;
container stayed (unhealthy) indefinitely while the app served fine in
browser. Root cause: DVWA requires manual DB init via setup.php on first
run, so any HTTP-based healthcheck fails until a human has clicked "Create
Database". Resolution: dropped the healthcheck with a documenting comment
in docker-compose.yml. Kept the Juice Shop healthcheck, which is
self-contained and worked first time.
