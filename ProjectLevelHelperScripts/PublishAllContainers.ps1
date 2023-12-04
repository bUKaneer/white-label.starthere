
$PublishContainerFilePaths = [System.Collections.ArrayList]@()
$CurrentFolder = Get-Location

Get-ChildItem $CurrentFolder -recurse | Where-Object { $_.Name -eq "PublishContainer.ps1" } | ForEach-Object {
    $PublishContainerFilePaths.Add($_.Directory)
}

$PublishContainerFilePaths | ForEach-Object {
    Set-Location $_
    & .\PublishContainer.ps1
}