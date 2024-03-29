$DebugPreference = "SilentlyContinue"

$LastExitCodeBackup = $LASTEXITCODE

. (Join-Path $PSScriptRoot chocolatey-profile.ps1)
. (Join-Path $PSScriptRoot helpers.ps1)
. (Join-Path $PSScriptRoot prompt.ps1)
. (Join-Path $PSScriptRoot k8s-helpers.ps1)
. (Join-Path $PSScriptRoot psreadline.ps1)
. (Join-Path $PSScriptRoot posh-git.ps1)

$global:LASTEXITCODE = $LastExitCodeBackup
