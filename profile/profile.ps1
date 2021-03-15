$DebugPreference = "SilentlyContinue"

$LastExitCodeBackup = $LASTEXITCODE

. (Join-Path $PSScriptRoot chocolatey-profile.ps1)
. (Join-Path $PSScriptRoot helpers.ps1)
. (Join-Path $PSScriptRoot prompt.ps1)
. (Join-Path $PSScriptRoot k8s-helpers.ps1)

$ModuleRepository = "agamemnon.ivh"

Initialize-ModuleCached `
	-Name "pwsh-start-process" `
	-RequiredVersion "0.1.0" -Prerelease $true `
	-Repository $ModuleRepository


Write-Debug "Setup Mindbox env | check env"
$IsMindboxWorkStation = ${ENV:mindbox/isMindboxWorkStation}
Write-Debug "Setup Mindbox env | $IsMindboxWorkStation"
if ($IsMindboxWorkStation -eq $True) {
	Initialize-ModuleCached `
		-Name "myrcs-mindbox" `
		-RequiredVersion "0.2.2" `
		-Prerelease $False `
		-Repository $ModuleRepository
}
Write-Debug "Setup Mindbox env | done"


function Exit-CurrentSession { exit }
New-Alias $([char]4) Exit-CurrentSession

Import-Module posh-git
$GitPromptSettings.PathStatusSeparator = [string]::Empty

$global:LASTEXITCODE = $LastExitCodeBackup
