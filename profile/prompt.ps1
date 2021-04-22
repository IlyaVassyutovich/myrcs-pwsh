function Update-WindowTitle {
	$GitStatus = Get-GitStatus -Force
	if ($GitStatus) {
		$NewTitleCandidate = "git: $($GitStatus.RepoName)"
	}
	else {
		$NewTitleCandidate = "pwsh"
	}

	if ($global:__LastSetTitle -ne $NewTitleCandidate) {
		Write-Debug "Updating window title"
		$Host.UI.RawUI.WindowTitle = $NewTitleCandidate
		$global:__LastSetTitle = $NewTitleCandidate
	}
}

function Prompt {
	$ExitCodeBackup = $global:LASTEXITCODE
	$TimeString = Get-Date -Format "HH:MM:ss"
	$CurrentLocation = $executionContext.SessionState.Path.CurrentLocation
	$RolePrompt = if (Test-IsAdmin) { "#" } else { "$" }

	$GitStatus = Get-GitStatus -Force
	if ($GitStatus) {
		$VcsPrompt = "─$(Write-VcsStatus)"
	}
	else {
		$VcsPrompt = ""
	}

	Update-WindowTitle

	$global:LASTEXITCODE = $ExitCodeBackup

	return "┬─[$TimeString]─[$CurrentLocation]$VcsPrompt$([System.Environment]::NewLine)╰─>$($RolePrompt * ($nestedPromptLevel + 1)) ";
}
