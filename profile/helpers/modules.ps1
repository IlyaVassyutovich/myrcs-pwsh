<#
Get-InstalledModule `
	-ModuleName PSReadLine `
	-RequiredVersion "2.2.0-beta4" `
	-AllowPrerelease

Install-Module `
	-ModuleName PSReadLine `
	-RequiredVersion "2.2.0-beta4" `
	-AllowPrerelease
#>


function Install-ModuleCore ([string]$Name, [string]$RequiredVersion, [string]$Prerelease, [string]$Repository) {
	Write-Debug "Install $Name | check installed version ($RequiredVersion, $Repository)"
	$Params = @{
		Name = $Name
		RequiredVersion = $RequiredVersion
		AllowPrerelease = ($null -ne $Prerelease)
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

function Initialize-ModuleCached ([string]$Name, [string]$RequiredVersion, [string]$Prerelease, [string]$Repository) {
	Write-Debug "Initialize $Name | verify cache"

	$FullModuleVersion = "$RequiredVersion-$Prerelease".TrimEnd("-")
	Write-Debug "Initialize $Name | full version is `"$FullModuleVersion`""

	$ExpectedCacheDir = Join-Path $ENV:TEMP "__pwsh-module-init-cache" "$Name@$Repository"
	$ExpectedCacheMarkerFilename = "$FullModuleVersion.marker"
	$ExpectedCacheMarkerFullname = Join-Path $ExpectedCacheDir $ExpectedCacheMarkerFilename
	if (-not (Test-Path $ExpectedCacheMarkerFullname)) {
		Write-Debug "Initialize $Name | cache marker not found"
		Install-ModuleCore $Name $FullModuleVersion $Prerelease $Repository
		New-Item $ExpectedCacheDir -ItemType Directory -Force | Out-Null
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
			Install-ModuleCore $Name $FullModuleVersion $Prerelease $Repository
			Write-Output "" | Out-File $ExpectedCacheMarkerFullname
		}
	}

	Write-Debug "Initialize $Name | importing module"
	Import-Module -FullyQualifiedName @{ModuleName = $Name; ModuleVersion = $RequiredVersion}
	Write-Debug "Initialize $Name | done"
}