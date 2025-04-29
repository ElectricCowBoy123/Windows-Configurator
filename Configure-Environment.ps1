# Import Vars
try {
  . "$($PSScriptRoot)\_vars.ps1"
} catch {
  Write-Host "Failed to Import Variables from '_vars.ps1'. Error: $_" -ForegroundColor Red
}

# Need to change this function so modules aren't reimported if they are already loaded, this is a testing function
function Import-Modules {
    param(
        [Parameter(Mandatory = $True)]
        [array]$modules
    )

    Write-Host "Importing Modules..." -ForegroundColor Cyan

    foreach ($module in $modules) {
    $isPath = $True
    if($module.Id -notlike '*/*' -and $module.Id -notlike '*\*'){
        $isPath = $False
        if($null -eq $(Get-Module $module.Name)){
            Install-Module $module.Id -Force
        }
    }

    if (Get-Module -Name $module.Name) {
        Remove-Module -Name $module.Name -Force
    }

    try {
        # Check if the module file exists before attempting to import
        if ($(Test-Path "$($module.Id)") -or $null -eq $(Get-Module $module.Name)) {
            Import-Module "$($module.Id)" -Force
        } else {
            Write-Host "Module file not found: $($module.Id)" -ForegroundColor Red
            exit(1)
        }
    } catch {
        Write-Host "Failed to Import $($module.Name). Error: $_" -ForegroundColor Red
        exit(1)
    }

    if (-not (Get-Module -Name $module.Name)) {
        Write-Host "Failed to get module $($module.Name)" -ForegroundColor Red
        exit(1)
    }
    }

    Write-Host "Modules Imported Successfully." -ForegroundColor Green
}

# Clear Console
Clear-Host

# Reset Environment Vars (In-case any have been added)
#$pathVariable = [System.Environment]::GetEnvironmentVariable("PATH")
#[System.Environment]::SetEnvironmentVariable("PATH", $pathVariable, [System.EnvironmentVariableTarget]::Process)

if(Get-Command "neofetch" -ErrorAction SilentlyContinue) {
    & neofetch
    Write-Host ""
}

# Overhead
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser > $null # Dependency for Installing Microsoft.WinGet.Client
Import-Modules -modules $modules
Test-Windows11
Test-Admin
Set-ExecutionPolicies
Test-URLs($urlsToCheck)
Test-Winget
<#
# Install Software
Install-PowerShellLatest
Install-WingetSoftware -softwareList $wingetSoftware
Install-PIPSoftware -pipPackages $pipPackages
Install-ChromeDriver
Install-Scrcpy
Install-AHK
Install-WSL
Install-Debian

# Configure AHK
Install-ScheduledTasks -taskXml $taskXml -ahkDirectory $ahkDirectory

# Configure Windows Terminal
Initialize-Terminal
Initialize-PS7Terminal
Initialize-PowerShell
Initialize-OhMyPosh -ohMyPoshThemeURL $ohMyPoshThemeURL

# Configure Notepad++
Initialize-NotepadPlusPlus -ThemeFilePath $themeFilePath -ConfigFilePath $ConfigFilePath

# Configure Windows
Initialize-Explorer -registrySettings $registrySettings
Initialize-DesktopBackground -wallpaperPath $wallpaperPath
Initialize-Waterfox -sourcePath $waterFoxConfigPath
Initialize-WaterfoxPrefs -Preferences $waterFoxPrefrences
Invoke-DiskCleanup -runDism $False
#>
# Updates
Update-Software
Get-WindowsUpdates

# download VS code add custom theme

# potentially add a ui
# check if windows needs updating
# check if there are any driver updates
# parameterise someway to run selectively