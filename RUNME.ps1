param([String]$n = "WhiteLabel")
$ProjectName = $n

# Welcome 
Clear-Host

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"
$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

# Move outside this folder and set as Start/Home folder.
Set-Location "..\"

$StartFolder = Get-Location

$WhiteLabelCommonProjectsFolder = "$StartFolder\WhiteLabel.Common"

if (!(Test-Path $WhiteLabelCommonProjectsFolder)) {
    New-Item $WhiteLabelCommonProjectsFolder -ItemType Directory
}

Set-Location $WhiteLabelCommonProjectsFolder

# Local Containers & Packages Setup

$ContainerRegistryAndPackageManagerFolder = "$WhiteLabelCommonProjectsFolder\white-label.infrastructure.local-containers-and-packages"

if (!(Test-Path $ContainerRegistryAndPackageManagerFolder)) {
    Start-Process -Wait -FilePath $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.infrastructure.local-containers-and-packages.git"
}

Set-Location $ContainerRegistryAndPackageManagerFolder

Start-Process -FilePath $DockerExecutablePath -ArgumentList "compose", "up"
#Start-Process -Wait $DotNetExecutablePath -ArgumentList "nuget", "add", "source", "http://localhost:19002/v3/index.json", "--name baget.local"

Set-Location $StartFolder

# Install Clean Architecture Template

Start-Process -Wait $DotNetExecutablePath -ArgumentList "new", "install", "Ardalis.CleanArchitecture.Template::9.0.0-preview2"

# Create Distributed Project Folder
$ProjectFolder = "$StartFolder\$projectName"
Write-Host "ProjectFolderPath: $ProjectFolder"

if (!(Test-Path $ProjectFolder)) {
    New-Item $ProjectFolder -ItemType Directory
}

# Scaffold Distributed System

Set-Location $ProjectFolder 

$AspireProject = "$ProjectName.Aspire"
$AspireProjectFolder = "$ProjectFolder\$AspireProject"

if (!(Test-Path $AspireProjectFolder)) {
    Start-Process -Wait $DotNetExecutablePath -ArgumentList "new", "aspire", "-o $AspireProject"
}

$AspireServiceDefaultsFolder = "$AspireProjectFolder\$AspireProject.ServiceDefaults"

# Pack and Push Service Defaults Project to Baget

Set-Location $AspireServiceDefaultsFolder

Start-Process -Wait $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
Start-Process -Wait $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$AspireProject.ServiceDefaults.1.0.0.nupkg", "-s http://localhost:19002/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"

# Back to Home

Set-Location $StartFolder










