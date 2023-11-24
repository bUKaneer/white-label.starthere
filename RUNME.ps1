$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

$RootFolder = Get-Location

Write-Host "RootFolder.Path: $RootFolder"

$WhiteLabelFolderPath = $RootFolder.Path + "\WhiteLabel"

Write-Host "WhiteLabelFolderPath: $WhiteLabelFolderPath"

if (!(Test-Path $WhiteLabelFolderPath)) {
    New-Item $WhiteLabelFolderPath -ItemType Directory
}

Set-Location $WhiteLabelFolderPath

$ContainerRegistryAndPackageManagerPath = "$WhiteLabelFolderPath\white-label.infrastructure.local-containers-and-packages"
Write-Host "ContainerRegistryAndPackageManagerPath: $ContainerRegistryAndPackageManagerPath"

if (!(Test-Path $ContainerRegistryAndPackageManagerPath)) {
    Start-Process -Wait -FilePath $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.infrastructure.local-containers-and-packages.git"
}

Set-Location $ContainerRegistryAndPackageManagerPath
Start-Process -Wait -FilePath $DockerExecutablePath -ArgumentList "compose", "up"


Set-Location $RootFolder
