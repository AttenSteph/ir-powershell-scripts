<#
.SYNOPSIS
    Export all mailbox rules from a single M365 mailbox, including hidden rules, to .csv file. Defualts to .\<email_address>_all_mailbox_rules.csv if output file not specified.
.DESCRIPTION
    Requries Recently new version of Powershell & Exchange Online Powershell Module
    Windows Terminal recommended. https://apps.microsoft.com/detail/9n0dx20hk701?activetab=pivot%3Aoverviewtab&hl=en-us&gl=US
    PS> winget install --id Microsoft.Powershell --source winget
    PS> Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.4.0
.PARAMETER UserPrincipalName
    privilegeduser@exampletenant.com - privileged account used to login with modern auth and fetch rules.
.PARAMETER OutFile
    \path\to\output\file.csv - if not specified .\<email_address>_all_mailbox_rules.csv
.EXAMPLE
    C:\PS> all-mailbox-rules-for-user.ps1 -UserPrincipalName privilegeduser@exampletenant.com -OutFile .\mailbox-rules.csv
.NOTES
    Author: Stephanie Sherwood
#>
param(
    [Parameter(Mandatory=$true)]
    [String]$UserPrincipalName,
    [String]$Email,
    [String]$OutFile = "$($Email)_all_mailbox_rules.csv"
)

Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName

get-mailbox -resultsize unlimited -Identity $Email  |
ForEach-Object {
Write-Verbose "Checking $($Email)..." -Verbose
$inboxrule = get-inboxrule -Mailbox $_.alias -includeHidden
if ($inboxrule) {
    foreach($rule in $inboxrule){
    [PSCustomObject]@{
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
}} | Export-csv $OutFile -NoTypeInformation
write-host $inboxrule | Select-Object Name,Identity,Enabled,From,Description,RedirectTo,ForwardTo | Format-List
write-host "Mailbox rules written to $OutFile"
