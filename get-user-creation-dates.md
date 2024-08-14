# get-user-creation-dates.ps1

## Synopsis
    Write user accounts with creation dates from a M365 tenant with creation date. Defaults to .\UsersCreationDate.csv


## Syntax

```powershell
get-user-creation-dates.ps1
```

## Install
- Trust winget repo.
- [Install Windows Terminal (Recommended, but not necessary)](https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US).
- Install Powershell 7.4+
- Install required Powershell modules (AzureAD).

```powershell
Set-PackageSource -Name winget -Trusted
winget install --id Microsoft.WindowsTerminal --source winget
winget install --id Microsoft.Powershell --source winget
Install-Module AzureAD -Scope AllUsers -Confirm:$False -Force
```
## Get-Help Usge
To see the examples, type:  
```powershell
Get-Help get-user-creation-dates.ps1 -Examples
```
For more information, type:
```powershell
Get-Help get-user-creation-dates.ps1 -Detailed
```
For technical information, type:
```powershell
Get-Help get-user-creation-dates.ps1 -Full
```
