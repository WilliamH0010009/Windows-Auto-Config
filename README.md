# Windows-Auto-Config
 Automatic custom configuration of Windows 10 installation, Atom and VSCode

## Content
The repository contains some files which are not listed here to make this piece more futureproof. The main tools are

* **Windows-Auto-Conf**: it automatically configures the system as described later
* **Atom-Config**: this is a stand alone Atom configurator
* **VSCode-config**: this is a stand alone VSCode configurator
* **Windows-VSCode**: which should be the to go script out of the box. It's a tasteful copypasta of some previously listed scripts.
* **Backup-Extensions**: A script that is a single command in a tranchcoat: it produces a list of currently installed VSCode extensions
* **MiKTeX_Setup_withDND**: updates MiKTeX, configures TEXMF directory and downloads the [D&D template](https://github.com/rpgtex/DND-5e-LaTeX-Template) in it. Not necessairily in this order.
* **Windows-VSCode-MiKTeX**: Annoter copypasta of previous script, all in one. You figure it out which ones.

## Tools and instructions

###### Tools
For this automated procedure were consulted the following links

[Guide](https://edi.wang/post/2018/12/21/automate-windows-10-developer-machine-setup)

[Github](https://github.com/EdiWang/EnvSetup/), which has been forked on the personal packages

<details><summary>Original code for PowerShell in case they changed it</summary>
<p>

```powershell
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# -----------------------------------------------------------------------------
$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Add 'This PC' Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue
if ($item) {
    Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0  
}
else {
    New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null  
}

# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
    "Microsoft.Messaging",
    "king.com.CandyCrushSaga",
    "Microsoft.BingNews",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.MicrosoftOfficeHub",
    "Fitbit.FitbitCoach",
    "4DF9E0F8.Netflix",
    "Microsoft.GetHelp")

foreach ($uwp in $uwpRubbishApps) {
    Get-AppxPackage -Name $uwp | Remove-AppxPackage
}
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Installing IIS..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Windows 10 Developer Mode..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "[WARN] Ma de in China: some software like Google Chrome require the true Internet first" -ForegroundColor Yellow

$Apps = @(
    "7zip.install",
    "git",
    "microsoft-edge",
    "googlechrome",
    "vlc",
    "dotnetcore-sdk",
    "ffmpeg",
    "wget",
    "openssl.light",
    "vscode",
    "sysinternals",
    "notepadplusplus.install",
    "linqpad",
    "fiddler",
    "beyondcompare",
    "filezilla",
    "lightshot.install",
    "microsoft-teams.install",
    "teamviewer",
    "github-desktop",
    "irfanview",
    "nodejs-lts",
    "azure-cli",
    "powershell-core")

foreach ($app in $Apps) {
    choco install $app -y
}

Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer
```

</p>
</details>

### What does the automated Windows configuration do

The expected behaviour of the edited procedure is the following:

* it asks for Administrator Privileges
* Temporarily suspend sleep on AC
* Adds "This PC" icon to Desktop
* removes some useless apps such as:
  * Candy Crush Saga
  * Bing News
  * Microsoft Solitaire Collection
  * Fitbit Coach
  * Netflix
* Installs Chocolatey if not present
* Installs the following packages through choco:
  * 7zip
  * firefox
  * git
  * VLC media player
  * Adobe Reader
  * MinGW
  * Visual Studio Code
  * Atom
  * MikTeX
  * Phyton
  * Github Desktop
  * Zoom
  * Android Debug Bridge (ADB)
  * Spotify
  * Discord
* Suggests to manually install:
  * Citra
  * MTG Arena
  * Microsoft Office
* Re-enable sleep while on AC
* Prompt to restart the device

### What does the Rest do?

The VSCode and Atom stand alone configurators just install some packages to work with C/C++, Python (only VSCode as 20/09/20) and LaTex, if you look at the code you'll surely find a list of the packages.
The MiKTeX configurator clones a DnD 5e template in a dedicated TEXMF directory and adds it to MiKTeX. 

As for the other items they should be pretty self explainatory or I forgot to put them here, one of the two.

### Is There something left to do?

The VSCode backup tool doesn't care for anything but packages at the moment. It's not a problem for me right now, but ideally it should allow to backup and quickly set up themes, keybinds and snippets too. Actually this whole section of the script is probably useless given the native github syncronization of VSCode. 

More importantly I should create a script to edit battery charge tresholds, which should ask for user imput so that it can be used to reset tresholds to default values. This apparently needs to edit the register and I'm too lazy to do it right now.