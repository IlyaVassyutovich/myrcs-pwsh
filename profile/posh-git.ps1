Initialize-ModuleCached `
	-Name "posh-git" `
	-RequiredVersion "1.0.0" `
	-Prerelease "beta5" `
	-Repository "PSGallery"

$GitPromptSettings.PathStatusSeparator = [string]::Empty