function Initialize-OhMyPosh(){
    Param(
        [Parameter(Mandatory=$True)]
        [string]$ohMyPoshThemeURL
    )
    Write-Host "Configuring Oh My Posh..." -ForegroundColor Cyan
    # Add Oh My Posh to PATH if not already added
    $ohMyPoshPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    if (-not ([Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) -split ";").Contains($ohMyPoshPath)) {
        Write-Host "Adding Oh My Posh to PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$ohMyPoshPath", [EnvironmentVariableTarget]::User)
    } else {
        Write-Host "Oh My Posh is already in PATH, skipping..." -ForegroundColor Green
    }

    # Ensure $PROFILE exists and add Oh My Posh initialization
    if (-not (Test-Path $PROFILE)) {
        Write-Host "PowerShell profile does not exist. Creating profile..." -ForegroundColor Yellow
        New-Item -Path $PROFILE -Type File -Force
    }

    # Add Oh My Posh initialization to the profile if not already present
    [String]$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
    # TODO make this paramterized, also make it so if the config is already there and the theme url gets changed then add it again, also consider downloading first offline might not work
    if (-not ($profileContent -like "*oh-my-posh init pwsh --config*")) {
        Write-Host "Adding Oh My Posh initialization to PowerShell profile..." -ForegroundColor Yellow
        Add-Content -Path $PROFILE -Value "oh-my-posh init pwsh --config '$($ohMyPoshThemeURL)' | Invoke-Expression"
    } else {
        if(-not ($profileContent -like "*oh-my-posh init pwsh --config '$($ohMyPoshThemeURL)' | Invoke-Expression*")){
          $newProfileContent = $profileContent -replace "oh-my-posh init pwsh --config '.*?'", "oh-my-posh init pwsh --config '$($ohMyPoshThemeURL)'"
          Set-Content -Path $PROFILE -Value $newProfileContent
          Write-Host "Updated Oh My Posh theme URL in PowerShell profile." -ForegroundColor Yellow
        }
        else {
            Write-Host "Oh My Posh initialization is already present in the PowerShell profile, skipping..." -ForegroundColor Green
        }
    }
}

function Initialize-PSReadLine(){
    Write-Host "Configuring PSReadLine..." -ForegroundColor Cyan
    [String]$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
    if (-not ($profileContent -like "*Set-PSReadLineOption -PredictionSource History*") -and -not ($profileContent -like "*Set-PSReadLineOption -PredictionViewStyle ListView*") -and -not ($profileContent -like "*Set-PSReadLineOption -EditMode Windows*")) {
        Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -PredictionSource History"
        Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -PredictionViewStyle ListView"
        Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -EditMode Windows"
        Write-Host "Configured PSReadLine." -ForegroundColor Yellow
    }
    else {
        Write-Host "PSReadLine Configuration Already Added to Profile" -ForegroundColor Green
    }
}

function Initialize-NotepadPlusPlus(){
    param (
        [Parameter(Mandatory=$True)]
        [string]$ThemeFilePath,

        [Parameter(Mandatory=$True)]
        [string]$ConfigFilePath
    )
    Write-Host "Configuring Notepad++..." -ForegroundColor Cyan
    # Define the local Notepad++ configuration path
    $LocalConfigPath = Join-Path $env:APPDATA "Notepad++"
    $ThemePath = Join-Path $LocalConfigPath "themes"

    # Ensure the themes directory exists
    if (!(Test-Path $ThemePath)) {
        New-Item -Path $ThemePath -ItemType Directory -Force | Out-Null
    }

    # Define the full paths for the theme and config files
    $ThemeFullPath = Join-Path $ThemePath "VS2019-Dark.xml"
    $LocalConfigFullPath = Join-Path $LocalConfigPath "config.xml"

    # Check if the theme file already exists
    if (Test-Path $ThemeFullPath) {
        Write-Host "Notepad++ Theme already configured, skipping..." -ForegroundColor Green
    } else {
        # Read the content from the provided theme file path
        if (Test-Path $ThemeFilePath) {
            $ThemeContent = Get-Content -Path $ThemeFilePath -Raw
            Set-Content -Path $ThemeFullPath -Value $ThemeContent -Force
            Write-Host "Notepad++ Theme file successfully written to Notepad++ themes folder." -ForegroundColor Yellow
        } else {
            Write-Host "Theme file not found at path: $ThemeFilePath" -ForegroundColor Red
            return
        }
    }

    # Check if the config file already exists
    if (Test-Path $LocalConfigFullPath) {
        Write-Host "Notepad++ Configuration already configured, skipping..." -ForegroundColor Green
    } else {
        # Read the content from the provided config file path
        if (Test-Path $ConfigFilePath) {
            $ConfigContent = Get-Content -Path $ConfigFilePath -Raw
            Set-Content -Path $LocalConfigFullPath -Value $ConfigContent -Force
            Write-Host "Notepad++ Configuration file successfully written to Notepad++ config folder." -ForegroundColor Yellow
        } else {
            Write-Host "Config file not found at path: $ConfigFilePath" -ForegroundColor Red
            return
        }
    }
}

