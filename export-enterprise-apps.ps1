# Import the Microsoft Graph PowerShell SDK module
# Import-Module Microsoft.Graph.PowerShell

# Connect to MS Graph with Appropriate Scopes
Connect-MgGraph -NoWelcome -Scopes "Application.Read.All"

# Specify the enterprise app IDs you want to export
$all_enterprise_apps = Get-MgServicePrincipal | select -Property Id

# Initialize an array to store the results
$results = @()

foreach ($Id in $all_enterprise_apps) {
    $app1 = Get-MgServicePrincipal -ServicePrincipalId $Id.Id
    $app2 = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $Id.Id -all

    # Extract relevant information (customize as needed)
    $appInfo = @{
        AppName = $app1.DisplayName -join ", "
        Id = $app1.Id -join ", "
        AppId = $app1.AppId -join ", "
        CreatedDateTime = $app2.CreatedDateTime -join ", "
        Users = $app2.PrincipalDisplayName -join ", "
    }

    $results += New-Object PSObject -Property $appInfo
}

# Write-Host $results
# Export results to a CSV file
$results | Export-Csv -Path "EnterpriseAppsInfo.csv" -NoTypeInformation