<#
.SYNOPSIS
    Retrieves detailed information about an Azure AD / Microsoft 365 service principal

.DESCRIPTION
    * Connects to Microsoft Graph using **Application.Read.All** (delegated) – usually pre‑consented for Microsoft Graph CLI/PowerShell.
    * Accepts DisplayName, ObjectId (GUID), or AppId (GUID).
    * Cross‑references the service‑principal AppId with the public list of well‑known Azure application IDs located at:
        https://raw.githubusercontent.com/Beercow/Azure-App-IDs/refs/heads/master/Azure_Application_IDs.csv
      The CSV contains three relevant columns:
        - **Application IDs**   (one or many IDs separated by ';')
        - **Application Name**  (friendly name)
        - **Reference**         (URL or note)
    * The CSV is cached under %LOCALAPPDATA%\M365Tools for 24 hours unless `-ForceRefresh` is specified.
    * Adds three properties to the output object:
        - `WellKnownAppId`   : [bool]  True if `$servicePrincipal.AppId` found in any CSV row
        - `WellKnownAppName` : [string] Matching row's Application Name, otherwise `$null`
        - `Reference`        : [string] Matching row's Reference, otherwise `$null`

.PARAMETER Search
    DisplayName, ObjectId, or AppId of the target service principal.

.PARAMETER OutputJson
    Emit JSON instead of a PSCustomObject.

.PARAMETER ForceRefresh
    Force re‑download of the well‑known AppId CSV, bypassing the cache.

.EXAMPLE
    .\get-service-principal-info.ps1 -Search "Azure DevOps"

.EXAMPLE
    .\get-service-principal-info.ps1 -Search "<appId>" -OutputJson -ForceRefresh | Out‑File sp.json

.NOTES
    * For app‑role assignment details, reconnect with:
        Connect-MgGraph -Scopes "Application.Read.All","AppRoleAssignment.ReadWrite.All"
      – requires one‑time admin consent.
    * Requires Microsoft.Graph PowerShell SDK.
    * PowerShell 7+ recommended.
#>
param(
    [Parameter(Mandatory)]
    [string]$Search,

    [switch]$OutputJson,

    [switch]$ForceRefresh
)

# region Dependencies
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    throw "Microsoft Graph PowerShell SDK is not installed. Run 'Install-Module Microsoft.Graph -Scope CurrentUser'."
}
# endregion

# region Graph Connection
$scopes = 'Application.Read.All'
Connect-MgGraph -Scopes $scopes -NoWelcome -ErrorAction Stop | Out-Null
# endregion

function Resolve-ServicePrincipal {
    param([string]$Query)

    if ($Query -match '^[0-9a-fA-F-]{36}$') {
        # Try as ObjectId first
        $sp = Get-MgServicePrincipal -ServicePrincipalId $Query -ErrorAction SilentlyContinue
        if (-not $sp) { $sp = Get-MgServicePrincipal -Filter "appId eq '$Query'" }
    }
    else {
        $escaped = $Query.Replace("'", "''")
        $sp = Get-MgServicePrincipal -Filter "displayName eq '$escaped'" -ErrorAction SilentlyContinue
        if (-not $sp) { $sp = Get-MgServicePrincipal -Filter "startswith(displayName,'$escaped')" }
    }
    return $sp
}

# Resolve SP
$servicePrincipal = Resolve-ServicePrincipal -Query $Search
if (-not $servicePrincipal) { throw "Service principal '$Search' not found." }

# region Owners & Credentials
$owners = Get-MgServicePrincipalOwner -ServicePrincipalId $servicePrincipal.Id -All -ErrorAction SilentlyContinue |
          Select-Object Id, DisplayName, UserPrincipalName
$pwdCreds = $servicePrincipal.PasswordCredentials | Select-Object CustomKeyIdentifier, StartDateTime, EndDateTime, Hint
$keyCreds = $servicePrincipal.KeyCredentials      | Select-Object KeyId, Type, Usage, StartDateTime, EndDateTime
# endregion

# region Well‑known AppId lookup with caching
$csvUri   = 'https://raw.githubusercontent.com/Beercow/Azure-App-IDs/refs/heads/master/Azure_Application_IDs.csv'
$cacheDir = Join-Path $env:LOCALAPPDATA 'M365Tools'
$cacheCsv = Join-Path $cacheDir 'Azure_Application_IDs.csv'
$cacheTtlHours = 24

if ($ForceRefresh -or -not (Test-Path $cacheCsv) -or (((Get-Date) - (Get-Item $cacheCsv).LastWriteTime).TotalHours -ge $cacheTtlHours)) {
    if (-not (Test-Path $cacheDir)) { New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null }
    Write-Verbose "Downloading Azure well‑known AppId list …"
    Invoke-WebRequest -Uri $csvUri -OutFile $cacheCsv -UseBasicParsing -ErrorAction Stop
}

$csvData = Import-Csv -Path $cacheCsv

# The 'Application IDs' column may contain multiple IDs separated by ';'
$match = $csvData | Where-Object { ($_.'Application IDs' -split ';') -contains $servicePrincipal.AppId }

$wellKnownAppId   = [bool]$match
$wellKnownAppName = if ($wellKnownAppId) { $match.'Application Name' } else { $null }
$reference        = if ($wellKnownAppId) { $match.Reference }        else { $null }
# endregion

# region Result Assembly
$result = [pscustomobject]@{
    DisplayName      = $servicePrincipal.DisplayName
    ObjectId         = $servicePrincipal.Id
    AppId            = $servicePrincipal.AppId
    AccountEnabled   = $servicePrincipal.AccountEnabled
    SignInAudience   = $servicePrincipal.SignInAudience
    CreatedDateTime  = $servicePrincipal.CreatedDateTime
    Tags             = ($servicePrincipal.Tags -join ', ')
    Owners           = $owners
    PasswordCreds    = $pwdCreds
    KeyCreds         = $keyCreds
    WellKnownAppId   = $wellKnownAppId
    WellKnownAppName = $wellKnownAppName
    Reference        = $reference
}
# endregion

if ($OutputJson) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result
}
