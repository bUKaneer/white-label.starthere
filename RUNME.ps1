param([String]$n = "WhiteLabel")
$ProjectName = $n

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"
$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

# Move outside this folder and set as Start/Home folder.
Set-Location "..\"

$StartFolder = Get-Location

Write-Host "StartFolder.Path: $StartFolder"

# Create Distributed Project Folder
$ProjectFolderPath = $StartFolder.Path + "\$projectName"

Write-Host "WhiteLabelFolderPath: $ProjectFolderPath"

if (!(Test-Path $ProjectFolderPath)) {
    New-Item $ProjectFolderPath -ItemType Directory
}

Set-Location $ProjectFolderPath

# Local Containers & Packages Setup

$ContainerRegistryAndPackageManagerPath = "$ProjectFolderPath\white-label.infrastructure.local-containers-and-packages"
Write-Host "ContainerRegistryAndPackageManagerPath: $ContainerRegistryAndPackageManagerPath"

if (!(Test-Path $ContainerRegistryAndPackageManagerPath)) {
    Start-Process -Wait -FilePath $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.infrastructure.local-containers-and-packages.git"
}

Set-Location $ContainerRegistryAndPackageManagerPath
Start-Process -FilePath $DockerExecutablePath -ArgumentList "compose", "up"

Start-Process -Wait $DotNetExecutablePath -ArgumentList "nuget", "add", "source", "http://localhost:19002/v3/index.json", "--name baget"

Set-Location $StartFolder

# Install Clean Architecture Template

Write-Host "Installing Template: Ardalis.CleanArchitecture.Template::9.0.0-preview2"

Start-Process -Wait $DotNetExecutablePath -ArgumentList "new", "install", "Ardalis.CleanArchitecture.Template::9.0.0-preview2"

# Scaffold Distributed System

$SystemRootFolder = "$StartFolder\System"
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

$AspireServiceDefaultsFolder = "$ProjectAspireFolder\$ProjectAspire.ServiceDefaults"
Write-Host "AspireServerDefaultsFolder: $AspireServiceDefaultsFolder"

# Pack and Push Service Defaults Project to Baget

Set-Location $AspireServiceDefaultsFolder

Start-Process -Wait $DotNetExecutablePath -ArgumentList "nuget", "pack", "--output nupkgs"

Start-Process -Wait $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectAspire.ServiceDefaults.1.0.0.nupkg", "-s http://localhost:19002/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"

# Back to Home

Set-Location $StartFolder










