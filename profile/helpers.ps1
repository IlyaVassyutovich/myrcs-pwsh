. (Join-Path $PSScriptRoot helpers/github.ps1)
. (Join-Path $PSScriptRoot helpers/git.ps1)
. (Join-Path $PSScriptRoot helpers/k8s.ps1)

function Initialize-Module ([string]$Name, [string]$RequiredVersion, [bool]$Prerelease, [string]$Repository){
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

function Test-IsAdmin
{
	<#
		.SYNOPSIS
		Check if PowerShell run elevated (e.g. as admin or not)

		.DESCRIPTION
		This is a complete new approach to check if the Shell runs elevated or not.
		It runs on PowerShell and PowerShell Core, and it supports macOS or Linux as well.

		.EXAMPLE
		PS C:\> Test-IsAdmin

		.NOTES
		Rewritten function to support PowerShell Desktop and Core on Windows, macOS, and Linux
		Mostly used within other functions and in the personal PowerShell profiles.

		Version: 1.0.1

		GUID: a59bfa91-7206-4892-bc2a-acf666b35364

		Author: Joerg Hochwald

		Companyname: Alright IT GmbH

		Copyright: Copyright (c) 2019, Alright IT GmbH - All rights reserved.

		License: https://opensource.org/licenses/BSD-3-Clause

		Releasenotes:
		1.0.1 2019-05-09: Add some comments to the code
		1.0.0 2019-05-09: Initial Release of the rewritten function

		THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	 #>
	  
	[CmdletBinding(ConfirmImpact = 'None')]
	[OutputType([bool])]
	param ()
	  
	process
	{
		if ($PSVersionTable.PSEdition -ne "Core")
		{
			Write-Warning "Only PoSh-Core is supported"
			return
		}
  
		if ($PSVersionTable.Platform -eq "Unix")
		{
			if ((id -u) -eq 0)
			{
				return $true
			}
			else
			{
				return $false
			}
		}
		if ($PSVersionTable.Platform -eq "Win32NT")
		{
			# For PowerShell Core on Windows the same approach as with the Desktop work just fine
			# This is for future improvements :-)
			$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
			$CurrentPrincipal = [Security.Principal.WindowsPrincipal]$CurrentIdentity
			$AdministratorRole = [Security.Principal.WindowsBuiltInRole] "Administrator"
			return $CurrentPrincipal.IsInRole($AdministratorRole)
		}
		else
		{
			# Unable to figure it out!
			Write-Warning -Message "Unknown PowerShell platform `"$($PSVersionTable.Platform)`""
  
			return
		}
	}
}

function New-SymbolicLink ([string] $LinkValue, [string] $TargetPath)
{
	New-Item -ItemType SymbolicLink -Path $LinkValue -Value $TargetPath
}

function Get-BasePath ([string] $Path)
{
	Split-Path -Path $Path
}

# MVP
function Open-TotalCommander ()
{
	totalcmd /T /L=(Get-Location)
}

function Open-RemoteDesktopSession ([string] $Computer) {
	$FullScreenSwitch = "/f"
	$ComputerSelectionSwitch = "/v"
	& C:\Windows\system32\mstsc.exe `
		$FullScreenSwitch `
		$ComputerSelectionSwitch $Computer
}
New-Alias "rdp" Open-RemoteDesktopSession

function Invoke-LinqPadScript {

	param (
		[string]
		[Parameter(Mandatory = $true, Position = 0)]
		$ScriptName,

		[string[]]
		[Parameter(ValueFromRemainingArguments, Position = 1)]
		$Rest
	)

	if (-Not (Test-Path $ScriptName)) {
		throw "No script at `"$ScriptName`""
	}

	$LPRunBinary = "C:\Program Files\LINQPad6\LPRun6.exe"
	if (-Not (Test-Path $LPRunBinary)) {
		throw "LPRun not found at `"$LPRunBinary`""
	}

	& $LPRunBinary $ScriptName $Rest
}
New-Alias "lprun" Invoke-LinqPadScript