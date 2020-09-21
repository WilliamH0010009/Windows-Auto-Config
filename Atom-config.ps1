if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname){
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

#Ci si aspetta di eseguire questo script con git e Atom già installati

#la parte qui sopra non è da includere se si copia nello script principale

Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "Configuring Atom, hoping to get it right" -ForegroundColor Green

#ottieni accesso a github!!!
#Credo fatto automaticamente alla richiesta di clone

#scarica la repo .atom da github
Write-Host "A prompt for username and password should now appear"
Write-Host "Using a token instead of a password is advised"
git clone https://github.com/gnowwho/.atom C:\Users\$env:username\.atom

#Assicurati che apm e atom siano in PATH
#se non lo sono metticeli
Write-Host "Let's make sure we can manipulate Atom packages" -ForegroundColor Green
if( Check-Command( 'apm') ){
  "Yup, perfect"
  }
else{
  Write-Host "We can't, let's backup Path directly in C and fix this"
  $env:path >> C:\PATH_Backup.txt #makes path backup

  $env:Path += ";C:\Users\$env:username\AppData\Local\atom\bin" #Add apm and atom as commands to current session
  [Environment]::SetEnvironmentVariable("Path", $env:Path, 'Machine')

  Write-Host "Should be OK now"
}

#Fanculo la sincronizzazione facciamo la lista a mano
Write-Host "Installing the Packages now" -ForegroundColor Green
$AtomExtensions = @(
    "language-latex",
    "language-powershell",
    "latex",
    "pdf-view",
    "platformio-ide-terminal")

foreach ($voice in $AtomExtensions) {
    apm install $voice
}


#scarica la repo di Latex per dnd (deprecated)
#Write-Host "I'm downloading the DnD Template for LaTeX from github"
#git clone https://github.com/rpgtex/DND-5e-LaTeX-Template C:\ProgramData\MiKTeX\tex\latex\dnd


Read-Host -Prompt "Setup is done (hopefully), press a key to exit"
