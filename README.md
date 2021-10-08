# RoutineChecks

This repo contains a PowerShell module for performing routine checks against various Azure resources via Pester.

> Requires Pester v5.3.0 or newer.

# Usage

```Powershell
Import-Module .\RoutineChecks.psm1

Invoke-RoutineChecks -SubscriptionName yoursubscription
```

# Current Checks

- API Management certificates expiry > 45 days
- App Gateway certificates expiry > 45 days
- App Service certificates expiry > 45 days
- VM disk encryption status = encrypted
- VM replicated status = protected and normal (where enabled)

More checks to come. PRs welcome.