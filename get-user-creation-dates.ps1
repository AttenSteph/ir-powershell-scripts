<#
.SYNOPSIS
    Write user accounts with creation dates from a M365 tenant with creation date. Defaults to .\UsersCreationDate.csv
.DESCRIPTION
    Requries AzureAD  
    Windows Terminal recommended. https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US  
    PS> winget install --id Microsoft.Powershell --source winget
    PS> Install-Module -Name AzureAD
.EXAMPLE
    get-user-creation-dates.ps1
.NOTES
    Author: Stephanie Sherwood
#>

# Import the Azure AD module
Import-Module AzureAD
 
# Connect to Azure AD
Connect-AzureAD
 
# Get the user object for the user with the specified email address
$Users = Get-AzureADUser -All:$true
 
$UserData = @()
# Iterate through each user
$Users | ForEach-Object {
    Write-Host "Getting created date for" $_.UserPrincipalName
 
    #Collect the user data
    $UserData += New-Object PSObject -property $([ordered]@{
        ObjectId  = $_.ObjectId           
        DisplayName = $_.DisplayName
        UserPrincipalName = $_.UserPrincipalName
        CreatedDateTime = $_.ExtensionProperty.createdDateTime
    })
}
 
#Export to CSV
$UserData
$UserData | Export-CSV ".\UsersCreationDate.csv" -NoTypeInformation
