# Web Application Test Environment

This directory contains the reproducible Docker environment for Workstream B of Project KAVACH. It provisions deterministically pinned versions of Damn Vulnerable Web Application (DVWA) and OWASP Juice Shop.

## Prerequisites
* Docker Desktop (or Docker Engine) installed and running.
* At least 4 GB of RAM allocated to Docker.
* Ports `8080` and `3000` available on the host machine.

## Bring-Up Procedure

1. Navigate to the environment directory:
```bash
   cd webapp/env
````
2. Initialize the containers in detached mode:
```bash
docker compose up -d
````
## Verification & Initial Setup

OWASP Juice Shop:
Navigate to http://localhost:3000. The application homepage and scoreboard should load immediately without further configuration.

DVWA:
Navigate to http://localhost:8080.

You will be redirected to the setup page. If not, manually navigate to http://localhost:8080/setup.php.

Scroll to the bottom of the page and click the "Create / Reset Database" button to initialize the seeded backend structure.

Log in using the default administrator credentials (admin / password).

## Teardown
To stop the environment and securely destroy the associated containers and networks, execute:
```bash
docker compose down -v
````
