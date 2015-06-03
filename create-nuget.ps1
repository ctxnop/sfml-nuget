New-Item -ItemType Directory -Force -Path repository
cd repository
Get-ChildItem "../" -Filter *.autopkg | `
Foreach-Object{
	Write-NuGetPackage ..\$_
}
Remove-Item *.symbols.*
cd ..
pause