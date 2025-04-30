function Install-WingetSoftware() {
    param (
        [Parameter(Mandatory = $true)]
        [array]$softwareList
    )
    Write-Host "Attempting to Install Software..." -ForegroundColor Cyan
    # Loop through the software list and install if not already installed
    foreach ($software in $softwareList) {
        if (-not (winget list | Select-String $software.Id)) {
            Write-Host "$($software.Name) is not installed. Installing $($software.Name)..." -ForegroundColor Yellow
            Invoke-Expression "winget install --id $($software.Id) --source winget --disable-interactivity --verbose"
        } else {
            Write-Host "$($software.Name) is already installed, skipping..." -ForegroundColor Green
        }
    }
}

function Install-PowerShellLatest {
    [Version]$latestVersionInfo = winget show Microsoft.Powershell | Select-String -Pattern 'Version\s*:\s*(.+)' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }
    [Version]$installedPowerShell = (winget list --id Microsoft.Powershell | Select-String -Pattern '(\d+\.\d+\.\d+\.\d+)').Matches.Groups[1].Value

    Write-Host "Checking if Latest PowerShell Version ($($latestVersionInfo)) is Installed..." -ForegroundColor Cyan

    # Check if PowerShell 7 is already installed
    if ($installedPowerShell -eq $latestVersionInfo) {
        Write-Host "Powershell is Up-to-Date." -ForegroundColor Green
        return
    }
    else {
        try {
            Invoke-Expression 'winget install --id Microsoft.Powershell --source winget --disable-interactivity --verbose'
            Write-Host "Powershell Updated." -ForegroundColor Yellow
        } catch {
            Write-Host "Failed to install PowerShell using winget." -ForegroundColor Red
        }
    }
}

function Install-PIPSoftware() {
    param (
        [Parameter(Mandatory = $True)]
        [array]$pipPackages
    )
    
    Write-Host "Installing PIP packages..." -ForegroundColor Cyan
    $pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
    
    if ($pythonPath) {
        foreach ($packageInfo in $pipPackages) {
            $friendlyName = $packageInfo.Name
            $package = $packageInfo.Module
            
            # Check if the package is installed
            $packageInstalled = python -m pip show $package 2>&1
            
            if ($packageInstalled -like "*No module named*" -or $packageInstalled -like "*not found:*") {
                Write-Host "$friendlyName ($package) is not installed. Installing..." -ForegroundColor Yellow
                
                # Upgrade pip first
                Invoke-Expression "python -m pip install --upgrade pip"
                
                # Attempt to install the package
                $installResult = Invoke-Expression "python -m pip install $package 2>&1"
                
                # Check if the installation was successful
                if ($installResult -like "*Successfully installed*") {
                    Write-Host "$friendlyName ($package) installed successfully." -ForegroundColor Green
                } else {
                    Write-Host "Failed to install $friendlyName ($package). Error: $installResult" -ForegroundColor Red
                }
            } else {
                Write-Host "$friendlyName ($package) is already installed, skipping..." -ForegroundColor Green
            }
        }
    } else {
        Write-Host "Python is not installed. Can't install pip packages!" -ForegroundColor Red
        exit(1)
    }
}

function Install-pip() {
    # Check and install pip
    $pipInstalled = Invoke-Expression "python -m pip --version" 2>&1
    if (-not $pipInstalled) {
        Write-Host "pip is not installed. Installing pip..." -ForegroundColor Yellow
        Invoke-Expression "python -m ensurepip --upgrade"
    } else {
        Write-Host "pip is already installed, skipping..." -ForegroundColor Green
    }
}

function Install-ChromeDriver(){
    Write-Host "Installing ChromeDriver..." -ForegroundColor Cyan
    # Check and install ChromeDriver
    $chromeDriverDir = "$($env:systemDrive)\ChromeDriver"

    if (-not (Test-Path $chromeDriverDir)) {
        Write-Host "ChromeDriver directory does not exist. Creating directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $chromeDriverDir -Force
    }

    $chromeDriverExe = Join-Path $chromeDriverDir "chromedriver.exe"
    if (-not (Test-Path $chromeDriverExe)) {
        Write-Host "ChromeDriver is not installed. Installing ChromeDriver..." -ForegroundColor Yellow
        $chromeDriverUrl = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE"
        $chromeDriverVersion = Invoke-RestMethod -Uri $chromeDriverUrl
        $chromeDriverZip = "chromedriver_win32.zip"
        $chromeDriverDownloadUrl = "https://chromedriver.storage.googleapis.com/$($chromeDriverVersion)/$($chromeDriverZip)"
        Invoke-WebRequest -Uri $chromeDriverDownloadUrl -OutFile $chromeDriverZip
        Expand-Archive -Path $chromeDriverZip -DestinationPath $chromeDriverDir -Force
        Remove-Item -Path $chromeDriverZip
    } else {
        Write-Host "ChromeDriver is already installed, skipping..." -ForegroundColor Green
    }

    # Add ChromeDriver to PATH for Machine scope if not already added
    if (-not ([Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) -split ";").Contains($chromeDriverDir)) {
        Write-Host "Adding ChromeDriver to Machine PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$chromeDriverDir", [EnvironmentVariableTarget]::Machine)
    } else {
        Write-Host "ChromeDriver is already in Machine PATH, skipping..." -ForegroundColor Green
    }

    # Add ChromeDriver to PATH for User scope if not already added
    if (-not ([Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) -split ";").Contains($chromeDriverDir)) {
        Write-Host "Adding ChromeDriver to User PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$chromeDriverDir", [EnvironmentVariableTarget]::User)
    } else {
        Write-Host "ChromeDriver is already in User PATH, skipping..." -ForegroundColor Green
    }
}

