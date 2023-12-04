$PushPackagesFilePaths = [System.Collections.ArrayList]@()
$CurrentFolder = Get-Location

Get-ChildItem $CurrentFolder -recurse | Where-Object { $_.Name -eq "PushPackage.ps1" } | ForEach-Object {
    $PushPackagesFilePaths.Add($_.Directory)
}

$PushPackagesFilePaths | ForEach-Object {
    Set-Location $_
    & .\PushPackage.ps1
}