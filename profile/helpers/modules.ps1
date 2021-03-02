function Initialize-Module ([string]$Name, [string]$RequiredVersion, [bool]$Prerelease, [string]$Repository) {
	$EffectiveRequiredVersion = $Prerelease ? "${RequiredVersion}-pre" : "$RequiredVersion"
	Write-Debug "Initialize $Name | check installed version ($EffectiveRequiredVersion, $Repository)"
	$Params = @{
		Name = $Name
		RequiredVersion = $EffectiveRequiredVersion
		AllowPrerelease = $Prerelease
	}
	$InstalledModule = Get-InstalledModule @Params -ErrorAction SilentlyContinue
	if ($null -eq $InstalledModule) {
		# TODO: Find module first
		Write-Debug "Initialize $Name | installing module"
		Install-Module @Params -Repository $Repository
		$InstalledModule = Get-InstalledModule @Params -ErrorAction SilentlyContinue
		Write-Debug "Initialize $Name | done"
	}
	else { Write-Debug "Initialize $Name | module already installed" }
	Write-Debug "Initialize $Name | ok"

	Write-Debug "Initialize $Name | importing module"
	Import-Module -FullyQualifiedName @{ModuleName = $Name; ModuleVersion = $RequiredVersion}
	Write-Debug "Initialize $Name | done"
}