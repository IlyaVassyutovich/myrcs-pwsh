$DebugPreference = "SilentlyContinue"

$LastExitCodeBackup = $LASTEXITCODE

. (Join-Path $PSScriptRoot chocolatey-profile.ps1)
. (Join-Path $PSScriptRoot helpers.ps1)
. (Join-Path $PSScriptRoot prompt.ps1)
. (Join-Path $PSScriptRoot k8s-helpers.ps1)

$ModuleRepository = "agamemnon.ivh"

Write-Debug "Setup Mindbox env | check env"
$IsMindboxWorkStation = ${ENV:mindbox/isMindboxWorkStation}
Write-Debug "Setup Mindbox env | $IsMindboxWorkStation"
if ($IsMindboxWorkStation -eq $True) {
	Initialize-ModuleCached `
		-Name "myrcs-mindbox" `
		-RequiredVersion "1.1.1" `
		-Repository $ModuleRepository
}
Write-Debug "Setup Mindbox env | done"

. (Join-Path $PSScriptRoot psreadline.ps1)
. (Join-Path $PSScriptRoot posh-git.ps1)


$global:LASTEXITCODE = $LastExitCodeBackup
