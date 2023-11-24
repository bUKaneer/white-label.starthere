param([String]$n = "WhiteLabel")
$ProjectName = $n

$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"
$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

Set-Location "..\"

$RootFolder = Get-Location

Write-Host "RootFolder.Path: $RootFolder"

$ProjectFolderPath = $RootFolder.Path + "\$projectName"

Write-Host "WhiteLabelFolderPath: $ProjectFolderPath"

if (!(Test-Path $ProjectFolderPath)) {
    New-Item $ProjectFolderPath -ItemType Directory
}

Set-Location $ProjectFolderPath

$ContainerRegistryAndPackageManagerPath = "$ProjectFolderPath\white-label.infrastructure.local-containers-and-packages"
Write-Host "ContainerRegistryAndPackageManagerPath: $ContainerRegistryAndPackageManagerPath"

if (!(Test-Path $ContainerRegistryAndPackageManagerPath)) {
    Start-Process -Wait -FilePath $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.infrastructure.local-containers-and-packages.git"
}

Set-Location $ContainerRegistryAndPackageManagerPath
Start-Process -FilePath $DockerExecutablePath -ArgumentList "compose", "up"

Start-Process -Wait $DotNetExecutablePath -ArgumentList "nuget", "add", "source", "http://localhost:19002/v3/index.json", "--name baget"

Set-Location $RootFolder

Write-Host "Installing clean-arch template"

Start-Process -Wait $DotNetExecutablePath -ArgumentList "new", "install", "Ardalis.CleanArchitecture.Template"

$SystemRootFolder = "$RootFolder\System"
Write-Host "SystemRootFolder: $SystemRootFolder"

if (!(Test-Path $SystemRootFolder)) {
    New-Item $SystemRootFolder -ItemType Directory
}

Set-Location $SystemRootFolder 

$ProjectAspire = "$ProjectName.Aspire"
$ProjectAspireFolder = "$SystemRootFolder\$ProjectAspire"
Write-Host "ProjectAspireFolder: $ProjectAspireFolder"

if (!(Test-Path $ProjectAspireFolder)) {
    Start-Process -Wait $DotNetExecutablePath -ArgumentList "new", "aspire", "-o $ProjectAspire"
}