function Initialize-PowerShell(){
    Write-Host "Configuring Powershell..." -ForegroundColor Cyan
    # Stop Powershell from checking for updates
    if ([System.Environment]::GetEnvironmentVariable('POWERSHELL_UPDATECHECK', 'User') -ne '0') {
        Write-Host "Disabling PowerShell update checks..." -ForegroundColor Yellow
        $PSVersionTable.PSVersion.Major -eq 7 | Out-Null; if ($?) { [System.Environment]::SetEnvironmentVariable('POWERSHELL_UPDATECHECK', '0', 'User') }
        Write-Host "PowerShell update checks have been disabled." -ForegroundColor Green
    } else {
        Write-Host "PowerShell update checks are already disabled, skipping..." -ForegroundColor Green
    }
}

function Initialize-Terminal(){
    if (-not (Get-Command "wt" -ErrorAction SilentlyContinue)) {
        $windowsTerminalPath = "$($env:ProgramFiles)\WindowsApps\Microsoft.WindowsTerminal_1.22.11141.0_x64__8wekyb3d8bbwe"
        if((Test-Path $windowsTerminalPath)){
            $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
            $machinePath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
            if($userPath -notlike "*;$($windowsTerminalPath)*" -and $machinePath -notlike "*;$($windowsTerminalPath)*"){
                Write-Host "Adding Windows Terminal to Path." -ForegroundColor Yellow
                [Environment]::SetEnvironmentVariable("Path", $userPath + ";$($windowsTerminalPath)", [EnvironmentVariableTarget]::User)
            }
        }
        else {
            Write-Host "Windows Terminal is not Installed!" -ForegroundColor Red
            return
        }
    }

    Write-Host "Configuring Windows Terminal..." -ForegroundColor Cyan
    # Check and install MesloLGS font
    $mesloFontName = "MesloLGS"
    $fontsFolder = "$env:SystemRoot\Fonts"

    if (-not (Get-ChildItem -Path $fontsFolder -Filter "*.ttf" | Where-Object { $_.Name -like "*$mesloFontName*" })) {
        Write-Host "MesloLGS NF font is not installed. Installing MesloLGS NF font..." -ForegroundColor Yellow
        $mesloFontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
        $mesloFontZip = "Meslo.zip"
        $mesloFontExtractPath = "MesloFonts"

        Invoke-WebRequest -Uri $mesloFontUrl -OutFile $mesloFontZip
        Expand-Archive -Path $mesloFontZip -DestinationPath $mesloFontExtractPath -Force
        Copy-Item -Path "$mesloFontExtractPath\*.ttf" -Destination $fontsFolder -Force
        Remove-Item -Path $mesloFontZip, $mesloFontExtractPath -Recurse -Force

        Write-Host "MesloLGS NF font installed successfully." -ForegroundColor Green
    } else {
        Write-Host "MesloLGS NF font is already installed, skipping..." -ForegroundColor Green
    }

    # Set MesloLGS NF font as the default in Windows Terminal settings
    $terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (Test-Path $terminalSettingsPath) {
        $settingsJson = Get-Content -Path $terminalSettingsPath -Raw | ConvertFrom-Json

        if ($settingsJson.profiles.defaults.font.PSObject.Properties.Match("face")) {
            if ($settingsJson.profiles.defaults.font.face -ne "MesloLGS NF") {
                Write-Host "Setting MesloLGS NF font as the default..." -ForegroundColor Yellow
                $settingsJson.profiles.defaults.font.face = "MesloLGS NF"
                $settingsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalSettingsPath -Force
                Write-Host "MesloLGS NF font has been set as the default in Windows Terminal settings." -ForegroundColor Green
            } else {
                Write-Host "MesloLGS NF font is already set as the default, skipping..." -ForegroundColor Green
            }
        } else {
            Write-Host "Adding font.face property to defaults and setting it to MesloLGS NF..." -ForegroundColor Yellow
            if (-not $settingsJson.profiles.defaults.font) {
                $settingsJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name font -Value @{ face = "MesloLGS NF" }
            } else {
                $settingsJson.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name face -Value "MesloLGS NF"
            }
            $settingsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalSettingsPath -Force
            Write-Host "MesloLGS NF font has been set as the default in Windows Terminal settings." -ForegroundColor Green
        }
    } else {
        Write-Host "Windows Terminal settings file not found. Please ensure Windows Terminal is installed." -ForegroundColor Red
    }

    # Configure Windows Terminal to use the Dark+ color scheme and enable transparency
    if (Test-Path $terminalSettingsPath) {
        $settingsJson = Get-Content -Path $terminalSettingsPath -Raw | ConvertFrom-Json

        # Ensure profiles.defaults exists
        if (-not $settingsJson.profiles.defaults) {
            $settingsJson.profiles | Add-Member -MemberType NoteProperty -Name defaults -Value @{}
        }

        # Set the color scheme to Dark+
        $settingsJson.profiles.defaults.colorScheme = "Dark+"

        # Enable transparency at 90%
        $settingsJson.profiles.defaults.useAcrylic = $True
        $settingsJson.profiles.defaults.opacity = 90

        # Save the updated settings
        $settingsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalSettingsPath -Force
        Write-Host "Windows Terminal already configured..." -ForegroundColor Green
    } else {
        Write-Host "Windows Terminal settings file not found. Please ensure Windows Terminal is installed." -ForegroundColor Red
    }
}

