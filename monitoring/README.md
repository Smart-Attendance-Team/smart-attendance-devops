\# Local Database Health Checks



Run commands from the DevOps repository root.



\## Check database health



```powershell

.\\monitoring\\health-check.ps1

```



Immediately check the exit code:



```powershell

$LASTEXITCODE

```



\- 0: the container is healthy and the database query succeeded.

\- 1: a check failed; read the FAIL message.



The script currently uses database attendance and user attendance\_user.

If these settings change, update the psql arguments in health-check.ps1.



\## View container status



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml ps -a

```



\## View recent database logs



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml logs --no-color --tail 100 db

```



Review logs before sharing them. Remove credentials and sensitive data.



\## Troubleshooting



\- Docker unavailable: open Docker Desktop and wait for it to start.

\- Database stopped: start it with the command below.

\- Health is starting: wait briefly, then repeat the health check.

\- Health is unhealthy or the query fails: inspect the database logs first.



Start the database:



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml up -d db

```



Do not delete database volumes to fix an error without a verified backup.



\## Scope



This is a manual local check for PostgreSQL.

It does not monitor backend, frontend, or AI services.

Automatic alerts and centralized logging are not configured yet.

