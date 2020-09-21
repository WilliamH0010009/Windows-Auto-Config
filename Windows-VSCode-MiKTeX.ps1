#Elevate to Admin privilege or Chocolaty doesn't work
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#----------------------------Local Function Declarations--------------------------------------
function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# --------------------------------------Rename PC---------------------------------------------
#$computerName = Read-Host 'Enter New Computer Name'
#Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
#Rename-Computer -NewName $computerName

# -------------------------------------------Temporarily Disable sleep-----------------------------------------------
Write-Host ""
Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

# ------------------------------------Add "Computer" on desktop, registry edit-----------------------------------------
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

#-----------------------------------------------Delete usless preinstalled apps-----------------------------------------
# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
    "king.com.CandyCrushSaga",
    "Microsoft.BingNews",
    "Microsoft.MicrosoftSolitaireCollection",
    "Fitbit.FitbitCoach",
    "4DF9E0F8.Netflix",
    "SpotifyAB.SpotifyMusic")

#Removed items:
#   "Microsoft.Messaging",
#   "Microsoft.People",
#   "Microsoft.WindowsFeedbackHub",
#   "Microsoft.YourPhone",
#   "Microsoft.MicrosoftOfficeHub",
#   "Microsoft.GetHelp"

foreach ($uwp in $uwpRubbishApps) {
    Get-AppxPackage -Name $uwp | Remove-AppxPackage
}

# ----------------------------------------------------------------------------- Enable IIS
#Write-Host ""
#Write-Host "Installing IIS..." -ForegroundColor Green
#Write-Host "------------------------------------" -ForegroundColor Green
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
# ----------------------------------------------------------------------------- Enable UWP development
#Write-Host ""
#Write-Host "Enable Windows 10 Developer Mode..." -ForegroundColor Green
#Write-Host "------------------------------------" -ForegroundColor Green
#reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# ----------------------------------------------------------------------------- Enable Remote Desktop and set Firewall exception
#Write-Host ""
#Write-Host "Enable Remote Desktop..." -ForegroundColor Green
#Write-Host "------------------------------------" -ForegroundColor Green
#Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
#Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
#Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

#--------------------------------------------- Check and install Chocolatey ---------------------------------
if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolatey for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

#---------------------------------------- Install Applications using 'choco' --------------------------------------
Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$Apps = @(
    "7zip.install",
    "firefox",
    "git",
    "vlc",
    "adobereader",
    "mingw",                     #compiler GNU per windows
    "vscode",                    #virtual studio code
    "atom",
    "miktex.install",            #versione installata (non portable) di miktex
    "python",
    "github-desktop",
    "zoom",
    "adb",
    "spotify",
    "discord.install",
    "strawberryperl")            #Versione open di Binary Perl, serve per la composizione automatica con MiKTeX 

# APPS Not installed that OP used
#    "microsoft-edge",
#    "googlechrome",
#    "dotnetcore-sdk",          #skd per web Applications
#    "ffmpeg",                  #multimedia framework per fare "tutto" con "ogni" formato video
#    "wget",                    #for retrieving files using HTTP, HTTPS and FTP
#    "openssl.light",           #implementazione open di SSL e TLS, protocolli crittografici
#    "notepadplusplus.install",
#    "linqpad",                 #editor ottimizzato per C#,F#,VB, LINQ, SQL, Azure e .NET in generale
#    "sysinternals",            #tool diagnostica windows e app
#    "fiddler",                 #debugger per web-app che cattura richieste HTTP e HTTPS
#    "beyondcompare",           #compara file
#    "filezilla",               #client FTP
#    "lightshot.install",       #tool per screenshot custom
#    "microsoft-teams.install",
#    "teamviewer",              #'na robaccia per il controllo remoto nei meeting
#    "irfanview",               #graphic viewer. sembra 'na merda
#    "nodejs-lts",              #long term support di nodejs
#    "azure-cli",               #Command Line Interface di Azure
#    "powershell-core"          #versione open di powershell

foreach ($app in $Apps) {
    choco install $app -y
}

Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "The following packages should optionally be installed manually" -ForegroundColor Green

$NonAuto = @(
  "Citra",
  "MTG Arena",
  "Microsoft Office"
)

foreach ( $name in $NonAuto) {
    Write-Host $name
}

#  ----------------------------------------------------------------------------------------------------------
# |                                   MiKTeX and DnD Template configuration                                  |
#  ----------------------------------------------------------------------------------------------------------

#------------------------------------------- DnD5e Template Download ------------------------------------------

Write-Host "I'm downloading the DnD Template for LaTeX from github" -ForegroundColor Green
git clone https://github.com/rpgtex/DND-5e-LaTeX-Template C:\ProgramData\TEXMF\tex\latex\dnd

Write-Host "Let's make sure MiKTeX is in Path as it should" -ForegroundColor Green
if( Check-Command( 'initexmf') ){
  "Yup, perfect"
  }
else{
  Write-Host "We can't, let's backup Path directly in C and fix this"
  $env:path >> C:\PATH_Backup.txt #makes path backup

  $env:Path += ";C:\Program Files\MiKTeX\miktex\bin\" #Add commands to current session
  [Environment]::SetEnvironmentVariable("Path", $env:Path, 'Machine') #set system Path (works from next session)

  Write-Host "Should be OK now"
}

Write-Host "I'm updating MiKTeX because it will bother us if it never was" -ForegroundColor Green

#We update MiKTeX so that it doesn't bother us
initexmf --admin --update-fndb

Write-Host "Registering C:\ProgramData\TEXMF as a recognized Directory for MiKTeX" -ForegroundColor Green
#we register the local TEXMF directory so we can access custom templates
initexmf --admin --register-root="C:\ProgramData\TEXMF"

#  ----------------------------------------------------------------------------------------------------------
# |                                           VSCode Configuration                                           |
#  ----------------------------------------------------------------------------------------------------------

#---------------------------------- Importing this Repo to access old backups ---------------------------------

git clone https://github.com/gnowwho/Windows-Auto-Config C:\Github\Windows-Auto-Config
$backupAdress = "C:\Github\Windows-Auto-Config\VSCode-Backup-and-Restore\extensions.txt"

#----------------------------------- We verify the presence of needed commands --------------------------------

Write-Host "Let's make sure we can manipulate VSCode packages" -ForegroundColor Green
if( Check-Command( 'code') ){
  "Yup, perfect"
  }
else{
  Write-Host "We can't, let's backup Path directly in C and fix this"
  $env:path >> C:\PATH_Backup.txt #makes path backup

  $env:Path += ";C:\Program Files\Microsoft VS Code\bin\" #Add commands to current session
  [Environment]::SetEnvironmentVariable("Path", $env:Path, 'Machine') #set system Path (works from next session)

  Write-Host "Should be OK now"
}

#------------------------------------------ Explicit Package installation -------------------------------------

$howMany = (Get-Content $backupAdress |Measure-Object -Line).lines #we count how many packages we need to install

for($i = 0; $i -lt $howMany; $i++){
    code --install-extension (Get-Content $backupAdress)[$i]
}

#------------------------------------------------ Re enabling sleep -------------------------------------------
Write-Host ""
Write-Host "Re-Enable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 10
Powercfg /Change standby-timeout-ac 30

Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer
