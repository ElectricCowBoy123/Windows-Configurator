$ahkDirectory = "$($PSScriptRoot)\config\AHK"
$ahkExecutable = "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe"
$taskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffffff")</Date>
    <Author>$($env:UserName)</Author>
    <URI>TASKPATH</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$($env:UserName)</UserId>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>"$($ahkExecutable)"</Command>
      <Arguments>"FILEPATH"</Arguments>
    </Exec>
  </Actions>
</Task>
"@


Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Params
{ 
    [DllImport("User32.dll", CharSet = CharSet.Unicode)] 
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

$urlsToCheck = @(
    "https://chromedriver.storage.googleapis.com/LATEST_RELEASE",
    "https://chromedriver.storage.googleapis.com",
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip",
    "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cobalt2.omp.json",
    "https://github.com/Lexikos/AutoHotkey_L/releases/download/v1.1.37.02/AutoHotkey_1.1.37.02_setup.exe",
    "https://github.com/Genymobile/scrcpy/releases/download/v3.2/scrcpy-win64-v3.2.zip",
    "https://aka.ms/getwinget"
)

$modules = @(
    @{ Name = "Helper"; Id = "$PSScriptRoot\modules\Helper\Helper.psm1" },
    @{ Name = "Install-Software"; Id = "$PSScriptRoot\modules\Install-Software\Install-Software.psm1" },
    @{ Name = "Configure-Windows"; Id = "$PSScriptRoot\modules\Configure-Windows\Configure-Windows.psm1" },
    @{ Name = "Initialize-Software"; Id = "$PSScriptRoot\modules\Initialize-Software\Initialize-Software.psm1" }
)

$wingetSoftware = @(
    @{ Name = "Notepad++"; Id = "Notepad\+\+\.Notepad\+\+" },
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "7-Zip"; Id = "7zip.7zip" }
    @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "OhMyPosh"; Id = "JanDeDobbeleer.OhMyPosh" },
    @{ Name = "Waterfox"; Id = "Waterfox.Waterfox" },
    @{ Name = "Git"; Id = "Git.Git" }
)

$pipPackages = @(
    @{ Name = "Selenium"; Module = "selenium" },
    @{ Name = "Requests"; Module = "requests" }
)

$bloatwarePackages = @(
    "Microsoft.3DBuilder",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

$wallpaperPath = "C:\Users\JohnFearn\OneDrive - Daffodil Group\Pictures\Wallpapers\2ae89afb-f605-4679-80da-b47099b06d3e.png"

$themeFilePath = "$($PSScriptRoot)\config\NotepadPlusPlus\VS2019-Dark.xml"
$ConfigFilePath = "$($PSScriptRoot)\config\NotepadPlusPlus\config.xml"

$registrySettings = @(
    @{ Name = "Show Hidden Files"; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Property = 'Hidden'; Value = 1 },
    @{ Name = "Enable End Task"; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Property = 'TaskbarEndTask'; Value = 1 },
    @{ Name = "Disable Spotlight Suggestions"; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Property = 'SubscribedContent-310093Enabled'; Value = 0 },
    @{ Name = "Disable Secondary Spotlight Suggestions"; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Property = 'SubscribedContent-338388Enabled'; Value = 0 }
)

$waterFoxConfigPath = "$($PSScriptRoot)\config\Waterfox"

$waterFoxPrefrences = @{
    "browser.theme.enableWaterfoxCustomizations" = 2
}