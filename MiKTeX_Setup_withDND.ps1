if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname){
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

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

Read-Host -Prompt "Setup is done. You should be able to properly compose DnD books with MiKTeX. [Press a key]"
