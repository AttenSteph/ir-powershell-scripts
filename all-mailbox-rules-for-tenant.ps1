<#
.SYNOPSIS
    Write all mailbox rules from a M365 tenant, including hidden rules to .csv file. Defualts to all_mailbox_rules.csv if output file not specified.
.DESCRIPTION
    Requries Recently new version of Powershell & Exchange Online Powershell Module
    Windows Terminal recommended. https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US
    PS> winget install --id Microsoft.Powershell --source winget
    PS> Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.4.0
.PARAMETER UserPrincipalName
    privilegeduser@exampletenant.com - privileged account used to login with modern auth and fetch rules.
.PARAMETER OutFile
    \path\to\output\file.csv - if not specified .\all_mailbox_rules.csv
.EXAMPLE
    C:\PS> all-mailbox-rules-for-tenant.ps1 -UserPrincipalName privilegeduser@exampletenant.com -OutFile .\mailbox-rules.csv
.NOTES
    Author: Stephanie Sherwood
#>
param(
    [Parameter(Mandatory=$true)]
    [String]$UserPrincipalName,
    [String]$OutFile = "all_mailbox_rules.csv"
)

Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName

get-mailbox -resultsize unlimited  |
ForEach-Object {
    Write-Verbose "Checking $($_.guid)..." -Verbose
    $inboxrule = get-inboxrule -Mailbox $_.guid -includeHidden
    if ($inboxrule) {
        foreach($rule in $inboxrule){
        [PSCustomObject]@{
            UPN             = $_.UserPrincipalName
            DisplayName     = $_.DisplayName
            EmailAddresses  = $_.EmailAddresses
            Mailbox         = $_.alias
            Rulename        = $rule.name
            Identity        = $rule.identity
            Enabled         = $rule.enabled
            From            = $rule.from
            Rulepriority    = $rule.priority
            Ruledescription = $rule.description
            RedirectTo      = $rule.redirectto
            ForwardTo       = $rule.forwardto
        }
    }
    }
} | 
Export-csv $OutFile -NoTypeInformation
write-host "Mailbox rules written to $OutFile"
