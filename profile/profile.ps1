$DebugPreference = "SilentlyContinue"

$LastExitCodeBackup = $LASTEXITCODE

Write-Debug "Setup Mindbox env | check env"
$IsMindboxWorkStation = ${ENV:mindbox/isMindboxWorkStation}
Write-Debug "Setup Mindbox env | $IsMindboxWorkStation"
if ($IsMindboxWorkStation -eq $True) {
	Write-Debug "Setup Mindbox env | setting up"
	# TODO: Implement module installation/checking
	$RequiredVersion = "0.1.1"
	$ev = $null
	Import-Module myrcs-mindbox `
		-RequiredVersion $RequiredVersion `
		-ErrorVariable ev `
		-ErrorAction "SilentlyContinue"
	if (-not $ev) {
		Write-Debug "Setup Mindbox env | module loaded ($RequiredVersion)"
	}
	else {
		Write-Error "Setup Mindbox env | module loading failed"
		Write-Error "$ev"
	}
}
Write-Debug "Setup Mindbox env | done"

. (Join-Path $PSScriptRoot chocolatey-profile.ps1)
. (Join-Path $PSScriptRoot helpers.ps1)
. (Join-Path $PSScriptRoot prompt.ps1)
. (Join-Path $PSScriptRoot k8s-helpers.ps1)

Initialize-Module `
	-Name "pwsh-start-process" `
	-RequiredVersion "0.1.0" -Prerelease $true `
	-Repository "agamemnon"

function Exit-CurrentSession { exit }
New-Alias $([char]4) Exit-CurrentSession

Import-Module posh-git
$GitPromptSettings.PathStatusSeparator = [string]::Empty

$global:LASTEXITCODE = $LastExitCodeBackup
