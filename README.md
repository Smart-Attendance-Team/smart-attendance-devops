# Smart Attendance - DevOps

Docker and infrastructure setup for Smart Attendance.

## Current status

- PostgreSQL 16 is running locally and its health check passes.
- GitHub Actions validation is configured but not yet tested on GitHub.
- Backend, frontend, and AI integration is pending.
- Monitoring and backups currently have placeholder folders only.
- Database tables and seed data await the agreed backend schema.

## Requirements

- Git
- Docker Desktop with Docker Compose

## Local setup

Run these commands from the repository root in PowerShell.

Only if .env does not already exist:
    Copy-Item .env.example .env

Start the database:
    docker compose --env-file .env -f docker/docker-compose.yml up -d

Check container health:
    docker compose --env-file .env -f docker/docker-compose.yml ps

Stop services without deleting the database volume:
    docker compose --env-file .env -f docker/docker-compose.yml down

## Database connection

From your computer:
- Host: localhost
- Port: 5433 by default, configurable through POSTGRES_PORT
- Database: attendance
- User: attendance_user
- Password: the value in your local .env file

From a backend container on the same Compose network:
- Host: db
- Port: 5432

## Security

Never commit .env or real credentials.
The example password is for local development only.