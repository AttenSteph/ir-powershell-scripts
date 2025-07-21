# Active Directory User Privilege and Delegation Audit Script
# Compatible with PowerShell 5.1

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetUser
)

Import-Module ActiveDirectory

$PrivilegedGroups = @(
    'Domain Admins',
    'Enterprise Admins',
    'Schema Admins',
    'Administrators',
    'Account Operators',
    'Backup Operators',
    'Server Operators',
    'Print Operators'
)

$GroupDescriptions = @{
    'Domain Admins'    = 'Full control of the entire domain. Compromise leads to total domain takeover.'
    'Enterprise Admins' = 'Full control of the forest. Can administer any domain within the forest.'
    'Schema Admins'     = 'Can modify the AD schema. Changes may impact the entire forest irreversibly.'
    'Administrators'    = 'Local admins on domain controllers and can manage domain settings.'
    'Account Operators' = 'Can manage user and group accounts, but not admins. Potential for privilege escalation.'
    'Backup Operators'  = 'Can back up and restore files, including sensitive data. Potential data exfiltration risk.'
    'Server Operators'  = 'Can log on locally and manage servers. Possible avenue for privilege escalation.'
    'Print Operators'   = 'Can manage printers on domain controllers. Often overlooked, but potential lateral movement vector.'
}

$SearchBase = (Get-ADDomain).DistinguishedName

try {
    $User = Get-ADUser -Identity $TargetUser -Properties MemberOf, DistinguishedName, SID
} catch {
    Write-Host "" -ForegroundColor Red
    Write-Host ("[ERROR] Could not find user: {0}" -f $TargetUser) -ForegroundColor Red
    exit 1
}

$AllResults = @()

$GroupCache = @{}

function Get-GroupNameCached {
    param(
        [string]$GroupDN
    )
    if (-not $GroupCache.ContainsKey($GroupDN)) {
        try {
            $GroupCache[$GroupDN] = (Get-ADGroup -Identity $GroupDN).Name
        } catch {
            Write-Host ("[ERROR] Could not resolve group: {0}" -f $GroupDN) -ForegroundColor Yellow
            $GroupCache[$GroupDN] = $GroupDN
        }
    }
    return $GroupCache[$GroupDN]
}

$UserName = $User.SamAccountName
$UserSID = $User.SID

$GroupResults = @()

if ($User.MemberOf) {
    foreach ($Group in $User.MemberOf) {
        $GroupName = Get-GroupNameCached -GroupDN $Group
        if ($PrivilegedGroups -contains $GroupName) {
            Write-Host ("[HIGH] {0} is a member of privileged group: {1}" -f $UserName, $GroupName) -ForegroundColor Red
            Write-Host ("[COMMENT] {0}" -f $GroupDescriptions[$GroupName])
            $GroupResults += [PSCustomObject]@{
                User = $UserName
                Category = 'PrivilegedGroup'
                ObjectName = $GroupName
                Details = 'Member'
            }
        }
    }
}

$ObjectsWithDelegation = @()

Get-ADObject -LDAPFilter "(nTSecurityDescriptor=*)" -Properties ntSecurityDescriptor | ForEach-Object {
    $acl = $_.ntSecurityDescriptor
    foreach ($ace in $acl.Access) {
        try {
            $aceSID = $ace.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value
            if ($aceSID -eq $UserSID.Value) {
                Write-Host ("[MEDIUM] Delegated ACL found for {0} on object: {1}" -f $UserName, $_.Name) -ForegroundColor Yellow
                Write-Host ("[INFO] {0} has delegated rights over {1}. Misuse could lead to privilege escalation." -f $UserName, $_.Name)
                Write-Host ("[INFO] Further auditing is needed if this is believed to be abused by the TA.")
                Write-Host ("[INFO] https://labs.lares.com/securing-active-directory-via-acls/")
                $ObjectsWithDelegation += [PSCustomObject]@{
                    User = $UserName
                    Category = 'DelegatedACL'
                    ObjectName = $_.Name
                    Details = "$($ace.ActiveDirectoryRights) - $($ace.AccessControlType)"
                }
            }
        } catch {
            Write-Host ("[ERROR] Could not translate IdentityReference for object: {0}" -f $_.Name) -ForegroundColor Yellow
        }
    }
}

$DelegationResults = @()
$DelegationProps = Get-ADUser -Identity $UserName -Properties msDS-AllowedToDelegateTo, UserAccountControl

if ($DelegationProps.'msDS-AllowedToDelegateTo') {
    foreach ($target in $DelegationProps.'msDS-AllowedToDelegateTo') {
        Write-Host ("[MEDIUM] Constrained delegation target found for {0}: {1}" -f $UserName, $target) -ForegroundColor Yellow
        Write-Host ("[INFO] {0} can delegate Kerberos tickets to {1}. This could be abused for lateral movement." -f $UserName, $target)
        Write-Host ("[INFO] https://learn.microsoft.com/en-us/defender-for-identity/security-assessment-unconstrained-kerberos")
        $DelegationResults += [PSCustomObject]@{
            User = $UserName
            Category = 'ConstrainedDelegation'
            ObjectName = $target
            Details = 'AllowedToDelegateTo'
        }
    }
}

if ($DelegationProps.UserAccountControl -band 0x80000) {
    Write-Host ("[HIGH] {0} is trusted for unconstrained delegation. This is a high-risk configuration that could lead to domain compromise." -f $UserName) -ForegroundColor Red
    Write-Host ("[INFO] https://learn.microsoft.com/en-us/defender-for-identity/security-assessment-unconstrained-kerberos")
    $DelegationResults += [PSCustomObject]@{
        User = $UserName
        Category = 'UnconstrainedDelegation'
        ObjectName = $UserName
        Details = 'TrustedForDelegation'
    }
}

$AllResults += $GroupResults + $ObjectsWithDelegation + $DelegationResults

$CsvPath = "$TargetUser-AuditResults.csv"

$AllResults | Export-Csv -Path $CsvPath -NoTypeInformation

Write-Host "\n[+] Audit complete. Results saved to $CsvPath." -ForegroundColor Green
