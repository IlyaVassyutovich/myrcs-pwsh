Write-Debug "Trying to setup alias for `"gitextensions`""
$ErrorVariable = $null
$GitExCommand = Get-Command "gitex" `
	-ErrorVariable ErrorVariable `
	-ErrorAction Continue
if ($null -eq $ErrorVariable -or 0 -eq $ErrorVariable.Count) {
	function private:Start-GitExtensions {
		& $GitExCommand.Source "browse"
	}
	New-Alias "ge" Start-GitExtensions
	Write-Debug "Alias for `"gitextesions`" set up"
}

# TODO: Rework to better determine default branch from origin
# Maybe use some configuration file, like with .git/github.json?
function Get-DefaultBranch {
	Write-Debug "Determining default branch"
	$DefaultBranchCandidates = git --no-pager branch --no-color --format "%(refname:lstrip=2)" `
		| Where-Object { $_ -eq "master" -or $_ -eq "main" }
	
	Write-Debug "Got $($DefaultBranchCandidates.Count) candidate[-s]"
	if ($DefaultBranchCandidates.Count -ne 1) {
		throw "Unable to determine default branch."
	}
	$DefaultBranch = $DefaultBranchCandidates
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

function Merge-WithDefaultBranch {
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

	git merge --edit --no-ff $CurrentBranch
}