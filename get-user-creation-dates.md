# get-user-creation-dates.ps1

## Synopsis
    Write user accounts with creation dates from a M365 tenant with creation date. Defaults to .\UsersCreationDate.csv


## Syntax

```powershell
get-user-creation-dates.ps1
```

## Install
Requries AzureAD  
[Windows Terminal recommended](https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&)

```powershell
winget install --id Microsoft.Powershell --source winget
Install-Module -Name AzureAD
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