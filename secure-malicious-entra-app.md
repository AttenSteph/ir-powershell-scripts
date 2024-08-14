# secure-malicious-entra-app.ps1

Secure a malicious M365 Enterprise Applications. Disables app, disables user sign-in for app, requires assignement, makes invisible, removes all users and groups, permissions to the app, role assignments, revokes refresh tokens and makes you a sammich.

Based on MS recommendations to secure a malicious Entra app once reported through Entra console. However, that version is broken, this version works, and it takes it a step farther in automating security. 

## Syntax
```powershell
secure-malicious-entra-app.ps1 -AppID <String> -ObjectID <String>
```

## Install & Usage Notes

- Trust winget repo.
- [Install Windows Terminal (Recommended, but not necessary)](https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US).
- Install Powershell 7.4+
- Install required Powershell modules (AzureAD, MS (Graph, & MS Graph Beta)[https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0]).

```powershell
Set-PackageSource -Name winget -Trusted
winget install --id Microsoft.WindowsTerminal --source winget
winget install --id Microsoft.Powershell --source winget
Install-Module AzureAD -Scope AllUsers -Confirm:$False -Force
Install-Module Microsoft.Graph -Scope AllUsers -Confirm:$False -Force
Install-Module Microsoft.Graph.Beta -Scope AllUsers -Confirm:$False -Force
```
**NOTE: MS Graph Beta Powershell SDK will register itself as a new enterprise app for the tenant. REMOVE THIS APP REGISTRATION WHEN YOU ARE DONE!**



## Get-Help Usge

To see the examples, type:
```powershell
Get-Help secure-malicious-entra-app.ps1 -Examples
```  
For more information, type:
```powershell
Get-Help secure-malicious-entra-app.ps1 -Detailed
```
For technical information, type:
```powershell
Get-Help secure-malicious-entra-app.ps1 -Full
```  
