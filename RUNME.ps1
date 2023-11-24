$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

$RootFolder = Get-Location
$WhiteLabelFolderPath = $RootFolder.Path + "\WhiteLabel"

if (!(Test-Path $WhiteLabelFolderPath)) {
    New-Item $WhiteLabelFolderPath -ItemType Directory
}

Set-Location $WhiteLabelFolderPath

$ContainerRegistryAndPackageManagerPath = "$WhiteLabelFolderPath\white-label.infrastructure.local-containers-and-packages"

if (!(Test-Path $ContainerRegistryAndPackageManagerPath)) {
    Start-Process -FilePath $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/{$ContainerRegistryAndPackageManagerPath}.git"
}

Set-Location $ContainerRegistryAndPackageManagerPath
Start-Process -FilePath $DockerExecutablePath -ArgumentList "compose", "up"


Set-Location $RootFolder
