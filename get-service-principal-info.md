# Get-M365ServicePrincipalInfo

PowerShell script to retrieve details about a Microsoft 365 / Azure AD service principal. Uses Microsoft Graph with **Application.Read.All** delegated scope—no admin consent required in most tenants.

---

## Prerequisites

- PowerShell 7+
- Microsoft.Graph PowerShell SDK

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

---

## Behavior Summary

- Connects to Microsoft Graph.
- Resolves service principal by display name, object ID, or app ID.
- Retrieves metadata, owners, credentials.
- Cross-references well-known AppId list from:
  https://raw.githubusercontent.com/Beercow/Azure-App-IDs/refs/heads/master/Azure_Application_IDs.csv
- Caches the CSV for 24 hours in `%LOCALAPPDATA%\M365Tools`.

---

## Output Fields

Returns a custom object (or JSON if `-OutputJson`) with fields including:

- `DisplayName`, `AppId`, `ObjectId`
- `AccountEnabled`, `CreatedDateTime`, `SignInAudience`
- `Tags`, `Owners`, `PasswordCreds`, `KeyCreds`
- `WellKnownAppId` (bool)
- `WellKnownAppName` (if matched)
- `Reference` (if matched)

---

## License