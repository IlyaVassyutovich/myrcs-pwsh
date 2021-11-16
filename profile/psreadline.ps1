Initialize-ModuleCached `
	-Name "PSReadLine" `
	-RequiredVersion "2.2.0" `
	-Prerelease "beta4" `
	-Repository "PSGallery"

Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function DeleteCharOrExit