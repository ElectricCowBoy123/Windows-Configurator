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
      if (Get-Module -Name $module.Name) {
          Remove-Module -Name $module.Name -Force
      }

      try {
          # Check if the module file exists before attempting to import
          if (Test-Path "$($module.Id)") {
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

# Overhead
Import-Modules -modules $modules
Test-Windows11
Test-Admin
Set-ExecutionPolicies
Test-URLs($urlsToCheck)
Test-Winget

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
Initialize-PowerShell
Initialize-OhMyPosh

# Configure Notepad++
Initialize-NotepadPlusPlus -ThemeFilePath $themeFilePath -ConfigFilePath $ConfigFilePath

# Configure Windows
Initialize-Explorer -registrySettings $registrySettings
Initialize-DesktopBackground -wallpaperPath $wallpaperPath
#Initialize-Waterfox -sourcePath $waterFoxConfigPath

# download VS code add custom theme

# download and configure waterfox add custom theme
# tweak the OS to not be annoying

# improve this to not have so much embedded in one script possibly make desktop backgrouind a file
# install everything blah maybe make it so it just installs software from an array using winget
# potentially add a ui