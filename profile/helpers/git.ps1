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