Write-Debug "Trying to setup alias for `"terraform`""
$ErrorVariable = $null
$TerraformCommand = Get-Command "terraform" `
	-ErrorVariable ErrorVariable `
	-ErrorAction SilentlyContinue
if ($null -eq $ErrorVariable -or 0 -eq $ErrorVariable.Count) {
	New-Alias "tf" $TerraformCommand
	Write-Debug "Alias for `"terraform`" set up"
}
else {
	Write-Warning "Terraform not found, alias not set"
	$ErrorVariable = $null
}