function Install-AHK(){
    Write-Host "Installing AHK..." -ForegroundColor Cyan
    # Check and install AutoHotkey
    $ahkExpectedPath = "$($env:systemDrive)\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe"
    if (-not (Test-Path $ahkExpectedPath)) {
        Write-Host "AutoHotkey is not installed or the expected version is not found. Installing AutoHotkey v1.1.37.02..." -ForegroundColor Yellow
        $ahkInstallerUrl = "https://github.com/Lexikos/AutoHotkey_L/releases/download/v1.1.37.02/AutoHotkey_1.1.37.02_setup.exe"
        $ahkInstallerPath = "$env:TEMP\AutoHotkey_1.1.37.02_setup.exe"
        Invoke-WebRequest -Uri $ahkInstallerUrl -OutFile $ahkInstallerPath
        Start-Process -FilePath $ahkInstallerPath -ArgumentList "/S" -Wait
        Remove-Item -Path $ahkInstallerPath -Force
    } else {
        Write-Host "AutoHotkey v1.1.37.02 is already installed, skipping..." -ForegroundColor Green
    }
}

function Install-Debian(){
    Write-Host "Installing Debian..." -ForegroundColor Cyan
    # Check if Debian is installed
    $debian = Invoke-Expression "wsl --list" | ForEach-Object {
        [PSCustomObject]@{
            Distribution = $_
        }
    }

    foreach ($item in $debian) {
        if ($item.Distribution -eq "Debian") {
            $debian = $True
        }
    }

    if (-not $debian) {
        Write-Host "Debian is not installed. Installing Debian..." -ForegroundColor Yellow
        Invoke-Expression "wsl --install -d Debian"
    } else {
        Write-Host "Debian is already installed, skipping..." -ForegroundColor Green
    }
}

function Install-WSL(){
    Write-Host "Installing WSL..." -ForegroundColor Cyan
    # Check and install WSL and Debian
    if (-not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
        Write-Host "WSL is not installed. Installing WSL..." -ForegroundColor Yellow
        Invoke-Expression "wsl --install"
        Start-Sleep -Seconds 10
    }
}

function Install-Scrcpy(){
    Write-Host "Installing scrcpy..." -ForegroundColor Cyan
    # Download and install scrcpy
    $scrcpyUrl = "https://github.com/Genymobile/scrcpy/releases/download/v3.2/scrcpy-win64-v3.2.zip"
    $scrcpyZip = "scrcpy.zip"
    $scrcpyDir = "$($env:systemDrive)\AHK\scrcpy"

    if (-not (Test-Path $scrcpyDir)) {
        Write-Host "scrcpy directory does not exist. Creating directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $scrcpyDir -Force
    }

    if (-not (Test-Path (Join-Path $scrcpyDir "scrcpy.exe"))) {
        Write-Host "Downloading scrcpy..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $scrcpyUrl -OutFile $scrcpyZip
        Expand-Archive -Path $scrcpyZip -DestinationPath $scrcpyDir -Force

        # Find the extracted folder dynamically
        $extractedFolder = Get-ChildItem -Path $scrcpyDir -Directory | Select-Object -First 1
        if ($extractedFolder) {
            Get-ChildItem -Path $extractedFolder.FullName -Recurse | Move-Item -Destination $scrcpyDir -Force
            Remove-Item -Path $extractedFolder.FullName -Recurse -Force
        }

        Remove-Item -Path $scrcpyZip -Force
        Write-Host "scrcpy installed successfully." -ForegroundColor Green
    } else {
        Write-Host "scrcpy is already installed, skipping..." -ForegroundColor Green
    }

    # Remove any existing scrcpy paths from Machine PATH
    $machinePath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $updatedMachinePath = ($machinePath -split ";" | Where-Object { $_ -notmatch "(?i)\b$([regex]::Escape($scrcpyDir))\b" }) -join ";"

    # Add scrcpy to PATH for Machine scope if not already added
    if (-not ($machinePath -split ";").Contains($scrcpyDir)) {
        Write-Host "Adding scrcpy to Machine PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("Path", "$updatedMachinePath;$scrcpyDir", [EnvironmentVariableTarget]::Machine)
    } else {
        Write-Host "scrcpy is already in Machine PATH, skipping..." -ForegroundColor Green
    }

    # Remove any existing scrcpy paths from User PATH
    $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    $updatedUserPath = ($userPath -split ";" | Where-Object { $_ -notmatch "(?i)\b$([regex]::Escape($scrcpyDir))\b" }) -join ";"

    # Add scrcpy to PATH for User scope if not already added
    if (-not ($userPath -split ";").Contains($scrcpyDir)) {
        Write-Host "Adding scrcpy to User PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("Path", "$updatedUserPath;$scrcpyDir", [EnvironmentVariableTarget]::User)
    } else {
        Write-Host "scrcpy is already in User PATH, skipping..." -ForegroundColor Green
    }
}

