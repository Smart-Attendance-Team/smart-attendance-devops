$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot ".env"
$composeFile = Join-Path $repoRoot "docker\docker-compose.yml"
$configFile = Join-Path $PSScriptRoot "backup-config.env.example"

if (-not (Test-Path $envFile)) {
    throw "Missing .env file."
}

if (-not (Test-Path $configFile)) {
    throw "Missing backup configuration file."
}

$config = @{}

Get-Content $configFile | ForEach-Object {
    if ($_ -match "^([^#=]+)=(.*)$") {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$backupDir = Join-Path $repoRoot $config["BACKUP_DIR"]
$retentionDays = [int]$config["RETENTION_DAYS"]
$databaseService = $config["DATABASE_SERVICE"]

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$uniqueId = [guid]::NewGuid().ToString("N").Substring(0,8)

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

    docker @composeArgs exec -T $databaseService sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f "$1"' sh $containerFile

    if ($LASTEXITCODE -ne 0) {
        throw "Database backup failed."
    }

    docker @composeArgs cp "${databaseService}:$containerFile" $partialFile

    if ($LASTEXITCODE -ne 0) {
        throw "Copy backup failed."
    }

    if ((Get-Item $partialFile).Length -eq 0) {
        throw "Backup file is empty."
    }

    Move-Item $partialFile $localFile

    Write-Host "Backup saved:"
    Write-Host $localFile


    Write-Host "Cleaning old backups..."

    Get-ChildItem $backupDir -Filter "*.dump" |
    Where-Object {
        $_.LastWriteTime -lt (Get-Date).AddDays(-$retentionDays)
    } |
    Remove-Item -Force

}
finally {

    docker @composeArgs exec -T $databaseService rm -f $containerFile

}