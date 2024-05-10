# Connect to MS Graph with Appropriate Scopes
Connect-MgGraph -Scopes "Application.ReadWrite.All","AppRoleAssignment.ReadWrite.All","DelegatedPermissionGrant.ReadWrite.All","Directory.ReadWrite.All","User.ReadWrite","User.RevokeSessions.All"

# Get Service Principal using objectId
$sp = Get-MgServicePrincipal -ServicePrincipalId <CHANGE THIS GUID>


# Remove all users assigned to the application
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