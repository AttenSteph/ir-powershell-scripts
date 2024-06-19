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