function Install-ScheduledTasks() {
    param(
        [Parameter(Mandatory = $True)]
        [String]$ahkDirectory,

        [Parameter(Mandatory = $True)]
        [String]$taskXml
    )
    
    Write-Host "Installing Scheduled Tasks..." -ForegroundColor Cyan
    
    # Ensure the source directory exists
    if (-not (Test-Path $ahkDirectory)) {
        Write-Host "The specified directory does not exist: $ahkDirectory" -ForegroundColor Red
        return
    }

    # Ensure the destination directory exists
    $destinationDirectory = "$($env:systemDrive)\AHK"
    if (-not (Test-Path $destinationDirectory)) {
        New-Item -Path $destinationDirectory -ItemType Directory -Force | Out-Null
    }

    # Get all .ahk files in the specified directory
    $ahkFiles = Get-ChildItem -Path $ahkDirectory -Filter *.ahk -File

    # Copy the .ahk files to the destination directory
    foreach ($file in $ahkFiles) {
        Copy-Item -Path $file.FullName -Destination $destinationDirectory -Force
    }

    # Create a scheduled task for each AHK file in the destination directory
    foreach ($file in $ahkFiles) {
        $taskName = "AHK $($file.BaseName)"
        $taskPath = "\Personal\$($taskName)"
        
        # Replace placeholders in the XML
        $currentTaskXml = $taskXml -replace 'TASKPATH', $taskPath
        $currentTaskXml = $currentTaskXml -replace 'FILEPATH', "$destinationDirectory\$($file.Name)"

        # Check if the task already exists
        $taskExists = -not (schtasks.exe /Query /TN $taskPath 2>&1 | Select-String "ERROR:")

        if (-not $taskExists) {
            # Save the XML to a temporary file
            $tempXmlPath = [System.IO.Path]::GetTempFileName()
            Set-Content -Path $tempXmlPath -Value $currentTaskXml -Encoding Unicode

            # Register the scheduled task
            schtasks.exe /Create /TN $taskPath /XML $tempXmlPath /F | Out-Null

            # Remove the temporary XML file
            Remove-Item -Path $tempXmlPath -Force

            Write-Host "Scheduled task created for $($file.Name)." -ForegroundColor Yellow
        } else {
            Write-Host "Scheduled task for $($file.Name) already exists, skipping..." -ForegroundColor Green
        }
    }
}

