function Get-GitHubRepositoryUri {
	$GitStatus = Get-GitStatus -Force
	if ($null -EQ $GitStatus) {
		throw "Not in git repo."
	}

	$GitHubSettingsFilePath = Join-Path $GitStatus.GitDir "github.json"
	if (-not (Test-Path $GitHubSettingsFilePath -PathType Leaf)) {
		throw "GitHub settings not found at `"$GitHubSettingsFilePath`"."
	}

	$RepositoryUri = Get-Content $GitHubSettingsFilePath | ConvertFrom-Json | Select-Object -ExpandProperty repositoryUri
	if ($null -eq $RepositoryUri) {
		throw "Unable to get repository uri from settings."
	}

	return $RepositoryUri
}

function New-PullRequest() {
	$RepositoryUri = Get-GitHubRepositoryUri
	
	$NewPullRequestUri = "$($RepositoryUri)/compare/$($GitStatus.Branch)?expand=1"

	Start-Process $NewPullRequestUri
}
New-Alias npr "New-PullRequest"

function Open-GitHubRepository() {
	$RepositoryUri = Get-GitHubRepositoryUri

	Start-Process $RepositoryUri
}
New-Alias oghr "Open-GitHubRepository"