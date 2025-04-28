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
    Set-ItemProperty -Path $regPath -Name WallpaperStyle -Value 6
    Set-ItemProperty -Path $regPath -Name TileWallpaper -Value 0

    # Refresh the desktop to apply the changes
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

function Remove-Bloatware(){
    Params(
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
            if (Test-Path $registryPath) {
                # Get the current value of the registry property
                $currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

                # Check if the current value is different from the desired value
                if ($currentValue.$propertyName -ne $propertyValue) {
                    # Set the registry property
                    Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -Type DWord -Force
                    Write-Host "Successfully set '$propertyName' to '$propertyValue' for '$friendlyName'." -ForegroundColor Yellow
                } else {
                    Write-Host "'$friendlyName' is already set to '$($propertyValue -eq 0 ? 'False' : $propertyValue -eq 1 ? 'True' : $propertyValue)' Skipping..." -ForegroundColor Green
                }
            } else {
                Write-Host "Registry path '$registryPath' does not exist. Skipping..." -ForegroundColor Red
            }
        } catch {
            Write-Host "Failed to set '$propertyName' for '$friendlyName'. Error: $_" -ForegroundColor Red
        }
    }
}