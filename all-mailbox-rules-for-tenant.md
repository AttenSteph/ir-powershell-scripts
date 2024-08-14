# all-mailbox-rules-for-tenant.ps1
    
Write all mailbox rules from a M365 tenant, including hidden rules to .csv file. Defualts to all_mailbox_rules.csv if output file not specified.   
    
## Syntax

```powershell
all-mailbox-rules-for-tenant.ps1 -UserPrincipalName <String> -OutFile <String>
```
    
## Install

- Trust winget repo.
- [Install Windows Terminal (Recommended, but not necessary)](https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US).
- Install Powershell 7.4+
- Install required Powershell modules (Exchange Online Powershell Module 3.4.0+).

```powershell
Set-PackageSource -Name winget -Trusted
winget install --id Microsoft.WindowsTerminal --source winget
winget install --id Microsoft.Powershell --source winget
Install-Module Excha
```

## Get-Help Usge

To see the examples, type:
```powershell
Get-Help all-mailbox-rules-for-tenant.ps1 -Examples
```
For more information, type:
```powershell
Get-Help all-mailbox-rules-for-tenant.ps1 -Detailed
```  
For technical information, type:
```powershell
Get-Help all-mailbox-rules-for-tenant.ps1 -Full
```
