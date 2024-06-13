# Import the Microsoft Graph PowerShell SDK module
# Import-Module Microsoft.Graph.PowerShell

# Connect to MS Graph with Appropriate Scopes
# Connect-MgGraph -NoWelcome -Scopes "Application.Read.All"

# Specify the enterprise app IDs you want to export
$all_enterprise_apps = Get-MgServicePrincipal | select -Property Id

# Initialize an array to store the results
$results = @()

foreach ($Id in $all_enterprise_apps) {
    $app = Get-MgServicePrincipal -ServicePrincipalId $Id.Id
    $users = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $Id.Id -all

    # Extract relevant information (customize as needed)
    $appInfo = @{
        AppName = $app.DisplayName
        Owners = $app.Owners -join ", "
        Users = $users -join ", "
    }

    $results += New-Object PSObject -Property $appInfo
}

# Write-Host $results
# Export results to a CSV file
$results | Export-Csv -Path "EnterpriseAppsInfo.csv" -NoTypeInformation