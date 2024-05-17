<#
.SYNOPSIS
    Secure a malicious M365 Enterprise Applications. Disables app, disables user sign-in for app, requires assignement, makes invisible, removes all users and groups, permissions to the app, role assignments, revokes refresh tokens and makes you a sammich.
.DESCRIPTION
    *** NOTE MS Graph Beta Powershell SDK will register itself as a new enterprise app for the tenant. REMOVE THIS APP REGISTRATION WHEN YOU ARE DONE!***
    Based on MS recommendations to secure a malicious Entra app once reported through Entra console. However, that version is broken, this version works, and it takes it a step farther in automating security.
    Requries Recently new version of Powershell, AzureAD, & MS Graph Beta
    Windows Terminal recommended. https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US
    PS> winget install --id Microsoft.Powershell --source winget
    PS> Install-Module AzureAD
    PS> Install-Module Microsoft.Graph.Beta
.PARAMETER AppID
    ApplicationID for Enterprise App. Find under App Overview > Properties in Entra console. Entra > Home > Enterprise applications | All applications > Overview
.PARAMETER ObjectID
    ObjectID for Enterprise App. Find under App Overview > Properties in Entra console. Entra > Home > Enterprise applications | All applications > Overview
.EXAMPLE
    C:\PS> secure-malicious-entra-app.ps1 -AppID 751ff9b5-edde-4dc1-8093-adf647495745 -ObjectID 636c6403-dbf8-4362-8be1-e54b2007b222
.NOTES
    Author: Stephanie Sherwood
#>
param(
    # [Parameter(Mandatory=$true)]
    # [String]$AppID,
    [Parameter(Mandatory=$true)]
    [String]$ObjectID
)

# Connect to MS Graph with Appropriate Scopes
Connect-MgGraph -NoWelcome -Scopes "Application.ReadWrite.All","AppRoleAssignment.ReadWrite.All","DelegatedPermissionGrant.ReadWrite.All","Directory.ReadWrite.All","User.ReadWrite","User.RevokeSessions.All"

# Get Service Principal using objectId
$sp = Get-MgServicePrincipal -ServicePrincipalId $ObjectID

# Get MS Graph App role assignments using objectId of the Service Principal
$assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id -All

# Remove all users and groups assigned to the application
$assignments | ForEach-Object {
    if ($_.PrincipalType -eq "User") {
        Remove-MgUserAppRoleAssignment -UserId $_.PrincipalId -AppRoleAssignmentId $_.Id
    } elseif ($_.PrincipalType -eq "Group") {
        Remove-MgGroupAppRoleAssignment -GroupId $_.PrincipalId -AppRoleAssignmentId $_.Id
    }
}

#Revoke all permissions granted to the application
# Get all delegated permissions for the service principal
$spOAuth2PermissionsGrants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $sp.Id -All

# Remove all delegated permissions
$spOAuth2PermissionsGrants | ForEach-Object {
    Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $_.Id
}

# Get all application permissions for the service principal
$spApplicationPermissions = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id

# Remove all app role assignments
$spApplicationPermissions | ForEach-Object {
    Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $_.PrincipalId -AppRoleAssignmentId $_.Id
}

# Revoke refresh tokens for all users
# Get MS Graph App role assignments using objectId of the Service Principal
$assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id -All | Where-Object {$_.PrincipalType -eq "User"}

# Revoke refresh token for all users assigned to the application
$assignments | ForEach-Object {
    Invoke-MgBetaInvalidateUserRefreshToken -UserId $_.PrincipalId
}

# If Service principal exists already, disable it , else, create it and disable it at the same time 
if ($sp) { Update-MgServicePrincipal -ServicePrincipalId $sp.Id -AccountEnabled:$false }
else {  $sp = New-MgServicePrincipal -AppId $appId –AccountEnabled:$false }

# Require app assigment
$params = @{
	appRoleAssignmentRequired = $true
}
Update-MgServicePrincipal -ServicePrincipalId $sp.ID -BodyParameter $params

# Hide App from users
$tags = $sp.tags
$tags += "HideApp"
Update-MgServicePrincipal -ServicePrincipalID  $objectId -Tags $tags

Write-Host "done"

# Write out some details for incident report
# Get-MgApplication -ApplicationId $AppID | Select-Object appDisplayName, DisplayName, Id, alternativeNames | fl
# Get-MgApplication -InputObject $AppID | 
#   Format-List Id, DisplayName, AppId, SignInAudience, PublisherDomain

# Write-Host "Script complete. Copy the text below to your report."
# Write-Host "------SNIP------"
# Write-Host "App Display Name: $ObjectID.appDisplayName"
# Write-Host "Display Name:  $ObjectID.DisplayName"
# Write-Host "Object ID: $ObjectID.Id"
# Write-Host "Alternative Names: $ObjectID.AlternativeNames"
# Write-Host "------SNIP------"

# Get-MgApplication -Filter "AppId eq $AppID" | 
#   Format-List Id, DisplayName, AppId, SignInAudience, PublisherDomain
