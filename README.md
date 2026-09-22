# Smart Attendance - DevOps

DevOps infrastructure and deployment foundation for the Smart Attendance platform.

## Overview

This repository contains the DevOps setup for the Smart Attendance system, including Docker infrastructure, CI validation, monitoring checks, and database backup procedures.

## Current Status

- PostgreSQL 16 container is configured and running locally.
- Docker Compose configuration is available for database infrastructure.
- GitHub Actions CI pipeline is configured and validated through pull requests.
- Database health checks are implemented.
- Database backup scripts and configuration management are implemented.
- Backend, frontend, and AI service integration will be added when application services are connected.

## Repository Structure

```text
smart-attendance-devops

.github/
└── workflows/
    └── ci.yml

docker/
└── docker-compose.yml

monitoring/
├── health-check.ps1
└── README.md

backups/
├── backup.ps1
├── backup-config.env.example
└── README.md

docs/