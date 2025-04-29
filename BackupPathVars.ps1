# Define backup file paths
$userPathBackupFile = "C:\Code\UserPathBackup.txt"
$systemPathBackupFile = "C:\Code\SystemPathBackup.txt"

# Create the backup directory if it doesn't exist
$backupDirectory = "C:\Code"
if (-not (Test-Path -Path $backupDirectory)) {
    New-Item -ItemType Directory -Path $backupDirectory
}

# Backup User PATH variable
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
$userPath | Out-File -FilePath $userPathBackupFile -Encoding UTF8

# Backup System PATH variable
$systemPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
$systemPath | Out-File -FilePath $systemPathBackupFile -Encoding UTF8

# Output completion message
Write-Host "Backup completed."
Write-Host "User PATH variable backed up to: $userPathBackupFile"
Write-Host "System PATH variable backed up to: $systemPathBackupFile"
