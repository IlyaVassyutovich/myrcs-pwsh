Import root script into PowerShell `$Profile`

```powershell
. (Join-Path ${ENV:iv/rcs/pwsh} "profile" "profile.ps1")
```