function Initialize-Waterfox(){
    param (
        [Parameter(Mandatory = $true)]
        [string]$sourcePath
    )
    
    Write-Host "Configuring Waterfox Theme..." -ForegroundColor Cyan

    # Check if the source path exists
    if (-Not (Test-Path $sourcePath)) {
        Write-Host "Source path '$sourcePath' does not exist. Please provide a valid path." -ForegroundColor Red
        return
    }

    # Get all profile directories
    $profileDirectories = Get-ChildItem -Path "$($env:APPDATA)\Waterfox\Profiles" -Directory

    foreach ($browserProfile in $profileDirectories) {
        $chromeFolderPath = Join-Path -Path $browserProfile.FullName -ChildPath "chrome"
        $addonsJsonPath = Join-Path -Path $browserProfile.FullName -ChildPath "addons.json"

        # Check if the profile directory contains an addons.json file
        if (Test-Path $addonsJsonPath) {
            # Get the list of files in the source and chrome folders
            $sourceFiles = Get-ChildItem -Path $sourcePath -Recurse -File
            $overwriteNeeded = $False
            
            foreach ($sourceFile in $sourceFiles) {
                $relativePath = $sourceFile.FullName.Substring($sourcePath.Length + 1)
                $chromeFilePath = Join-Path -Path $chromeFolderPath -ChildPath $relativePath
                #Write-Host "FilePath: $($chromeFilePath)"
                if (-Not (Test-Path $chromeFilePath)) {
                    # If the file does not exist in chrome, we need to copy it
                    $overwriteNeeded = $True
                    break
                } else {
                    # If the file exists, compare the content
                    try {
                        $sourceFileHash = Get-FileHash -Path $sourceFile.FullName
                        $chromeFileHash = Get-FileHash -Path $chromeFilePath

                        if ($sourceFileHash.Hash -ne $chromeFileHash.Hash) {
                            # If the hashes are different, we need to overwrite
                            $overwriteNeeded = $True
                            break
                        }
                    }
                    catch {
                        Write-Host "Error comparing files: $($sourceFile.FullName) and $($chromeFilePath). Skipping..." -ForegroundColor Red
                        continue
                    }
                }
            }

            if ($overwriteNeeded) {
                # Ensure the chrome folder exists before copying
                if (-Not (Test-Path $chromeFolderPath)) {
                    New-Item -ItemType Directory -Path $chromeFolderPath -Force | Out-Null
                }

                # Copy the contents from the source path to the chrome folder, overwriting existing files
                Copy-Item -Path "$sourcePath\chrome\*" -Destination $chromeFolderPath -Recurse -Force
                Write-Host "Transferred contents from '$sourcePath' to '$chromeFolderPath'." -ForegroundColor Green
            } else {
                Write-Host "'$(Split-Path -Path $browserProfile.FullName -Leaf)' already contains this configuration. Skipping..." -ForegroundColor Green
            }
        }
    }
}