function Update-Software(){
    function Test-Equivalency(){
        param (
            [Parameter(Mandatory = $True)]
            [string]$firstString,

            [Parameter(Mandatory = $True)]
            [string]$secondString
        )

        # Split the strings into arrays of words
        $words1 = $firstString -split '\s+'
        $words2 = $secondString -split '\s+'

        # Get the unique words from both strings
        $uniqueWords1 = $words1 | Select-Object -Unique
        $uniqueWords2 = $words2 | Select-Object -Unique

        # Count the number of matching words
        $matchingWordsCount = ($uniqueWords1 | Where-Object { $uniqueWords2 -contains $_ }).Count

        # Calculate the percentage of matching words
        $percentage = ($matchingWordsCount / $uniqueWords1.Count) * 100

        # Return true if more than 50% of the words in string1 are in string2
        return $percentage -gt 50
    }

    Write-Host "Attempting to Update all Software Packages..." -ForegroundColor Cyan

    $wingetPackages = Get-WinGetPackage | Where-Object { $_.Source -eq "winget" }

    foreach($wingetPackage in $wingetPackages){
        if($wingetPackage.Id -ne "Microsoft.Office"){
            try {
                Write-Host "Checking Package $($wingetPackage.Id)" -ForegroundColor Cyan
                $output = Invoke-Expression "winget update $($wingetPackage.Id) --verbose"
                if(-not ($output -like "*No available upgrade found*")){
                    if($output -like '*Application is currently running*' -or $output -like '*Installer failed*'){
                        Write-Host "Application is currently running, attempting to kill $($wingetPackage.Name)" -ForegroundColor Yellow
                        $processes = Get-Process -Name $wingetPackage.Name -ErrorAction SilentlyContinue
                        if ($processes) {
                            Write-Host "Attempting to Kill '$($wingetPackage.Name)'..." -ForegroundColor Yellow
                            Start-Sleep -Seconds 2  
                            $processes | Stop-Process -Force -ErrorAction SilentlyContinue
                            $output = Invoke-Expression "winget update $($wingetPackage.Id) --verbose"
                            if($output -notlike "*Successfully installed*" -or $output -notlike "*Success*"){
                                Write-Host "Unhandled Error Occured $($output)" -ForegroundColor Red
                            }
                            else {
                                Write-Host "$($wingetPackage.Name) Updated Succcessfully." -ForegroundColor Green
                            }
                        } else {
                            $processes = Get-Process | Select-Object Product, Id
                            if($processes){
                                $processStopped = $False
                                foreach($process in $processes){
                                    if($($process.Product).Length -gt 0){
                                        if($process.Product -eq $wingetPackage.Name -or $(Test-Equivalency -firstString $wingetPackage.Name -secondString $process.Product)){
                                            $process | Stop-Process -Force -ErrorAction SilentlyContinue
                                            $processStopped = $True
                                        }
                                    }
                                }
                                if($processStopped){
                                    $output = Invoke-Expression "winget update $($wingetPackage.Id) --verbose"
                                    if($output -notlike "*Successful*"){
                                        Write-Host "Unhandled Error Occured $($output)" -ForegroundColor Red
                                    }
                                    else {
                                        Write-Host "$($wingetPackage.Name) Updated Succcessfully." -ForegroundColor Green
                                    }
                                    
                                }
                            } else {
                                Write-Host $output -ForegroundColor Red
                                Write-Host "No running processes found for $($wingetPackage.Name)" -ForegroundColor Red
                            }
                        }
                    }
                    elseif($output -like "*Successfully installed*" -or $output -like "*Success*"){
                        Write-Host "Successfully Updated $($wingetPackage.Name)" -ForegroundColor Green
                    }
                    elseif($output -like "*The installer cannot be run from an administrator context*"){
                        Write-Host "The installer for $($wingetPackage.Name) cannot be run from an administrator context. Please update this under a non-admin context." -ForegroundColor Red
                    }
                    elseif($output -like "*The package cannot be upgraded using winget*"){
                        Write-Host "$($wingetPackage.Name) doesn't support being updated via Winget, boo!" -ForegroundColor Red
                    }
                    elseif($output -like "*This package's version number cannot be determined*"){
                        Write-Host "$($wingetPackage.Name) version number cannot be determined" -ForegroundColor Red
                    }
                    else {
                        Write-Host "Encountered unhandled error while updating $($wingetPackage.Name): `n ErrorText: `n $output" -ForegroundColor Red
                    }
                }
            }
            catch {
                Write-Host "Error Updating $($wingetPackage.Name) $($_.Exception)" -ForegroundColor Red
            }
        }
    }
}


