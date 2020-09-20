if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname){
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Write-Host "check di gcc che so esistere"
if(Check-Command( 'gcc')){
  Write-Host "so fare gli if"
}
else{
  Write-Host "Non so fare gli if"
}

Write-Host "check di re che so non esistere"
Check-Command( 're' )

Read-Host -Prompt "Premi un tasto"
