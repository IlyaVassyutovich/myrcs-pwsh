function Install-ModuleCore ([string]$Name, [string]$RequiredVersion, [bool]$Prerelease, [string]$Repository) {
	$EffectiveRequiredVersion = $Prerelease ? "${RequiredVersion}-pre" : "$RequiredVersion"
	Write-Debug "Install $Name | check installed version ($EffectiveRequiredVersion, $Repository)"
	$Params = @{
		Name = $Name
		RequiredVersion = $EffectiveRequiredVersion
		AllowPrerelease = $Prerelease
	}
	$InstalledModule = Get-InstalledModule @Params -ErrorAction SilentlyContinue
	if ($null -eq $InstalledModule) {
		# TODO: Find module first
		Write-Debug "Install $Name | installing module"
		Install-Module @Params -Repository $Repository
		$InstalledModule = Get-InstalledModule @Params -ErrorAction SilentlyContinue
		Write-Debug "Install $Name | done"
	}
	else { Write-Debug "Install $Name | module already installed" }
	Write-Debug "Install $Name | ok"
}

function Initialize-Module ([string]$Name, [string]$RequiredVersion, [bool]$Prerelease, [string]$Repository) {
	Install-ModuleCore $Name $RequiredVersion $Prerelease $Repository

	Write-Debug "Initialize $Name | importing module"
	Import-Module -FullyQualifiedName @{ModuleName = $Name; ModuleVersion = $RequiredVersion}
	Write-Debug "Initialize $Name | done"
}

function Initialize-ModuleCached ([string]$Name, [string]$RequiredVersion, [bool]$Prerelease, [string]$Repository) {
	Write-Debug "Initialize $Name | verify cache"
	$ExpectedCacheDir = Join-Path $ENV:TEMP "__pwsh-module-init-cache" "$Name@$Repository"
	$ExpectedCacheMarkerFilename = "$($Prerelease ? "${RequiredVersion}-pre" : "$RequiredVersion").marker"
	$ExpectedCacheMarkerFullname = Join-Path $ExpectedCacheDir $ExpectedCacheMarkerFilename
	if (-not (Test-Path $ExpectedCacheMarkerFullname)) {
		Write-Debug "Initialize $Name | cache marker not found"
		Install-ModuleCore $Name $RequiredVersion $Prerelease $Repository
		New-Item $ExpectedCacheDir -ItemType Directory | Out-Null
		New-Item $ExpectedCacheMarkerFullname -ItemType File | Out-Null
		Write-Output "" | Out-File $ExpectedCacheMarkerFullname
	}
	else {
		Write-Debug "Initialize $Name | cache marker found"
		$CacheMarkerItem = Get-Item $ExpectedCacheMarkerFullname
		$CacheExpirationDateTime = $CacheMarkerItem.LastWriteTimeUtc.AddDays(5)
		if ($CacheExpirationDateTime -gt (Get-Date)) {
			Write-Debug "Initialize $Name | cache marker is up to date"
		}
		else {
			Write-Debug "Initialize $Name | cache marker is stale"
			Install-ModuleCore $Name $RequiredVersion $Prerelease $Repository
			Write-Output "" | Out-File $ExpectedCacheMarkerFullname
		}
	}

	Write-Debug "Initialize $Name | importing module"
	Import-Module -FullyQualifiedName @{ModuleName = $Name; ModuleVersion = $RequiredVersion}
	Write-Debug "Initialize $Name | done"
}