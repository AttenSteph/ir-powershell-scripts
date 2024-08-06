**NAME**

secure-malicious-entra-app.ps1

**SYNOPSIS**

Secure a malicious M365 Enterprise Applications. Disables app, disables user sign-in for app, requires assignement, makes invisible, removes all users and groups, permissions to the app, role assignments, revokes refresh tokens and makes you a sammich.


**SYNTAX**
```
PS> secure-malicious-entra-app.ps1 [-AppID] <String> [-ObjectID] <String> [<CommonParameters>]
```

**DESCRIPTION**

**NOTE: MS Graph Beta Powershell SDK will register itself as a new enterprise app for the tenant. REMOVE THIS APP REGISTRATION WHEN YOU ARE DONE!**

Based on MS recommendations to secure a malicious Entra app once reported through Entra console. However, that version is broken, this version works, and it takes it a step farther in automating security. Requries Recently new version of Powershell, AzureAD, & MS Graph Beta Windows Terminal recommended. https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US

```
PS> winget install --id Microsoft.Powershell --source winget
PS> Install-Module AzureAD
PS> Install-Module Microsoft.Graph.Beta
```


**REMARKS**

To see the examples, type: "Get-Help secure-malicious-entra-app.ps1 -Examples"
For more information, type: "Get-Help secure-malicious-entra-app.ps1 -Detailed"
For technical information, type: "Get-Help secure-malicious-entra-app.ps1 -Full"