function Initialize-DesktopBackground() {
    param (
        [Parameter(Mandatory = $true)]
        [string]$wallpaperPath
    )
    Write-Host "Changing Desktop Wallpaper..." -ForegroundColor Cyan
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent

    $result = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperPath, $fWinIni) | Out-Null

    if ($result -eq 0) {
        Write-Host "Failed to set desktop background!" -ForegroundColor Red
    } else {
        Write-Host "Desktop Background Set!" -ForegroundColor Green
    }

    # Set wallpaper style to "Fit to screen"
    $regPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $regPath -Name WallpaperStyle -Value 4
    Set-ItemProperty -Path $regPath -Name TileWallpaper -Value 0

    # Refresh the desktop to apply the changes
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

function Remove-Bloatware(){
    Param(
        [Parameter(Mandatory = $True)]
        [array]$bloatwarePackages
    )
    Write-Host "Removing Bloatware..." -ForegroundColor Cyan
    # Flag to track if any bloatware is detected
    $bloatwareDetected = $False

    # Check for each package
    foreach ($package in $bloatwarePackages) {
        $appxPackage = Get-AppxPackage -Name $package -AllUsers -ErrorAction SilentlyContinue
        $provisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $package

        if ($appxPackage) {
            Write-Host "Bloatware detected and removing: $package (AppxPackage)" -ForegroundColor Yellow
            $bloatwareDetected = $true
            $appxPackage | Remove-AppxPackage -AllUsers -ErrorAction Stop > $null 2>&1
        }

        if ($provisionedPackage) {
            Write-Host "Bloatware detected and removing: $package (ProvisionedPackage)" -ForegroundColor Yellow
            $bloatwareDetected = $true
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $provisionedPackage.PackageName -ErrorAction Stop > $null 2>&1
            } catch {
                Write-Host "Failed to remove provisioned package: $package" -ForegroundColor Red
            }
        }
    }

    # Print message if no bloatware is detected
    if (-not $bloatwareDetected) {
        Write-Host "Bloatware Already Removed, Skipping..." -ForegroundColor Green
    }
}

function Initialize-Explorer() {
    param (
        [Parameter(Mandatory=$True)]
        [array]$registrySettings
    )

    Write-Host "Configuring Windows Explorer settings..." -ForegroundColor Cyan

    foreach ($setting in $registrySettings) {
        $friendlyName = $setting.Name
        $registryPath = $setting.Path
        $propertyName = $setting.Property
        $propertyValue = $setting.Value
        try {
            # Check if the registry key exists
            if (-not (Test-Path $registryPath)) {
                # Create the registry path if it doesn't exist
                New-Item -Path $registryPath -Force | Out-Null
                Write-Host "Created registry path '$registryPath'." -ForegroundColor Yellow
            }

            # Get the current value of the registry property
            $currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

            # Check if the current value is different from the desired value
            if ($currentValue.$propertyName -ne $propertyValue) {
                # Set the registry property
                try {
                    Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -Type DWord -Force
                }
                catch {
                    Write-Host "Failed to Set Registry Key $($registryPath) : $($PropertyName) Error: $($_.Exception)" -ForegroundColor Red
                }
                
                Write-Host "Successfully set '$propertyName' to '$propertyValue' for '$friendlyName'." -ForegroundColor Yellow
            } else {
                if ($propertyValue -eq 0) {
                    Write-Host "'$friendlyName' is already set to 'False'. Skipping..." -ForegroundColor Green
                } elseif ($propertyValue -eq 1) {
                    Write-Host "'$friendlyName' is already set to 'True'. Skipping..." -ForegroundColor Green
                } else {
                    Write-Host "'$friendlyName' is already set to '$($propertyValue)'. Skipping..." -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "Failed to set '$propertyName' for '$friendlyName'. Error: $_" -ForegroundColor Red
        }
    }
}

function Get-WindowsUpdates() {
    # Check if the PSWindowsUpdate module is available
    Write-Host "Checking for Windows Updates..." -ForegroundColor Cyan
    if (-not (Get-Module -Name PSWindowsUpdate -ListAvailable)) {
        Write-Host "PSWindowsUpdate module is not available. Installing it now..." -ForegroundColor Yellow
        try {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction Stop
            Write-Host "PSWindowsUpdate module installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install PSWindowsUpdate module: $_" -ForegroundColor Red
            return
        }
    }

    # Import the PSWindowsUpdate module with error handling
    try {
        Import-Module PSWindowsUpdate -ErrorAction Stop
    } catch {
        Write-Host "Failed to import PSWindowsUpdate module: $_" -ForegroundColor Red
        return
    }

    Write-Host "Checking for Windows updates..." -ForegroundColor Cyan

    try {
        # Get the list of available updates
        $updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop

        if ($updates) {
            Write-Host "The following updates are available:" -ForegroundColor Yellow
            $updates | Format-Table -Property Title, Size, KBArticleID
        } else {
            Write-Host "No updates are available." -ForegroundColor Green
        }
    } catch {
        Write-Host "An error occurred while checking for updates: $_" -ForegroundColor Red
    }
}

function Invoke-DiskCleanup() {
    Param(
        [Parameter(Mandatory = $True)]
        [bool]$runDism
    )
    Invoke-Expression "cleanmgr.exe /d $($env:systemDrive) /VERYLOWDISK"
    if($runDism){
        Invoke-Expression "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
    }
}