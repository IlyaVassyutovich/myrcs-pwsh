Write-Debug "Trying to setup alias for `"terraform`""
$ErrorVariable = $null
$TerraformCommand = Get-Command "terraform" `
	-ErrorVariable ErrorVariable `
	-ErrorAction Continue
if ($null -eq $ErrorVariable -or 0 -eq $ErrorVariable.Count) {
	New-Alias "tf" $TerraformCommand
	Write-Debug "Alias for `"terraform`" set up"
}