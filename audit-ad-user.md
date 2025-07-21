# Active Directory User Privilege and Delegation Audit Script

## Purpose

This PowerShell script audits a specified Active Directory (AD) user account to identify:

- Membership in privileged groups (e.g., Domain Admins, Enterprise Admins)
- Delegated access rights via object ACLs
- Configurations for constrained or unconstrained delegation

The script is designed for incident response, security reviews, and privilege audits in Active Directory environments.

---

## Usage

Run the script in a PowerShell session with **Domain Admin** or equivalent privileges.  
PowerShell 5.1 is required.

```powershell
.\audit-ad-users.ps1 -TargetUser <SamAccountName>
```

### Parameters

| Parameter    | Description                     | Required |
|--------------|---------------------------------|----------|
| `-TargetUser` | The `SamAccountName` of the AD user to audit. | Yes |

---

## Actions Performed

### 1. Privileged Group Membership Audit

The script checks if the target user is a direct member of the following privileged groups:

| Group Name         | Impact |
|-------------------|--------|
| Domain Admins      | Full control of the domain. Total domain compromise if misused. |
| Enterprise Admins  | Full control of the forest. Cross-domain compromise risk. |
| Schema Admins      | Can modify AD schema. Dangerous and irreversible if abused. |
| Administrators     | Local admin on DCs. Can manage domain-wide settings. |
| Account Operators  | Manage user and group accounts. Possible privilege escalation vector. |
| Backup Operators   | Can back up/restore sensitive data. Data exfiltration risk. |
| Server Operators   | Manage server OS components. Potential privilege escalation. |
| Print Operators    | Manage printers on DCs. Possible lateral movement path. |

If the user is a member of any of these groups, the script displays:

- The group name (in **red**)
- The specific security implications (in **yellow**)

---

### 2. Delegated ACL Audit

The script inspects all AD objects for delegated ACLs where the target user has access. This identifies non-standard permissions that may lead to:

- Privilege escalation
- Lateral movement
- Domain persistence

Reference: [Lares Labs - Securing Active Directory via ACLs](https://labs.lares.com/securing-active-directory-via-acls/)

---

### 3. Delegation Configuration Audit

The script checks for delegation-related flags:

- **Constrained Delegation**  
  Lists specific services the account can delegate to.  
  Risk: Lateral movement if Kerberos tickets can be abused.

- **Unconstrained Delegation**  
  Full delegation rights. High risk of domain compromise.

Reference: [Microsoft Defender for Identity - Kerberos Delegation](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment-unconstrained-kerberos)

---

## Output

Results are saved to a CSV file named:

```
<SamAccountName>-AuditResults.csv
```

### CSV Columns

| User   | Category             | ObjectName | Details                      |
|---------|----------------------|------------|------------------------------|
| Username | PrivilegedGroup/DelegatedACL/ConstrainedDelegation/UnconstrainedDelegation | Group or Object Name | Details of rights |

---

## Example

```powershell
.\audit-ad-users.ps1 -TargetUser jdoe
```

Outputs `jdoe-AuditResults.csv` and prints real-time findings to the console.

---

## Security Considerations

- **Run this script in a secure environment.**
- **Limit access to the output file as it contains sensitive access information.**

---

## License

This script is provided AS-IS with no warranty. Use at your own risk.
