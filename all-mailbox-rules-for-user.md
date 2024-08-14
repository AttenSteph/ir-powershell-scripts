# all-mailbox-rules-for-user.ps1

Export all mailbox rules from a single M365 mailbox, including hidden rules, to .csv file. Defualts to .\<email_address>_all_mailbox_rules.csv if output file not specified.

## Syntax

```powershell
all-mailbox-rules-for-user.ps1 -UserPrincipalName <String> -Email <String> -OutFile <String>
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
Install-Module ExchangeOnlineManagement -Scope AllUsers -Confirm:$False -Force
```

## Get-Help Usge

To see the examples, type:
```powershell
Get-Help all-mailbox-rules-for-user.ps1 -Examples
```
For more information, type:
```powershell
Get-Help all-mailbox-rules-for-user.ps1 -Detailed
```  
For technical information, type:
```powershell
Get-Help all-mailbox-rules-for-user.ps1 -Full
```
