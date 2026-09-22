$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot ".env"
$composeFile = Join-Path $repoRoot "docker\docker-compose.yml"

$composeArgs = @(
    "compose",
    "--env-file", $envFile,
    "-f", $composeFile
)

try {
    if (-not (Test-Path $envFile)) {
        throw "Missing local .env file."
    }

    Write-Host "Checking database container..."

    $containerId = docker @composeArgs ps -q db
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot query Docker. Check that Docker Desktop is running."
    }

    if (-not $containerId) {
        throw "Database container is not running."
    }

    $health = docker inspect --format '{{.State.Health.Status}}' $containerId
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot read container health."
    }

    if ($health -ne "healthy") {
        throw "Database container health is: $health"
    }

    Write-Host "Container health: healthy"
    Write-Host "Testing database query..."

    $result = docker @composeArgs exec -T -e PGCONNECT_TIMEOUT=5 -e "PGOPTIONS=-c statement_timeout=5000" db psql -U attendance_user -d attendance -v ON_ERROR_STOP=1 -Atc "SELECT 1;"

    if ($LASTEXITCODE -ne 0) {
        throw "Database query failed."
    }

    if (($result -join "").Trim() -ne "1") {
        throw "Database query returned an unexpected result."
    }

    Write-Host "PASS: PostgreSQL is healthy and responds to queries."
    exit 0
}
catch {
    Write-Host "FAIL: $($_.Exception.Message)"
    exit 1
}