function Initialize-WaterfoxPrefs {
    param (
        [Parameter(Mandatory = $True)]
        [hashtable]$Preferences
    )

    Write-Host "Configuring Waterfox User Configuration..." -ForegroundColor Cyan

    $profileDirectories = Get-ChildItem -Path "$($env:APPDATA)\Waterfox\Profiles" -Directory
    $prefsFilePath = $null

    foreach ($profileDir in $profileDirectories) {
        $prefsFilePathTest = Join-Path -Path $profileDir.FullName -ChildPath "prefs.js"
        if (Test-Path $prefsFilePathTest) {
            $prefsFilePath = $prefsFilePathTest
            break  # Exit the loop once we find the prefs.js file
        }
    }

    if (-not (Test-Path $prefsFilePath)) {
        Write-Host "prefs.js file not found in the profile folder." -ForegroundColor Red
        return
    }

    # Read the contents of prefs.js
    $prefsContent = Get-Content -Path $prefsFilePath
    $changesMade = $false

    # Loop through each preference in the hashtable
    foreach ($key in $Preferences.Keys) {
        $value = $Preferences[$key]
        $prefLine = "user_pref(`"$key`", $value);"
        $existingLine = "user_pref(`"$key`","

        # Initialize a flag to track if the preference exists
        $preferenceFound = $false

        # Check if the preference exists in the file
        for ($i = 0; $i -lt $prefsContent.Count; $i++) {
            if ($prefsContent[$i] -like "$existingLine*") {
                [String]$currentLine = $prefsContent[$i]
                [String]$currentValue = ($currentLine -split ',')[1].Trim() -replace '\);', ''
                #Write-Host "Value $($value) Currentvalue $($currentValue)"
                # Check if the current value is the same as the desired value
                if ($currentValue -eq $value) {
                    Write-Host "Preference '$key' is already set to the desired value '$value'. Skipping..." -ForegroundColor Green
                    $preferenceFound = $True
                    break  # Skip to the next preference
                }

                # Replace the existing value
                $prefsContent[$i] = $prefLine
                Write-Host "Updated preference: $key to $value" -ForegroundColor Yellow
                $changesMade = $True  # Mark that a change was made
                $preferenceFound = $True
                break  # Exit the loop since we found and updated the preference
            }
        }

        # If the preference was not found, add it to the end of the file
        if (-not $preferenceFound) {
            $prefsContent += "`n$prefLine"
            Write-Host "Added preference: $key with value $value" -ForegroundColor Yellow
            $changesMade = $True  # Mark that a change was made
        }
    }

    # Write the updated content back to prefs.js only if changes were made
    if ($changesMade) {
        Set-Content -Path $prefsFilePath -Value $prefsContent
    }
}

function Initialize-PS7Terminal(){
    Write-Host "Configuring Windows Terminal to Use Powershell 7..." -ForegroundColor Cyan

    if (-not (Test-Path -Path "$env:ProgramFiles\PowerShell\7")) {
        Write-Host "Powershell 7 is not installed!" -ForegroundColor Red
        return
    }
    if (-not (Get-Command "wt" -ErrorAction SilentlyContinue)) {
        if(-not (Test-Path "$($env:ProgramFiles)\WindowsApps\Microsoft.WindowsTerminal_1.22.11141.0_x64__8wekyb3d8bbwe")){
            Write-Host "Adding Windows Terminal to Path." -ForegroundColor Yellow
            [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$($env:ProgramFiles)\WindowsApps\Microsoft.WindowsTerminal_1.22.11141.0_x64__8wekyb3d8bbwe", [EnvironmentVariableTarget]::User)
        }
        else {
            Write-Host "Windows Terminal is not Installed!" -ForegroundColor Red
            return
        }
    }
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (-not (Test-Path -Path $settingsPath)) {
        Write-Host "Windows Terminal Settings file not found at $($settingsPath)" -ForegroundColor Red
        return
    }
    $settingsContent = Get-Content -Path $settingsPath | ConvertFrom-Json
    $PS7Profile = $settingsContent.profiles.list | Where-Object { $_.commandline -eq "$($env:SystemDrive)\\Program Files\\PowerShell\\7\\pwsh.exe" }
    if ($PS7Profile) {
        $settingsContent.defaultProfile = $PS7Profile.guid
        $updatedSettings = $settingsContent | ConvertTo-Json -Depth 100
        Set-Content -Path $settingsPath -Value $updatedSettings
        Write-Host "Default terminal profile updated to PowerShell 7." -ForegroundColor Yellow
    } else {
        Write-Host "No PowerShell 7 profile found in Windows Terminal settings using the name attribute." -ForegroundColor Red
    }
}