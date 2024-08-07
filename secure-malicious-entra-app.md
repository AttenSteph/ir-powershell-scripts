# secure-malicious-entra-app.ps1

Secure a malicious M365 Enterprise Applications. Disables app, disables user sign-in for app, requires assignement, makes invisible, removes all users and groups, permissions to the app, role assignments, revokes refresh tokens and makes you a sammich.

## SYNTAX
```powershell
secure-malicious-entra-app.ps1 -AppID <String> -ObjectID <String>
```

## DESCRIPTION

**NOTE: MS Graph Beta Powershell SDK will register itself as a new enterprise app for the tenant. REMOVE THIS APP REGISTRATION WHEN YOU ARE DONE!**

Based on MS recommendations to secure a malicious Entra app once reported through Entra console. However, that version is broken, this version works, and it takes it a step farther in automating security. Requries Recently new version of Powershell, AzureAD, & MS Graph Beta Windows Terminal recommended. https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US

```powershell
winget install --id Microsoft.Powershell --source winget
Install-Module AzureAD
Install-Module Microsoft.Graph.Beta
```


## REMARKS

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