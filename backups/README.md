\# Database Backup and Restore



Run all commands from the DevOps repository root.



\## Requirements



\- Docker Desktop is running.

\- The PostgreSQL service is running.

\- A local .env file exists.



\## Create a backup



```powershell

.\\backups\\backup.ps1

```



Backups are saved in backups/dumps/ with unique filenames.

This directory is ignored by Git. Never commit database dumps.



The script uses PostgreSQL custom-format backups.

Keep an additional protected copy outside this computer if the data matters.



\## Test a restore



Use a new, empty test database. Never restore a test backup over the original database.



The examples below use attendance\_user.

Replace it if POSTGRES\_USER differs in your local .env.



1\. Create the test database:



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml exec -T db createdb -U attendance\_user -T template0 attendance\_restore\_test

```



If this database already exists, choose a different test database name and use it in the restore command too.



2\. Set the path to the backup you want to test:



```powershell

$backupFile = Read-Host "Enter the full path to your .dump file, without quotes"

```



3\. Copy the backup into the container:



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml cp "$backupFile" db:/tmp/attendance-restore-test.dump

```



Continue only if the copy succeeds.



4\. Restore into the test database:



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml exec -T db pg\_restore -U attendance\_user -d attendance\_restore\_test --exit-on-error --single-transaction /tmp/attendance-restore-test.dump

```



Immediately check the exit code:



```powershell

$LASTEXITCODE

```



An exit code of 0 indicates that the restore command succeeded.



5\. Inspect the restored application tables:



```powershell

docker compose --env-file .\\.env -f .\\docker\\docker-compose.yml exec -T db psql -U attendance\_user -d attendance\_restore\_test -c "\\dt"

```



After application data is available, also verify expected row counts and representative records.



\## Validation status



\- Backup creation succeeded locally.

\- Restore into a separate test database returned exit code 0.

\- The tested database did not yet contain application tables.

\- A restore test with synthetic application data is still required.



\## Current limitations



\- Backups are manual, not scheduled.

\- Off-device storage and retention are not configured.

\- This script backs up one database, not PostgreSQL cluster roles.

