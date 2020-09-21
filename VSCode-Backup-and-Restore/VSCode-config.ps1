if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname){
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

#Ci aspettiamo che git e VSCode siano installati
#----------------------------------------------------------------------------------------------------------------------------------------------------------
#scarica la repo di Latex per dnd (deprecated)
#Write-Host "I'm downloading the DnD Template for LaTeX from github"
#git clone https://github.com/rpgtex/DND-5e-LaTeX-Template C:\ProgramData\MiKTeX\tex\latex\dnd

#----------------------------------------------------------------------------------------------------------------------------------------------------------
#Voglio recuperare il backup da github --Dove lo salvo? idealmente nella directory dove poi andrei a sincronizzare con git per avere
#la funzione che ricostruisce la lista di estensioni
git clone https://github.com/gnowwho/Windows-Auto-Config C:\Github\Windows-Auto-Config
$backupAdress = "C:\Github\Windows-Auto-Config\VSCode-Backup-and-Restore\extensions.txt"

#----------------------------------------------------------------------------------------------------------------------------------------------------------
#verifichiamo per sicurezza che "code" sia in path
# se no aggiungi "C:\Program Files\Microsoft VS Code\bin\"
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

#----------------------------------------------------------------------------------------------------------------------------------------------------------
#installiamo i pacchetti
$howMany = (Get-Content $backupAdress |Measure-Object -Line).lines #conta le righe

for($i = 0; $i -lt $howMany; $i++){
    code --install-extension (Get-Content $backupAdress)[$i]
}

#prompt 
Read-Host -Prompt "Setup is done (hopefully), press a key to exit"
