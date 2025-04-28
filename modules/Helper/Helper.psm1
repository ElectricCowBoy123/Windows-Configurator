function Install-Python(){
    # Check and install the highest version of Python using winget
    # Search for Python installations
    $pythonSearchResults = winget search --id "Python.Python" | Where-Object { $_ -match "Python.Python" }

    # Extract the version numbers
    $middleValues = $pythonSearchResults | ForEach-Object {
        ($_ -split '\s+')[1]
    }

    # Initialize an empty array to store valid version objects
    $validVersions = @()

    # Iterate through each value in $middleValues
    foreach ($value in $middleValues) {
        # Check if the value matches a valid version format
        if ($value -match '^\d+(\.\d+){0,3}$') {
            # Try to parse the value as a System.Version object
            try {
                $versionObject = [System.Version]::Parse($value)
                # Add the parsed version object to the valid versions array
                $validVersions += $versionObject
            } catch {
                # Handle any parsing errors (optional, can log or ignore)
            }
        }
    }

    # Sort the valid versions in descending order
    $latestVersion = $validVersions | Sort-Object -Descending | Select-Object -First 1

    # Get the installed Python version
    $installedPythonVersion = [System.Version]::Parse((Get-Command python -ErrorAction SilentlyContinue | ForEach-Object { & $_ --version 2>&1 }).Split()[1])

    # Install the topmost Python version using winget if not already installed
    if ($middleValues) {
        if ($latestVersion.Major -gt $installedPythonVersion.Major -or ($latestVersion.Major -eq $installedPythonVersion.Major -and $latestVersion.Minor -gt $installedPythonVersion.Minor)) {
            Write-Host "Installed Python version is: $($installedPythonVersion.ToString()) But Latest Python version is: $($latestVersion.ToString())" -ForegroundColor Red
            Write-Host "Upgrading to the most recent Python version: $($latestVersion.ToString())..." -ForegroundColor Yellow
            Invoke-Expression "winget install --id Python.Python.$($latestVersion.ToString()) --source winget"
        } else {
            Write-Host "The latest Python version ($($latestVersion.ToString())) is already installed, skipping..." -ForegroundColor Green
        }
    } else {
        Write-Host "No Python versions found in the search results." -ForegroundColor Red
    }

    # Add only the highest Python version to the PATH environment variable for both Machine and User scopes
    $pythonBasePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Programs\Python"
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

    # Get all Python directories under Programs\Python
    $pythonDirs = Get-ChildItem -Path $pythonBasePath -Directory | Where-Object { $_.Name -match "^Python\d+$" }

    if ($pythonDirs) {
        # Extract version numbers and find the highest version
        $highestVersionDir = $pythonDirs | Sort-Object { [int]($_.Name -replace "Python", "") } -Descending | Select-Object -First 1
        $highestVersionPath = $highestVersionDir.FullName
        
        # Check if the highest version is already in Machine PATH
        if (-not ($machinePath -split ";" | Where-Object { $_ -eq $highestVersionPath })) {
            # Remove any existing Python paths from Machine PATH
            $updatedMachinePath = ($machinePath -split ";" | Where-Object { $_ -notmatch "(?i)\\Programs\\Python\\Python\d+$" }) -join ";"

            # Add the highest version to Machine PATH
            [System.Environment]::SetEnvironmentVariable("Path", "$updatedMachinePath;$highestVersionPath", [System.EnvironmentVariableTarget]::Machine)
            Write-Host "Added $highestVersionPath to the Machine PATH environment variable and removed others." -ForegroundColor Yellow
        } else {
            Write-Host "$highestVersionPath is already in the Machine PATH, skipping..." -ForegroundColor Green
        }

        # Check if the highest version is already in User PATH
        if (-not ($userPath -split ";" | Where-Object { $_ -eq $highestVersionPath })) {
            # Remove any existing Python paths from User PATH
            $updatedUserPath = ($userPath -split ";" | Where-Object { $_ -notmatch "(?i)\\Programs\\Python\\Python\d+$" }) -join ";"

            # Add the highest version to User PATH
            [System.Environment]::SetEnvironmentVariable("Path", "$updatedUserPath;$highestVersionPath", [System.EnvironmentVariableTarget]::User)
            Write-Host "Added $highestVersionPath to the User PATH environment variable and removed others." -ForegroundColor Yellow
        } else {
            Write-Host "$highestVersionPath is already in the User PATH, skipping..." -ForegroundColor Green
        }
    } else {
        Write-Host "No Python directories found under $pythonBasePath." -ForegroundColor Red
    }

    # Check if Python is installed and update the App Execution Alias
    $pythonAliasPath = "$($env:LOCALAPPDATA)\Microsoft\WindowsApps\python.exe"
    if (Test-Path $pythonAliasPath) {
        Remove-Item $pythonAliasPath -Force
        Write-Host "Removed Python App Execution Alias to prevent opening Microsoft Store."
    } else {
        Write-Host "No Annoying Python App Execution Alias Exists, Skipping..." -ForegroundColor Green
    }

    # Verify Python installation
    try {
        $pythonVersion = & python --version
        Write-Host "Python $($pythonVersion) is installed and available, skipping... " -ForegroundColor Green
    } catch {
        Write-Host "Python is not properly installed or not available in the PATH." -ForegroundColor Red
    }

    # Check if Python3 is installed and update the App Execution Alias
    $python3AliasPath = "$($env:LOCALAPPDATA)\Microsoft\WindowsApps\python3.exe"
    if (Test-Path $python3AliasPath) {
        Remove-Item $python3AliasPath -Force
        Write-Host "Removed Python3 App Execution Alias to prevent opening Microsoft Store." -ForegroundColor Yellow
    } else {
        Write-Host "No annoying Python3 App Execution Alias, skipping..." -ForegroundColor Green
    }
}

function Test-URLs(){
    param(
        [Parameter(Mandatory = $True)]
        [array]$urlsToCheck
    )
    Write-Host "Testing URLs..." -ForegroundColor Cyan
    # Check if URLs are responding
    foreach ($url in $urlsToCheck) {
        try {
            $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10 -ErrorAction Stop
            if ($response.StatusCode -ne 200) {
                throw "URL $($url) is not responding with status code 200."
            }
        } catch {
            Write-Host "Error: Unable to reach $($url). Please check your internet connection or the URL." -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "URLs OK." -ForegroundColor Green
}

function Test-Python3(){
    # Verify Python3 installation
    Write-Host "Verifying if Python3 Command is Available..." -ForegroundColor Cyan
    try {
        $python3Version = & python3 --version
        Write-Host "Python3 $($python3Version) is installed and available, skipping... " -ForegroundColor Green
    } catch {
        Write-Host "Python3 is not properly installed or not available in the PATH." -ForegroundColor Red
    }   
}

function Set-ExecutionPolicies(){
    Write-Host "Setting Execution Policy..." -ForegroundColor Cyan
    # Check and set the execution policy to Bypass for the LocalMachine scope if not already set
    $currentPolicy = Get-ExecutionPolicy -Scope LocalMachine
    if ($currentPolicy -ne "Bypass") {
        try {
            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
            Write-Host "Execution policy successfully set to Bypass for LocalMachine scope." -ForegroundColor Green
        } catch {
            Write-Host "Failed to set execution policy for LocalMachine scope. Current effective policy may be overridden by a Group Policy or a more specific scope." -ForegroundColor Red
            Write-Host "Use 'Get-ExecutionPolicy -List' to view all execution policies." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Execution policy is already set to Bypass for LocalMachine scope, skipping..." -ForegroundColor Green
    }

    # Check and set the execution policy to Bypass for the CurrentUser scope if not already set
    $currentUserPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentUserPolicy -ne "Bypass") {
        try {
            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
            Write-Host "Execution policy successfully set to Bypass for CurrentUser scope." -ForegroundColor Green
        } catch {
            Write-Host "Failed to set execution policy for CurrentUser scope. Current effective policy may be overridden by a Group Policy or a more specific scope." -ForegroundColor Red
            Write-Host "Use 'Get-ExecutionPolicy -List' to view all execution policies." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Execution policy is already set to Bypass for CurrentUser scope, skipping..." -ForegroundColor Green
    }

    # Set the execution policy to Bypass for all scripts run on this machine
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" -Name "ExecutionPolicy" -Value "Bypass"
        Write-Host "Execution policy set to Bypass for all scripts on this machine." -ForegroundColor Green
    } catch {
        Write-Host "Failed to set execution policy for all scripts. Ensure you have the necessary permissions." -ForegroundColor Red
    }
}

function Test-Windows11(){
    Write-Host "Verifying if System OS is Windows 11..." -ForegroundColor Cyan
    # Ensure the script is running on Windows 11
    $osName = (Get-ComputerInfo).OsName
    if ($osName -notlike "*Windows 11*") {
        Write-Host "This script is designed to run on Windows 11. Detected OS: $osName" -ForegroundColor Red
        exit 1
    }
    Write-Host "System OS is Windows 11." -ForegroundColor Green
}

function Test-Admin(){
    Write-Host "Verifying if the script is running with Administrator privileges..." -ForegroundColor Cyan
    # Ensure the script is run as Administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Please run this script as Administrator." -ForegroundColor Red
        exit
    }
    Write-Host "Script is running with Administrator privileges." -ForegroundColor Green
}

function Test-Winget() {
    Write-Host "Verifying if winget is installed..." -ForegroundColor Cyan
    $wingetInstalled = Get-Command 'winget' -ErrorAction SilentlyContinue
    if ($null -eq $wingetInstalled) {
        Write-Host "winget not found. Installing winget..." -ForegroundColor Yellow
        $installerUrl = "https://aka.ms/getwinget"
        $installerPath = "$env:TEMP\Microsoft.DesktopAppInstaller_*.msixbundle"
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
        Start-Process "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

        $wingetInstalled = Get-Command 'winget' -ErrorAction SilentlyContinue
        if ($null -ne $wingetInstalled) {
            Write-Host "winget Installed Successfully" -ForegroundColor Green
        } else {
            Write-Host "Failed to install winget!" -ForegroundColor Red
        }
    }
    else {
        Write-Host "winget is already installed." -ForegroundColor Green
    }
}