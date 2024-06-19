# Incident Response PowerShell Scripts
Please check the individual .md files associated with each script for detailed information, or the script itself.
- all-mailbox-rules-for-tenant.ps1 - dumps all mailbox rules for a tenant with a focus on information needed to spot malicious rules
- all-mailbox-rules-for-user.ps1 - dumps all mailbox rules for a user with a focus on information needed to spot malicious rules
- export-enterprise-apps.ps1 - (BROKEN) exports enterprise apps with useful info
- get-user-creation-dates.ps1 - gets user creation dates to more easily spot accounts that have been created en masse. Those accounts are usually external user accounts.
- secure-malicious-entra-app.ps1 - MS Graph PowerShell SDK script to secure a malicious Entra app. Fixed. The one from MS is broken.