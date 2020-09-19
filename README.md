# Windows-Auto-Config
 Automatic custom configuration of Windows 10 installation

## Tools and instructions

###### Tools
For this automated procedure were used the following tools:

* Windows PowerShell
* Chocolatey
* Chocolatey GUI

###### Procedure
The following actions were performed:

* Execute the PowerShell at administrator Level
* Run `Get-ExecutionPolicy` to gain info about the execution policy of the system
* Set the policy as `AllSigned` if necessary, with the command `Set-ExecutionPolicy AllSigned`
* Install Chocolatey running the command

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

**note**: These instructions are here to understand how this was done the first time, it's probably better to just follow the instructions on the official site to install Chocolatey.

* Run `choco install chocolateygui` to install the Chocolatey Package [ChocolateyGUI](https://chocolatey.org/packages/ChocolateyGUI)
