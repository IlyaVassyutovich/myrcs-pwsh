Write-Debug "Trying to setup alias for `"gitextensions`""
$ErrorVariable = $null
$GitExCommand = Get-Command "gitex" `
	-ErrorVariable ErrorVariable `
	-ErrorAction SilentlyContinue
if ($null -eq $ErrorVariable -or 0 -eq $ErrorVariable.Count) {
	function private:Start-GitExtensions {
		& $GitExCommand.Source "browse"
	}
	New-Alias "ge" Start-GitExtensions
	Write-Debug "Alias for `"gitextesions`" set up"
}
else {
	Write-Warning "GitExtensions not found, alias not set"
	$ErrorVariable = $null
}

# TODO: Rework to better determine default branch from origin
# Maybe use some configuration file, like with .git/github.json?
function Get-DefaultBranch {
	Write-Debug "Determining default branch"
	$DefaultBranchCandidates = git --no-pager branch --no-color --format "%(refname:lstrip=2)" `
		| Where-Object { $_ -eq "master" -or $_ -eq "main" }
	
	Write-Debug "Got $($DefaultBranchCandidates.Count) candidate[-s]"
	Switch ($DefaultBranchCandidates.Count) {
		2	{ $DefaultBranch = "main" }
		1	{ $DefaultBranch = $DefaultBranchCandidates }
		Default { throw "Unable to determine default branch." }
	}

	Write-Debug "Selected `"$DefaultBranch`" as default"

	return $DefaultBranch
}

function Rebase-CurrentBranchOntoDefault {
	Write-Debug "Rebasing onto..."
	
	$CurrentBranch = git branch --show-current
	Write-Debug "Current branch is `"$CurrentBranch`""

	$DefaultBranch = Get-DefaultBranch
	Write-Debug "Default branch is `"$DefaultBranch`""

	$MergeBase = git merge-base $CurrentBranch $DefaultBranch
	Write-Debug "Merge base is `"$MergeBase`""

	git rebase `
		--onto $DefaultBranch `
		$MergeBase `
		$CurrentBranch
}

function Get-PullRequestRefForMergeCommit ([String] $PullRequestFullUri) {
	$GithubPRUriPattern = "^https:\/\/github\.com\/" + "(?<org>[a-zA-Z0-9-_]+)\/" + "(?<repo>[a-zA-Z0-9-_]+)\/" + "pull\/" + "(?<prid>\d+)\/?\??$"

	$Match = $PullRequestFullUri -match $GithubPRUriPattern
	if (-not $Match) {
		throw "Failed to match uri."
	}
	
	return $Matches.org + "/" + $Matches.repo + "#" + $Matches.prid
}

function Merge-WithDefaultBranch {
	[CmdletBinding()]
	param (
		[Parameter()]
		[String]
		$PullRequestFullUri
	)

	Write-Debug "Determining git status"
	$GitStatus = Get-GitStatus -Force
	if ($null -eq $GitStatus) {
		throw "Not in git repository."
	}
	Write-Debug "In git repo, continuing"

	$DefautlBranch = Get-DefaultBranch
	Write-Debug "Merging with `"$DefautlBranch`""

	Write-Debug "Determining current branch"
	$CurrentBranch = git branch --show-current
	Write-Debug "Got current branch — `"$CurrentBranch`""

	if ($CurrentBranch -eq $DefautlBranch) {
		throw "Can't merge into itself."
	}

	git checkout $DefautlBranch

	if ($null -ne $PullRequestFullUri) {
		git merge --no-ff --message "Merge $(Get-PullRequestRefForMergeCommit $PullRequestFullUri)" $CurrentBranch
	}
	else {
		git merge --edit --no-ff $CurrentBranch
	}
}
New-Alias "mwd" "Merge-WithDefaultBranch"
