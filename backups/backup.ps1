$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot ".env"
$composeFile = Join-Path $repoRoot "docker\docker-compose.yml"
$backupDir = Join-Path $PSScriptRoot "dumps"

if (-not (Test-Path $envFile)) {
    throw "Missing .env file."
}

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$uniqueId = [guid]::NewGuid().ToString("N").Substring(0, 8)
$fileName = "attendance-$timestamp-$uniqueId.dump"
$containerFile = "/tmp/$fileName"
$localFile = Join-Path $backupDir $fileName
$partialFile = "$localFile.partial"

$composeArgs = @(
    "compose",
    "--env-file", $envFile,
    "-f", $composeFile
)

try {
    Write-Host "Creating database backup..."

    docker @composeArgs exec -T db sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f "$1"' sh $containerFile
    if ($LASTEXITCODE -ne 0) {
        throw "Database backup failed."
    }

    docker @composeArgs cp "db:$containerFile" $partialFile
    if ($LASTEXITCODE -ne 0) {
        throw "Copying the backup to your computer failed."
    }

    if ((Get-Item $partialFile).Length -eq 0) {
        throw "The backup file is empty."
    }

    Move-Item -LiteralPath $partialFile -Destination $localFile

    Write-Host "Backup saved successfully:"
    Write-Host $localFile
}
finally {
    docker @composeArgs exec -T db rm -f $containerFile
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not remove the temporary backup inside the container."
    }
}