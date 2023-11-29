param([String]$n = "WhiteLabel")
$ProjectName = $n

#
# Credit to: https://codeandkeep.com/PowerShell-Tcp-Port-Finder/
# For Get-ActiveTcpPort and  Get-InactiveTcpPort
#

Function Get-ActiveTcpPort {
    # Use a hash set to avoid duplicates
    $portList = New-Object -TypeName Collections.Generic.HashSet[uint16]

    $properties = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()

    $listener = $properties.GetActiveTcpListeners()
    $active = $properties.GetActiveTcpConnections()

    foreach ($serverPort in $listener) {
        [void]$portList.Add($serverPort.Port)
    }
    foreach ($clientPort in $active) {
        [void]$portList.Add($clientPort.LocalEndPoint.Port)
    }

    return $portList
}

Function Get-InactiveTcpPort {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [uint16]$Start = 1024,

        [Parameter(Position = 1)]
        [uint16]$End = 5000
    )
    $attempts = 100
    $counter = 0

    $activePorts = Get-ActiveTcpPort

    while ($counter -lt $attempts) {
        $counter++
        $port = Get-Random -Minimum ($Start -as [int]) -Maximum ($End -as [int])

        if ($port -notin $activePorts) {
            return $port
        }
    }
    $emsg = [string]::Format(
        'Unable to find available TCP Port. Range: {0}, Attempts: [{1}]',
        "[$Start - $End]",
        $attempts
    )
    throw $emsg
}


# Welcome 
Clear-Host

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"
$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"

# Move outside this folder and set as Start/Home folder.
Set-Location "..\"

$StartFolder = Get-Location

$WhiteLabelCommonProjectsFolder = "$StartFolder\WhiteLabel.Common"

if (!(Test-Path $WhiteLabelCommonProjectsFolder)) {
    New-Item $WhiteLabelCommonProjectsFolder -ItemType Directory
}

Set-Location $WhiteLabelCommonProjectsFolder

# Add Service Meta Project

Set-Location $WhiteLabelCommonProjectsFolder
$ServiceMetaProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.ServiceMeta"

if (!(Test-Path $ServiceMetaProjectFolder)) {
    Start-Process -NoNewWindow -Wait $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.ServiceMeta.git"
}

Set-Location $ServiceMetaProjectFolder

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "new", "install .\"

# Add Packages and Containers Project

Set-Location $WhiteLabelCommonProjectsFolder

$PackagesAndContainersProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.Projects.PackagesAndContainers"

if (!(Test-Path $PackagesAndContainersProjectFolder)) {
    Start-Process -NoNewWindow -Wait $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.Projects.PackagesAndContainers.git"
}

Set-Location $PackagesAndContainersProjectFolder

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "new", "install .\"

# Create Distributed Project Folder
$ProjectFolder = "$StartFolder\$ProjectName"

if (!(Test-Path $ProjectFolder)) {
    New-Item $ProjectFolder -ItemType Directory
}

# Scaffold Distributed System

Set-Location $ProjectFolder 

# Setup Aspire Host

$AspireProject = "$ProjectName.Aspire"
$AspireProjectFolder = "$ProjectFolder\$AspireProject"

if (!(Test-Path $AspireProjectFolder)) {
    Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "new", "aspire", "-o $AspireProject"
}

Set-Location $AspireProjectFolder

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "build"

$AspireServiceDefaultsFolder = "$AspireProjectFolder\$AspireProject.ServiceDefaults"

# Create Sub-Projects Folder (A folder into which you can place all your supporting code, Service Solutions, Templates, Project bound for Nuget etc)

Set-Location $ProjectFolder
$SubProjectsFolder = "$ProjectFolder\$ProjectName.Projects"

if (!(Test-Path $SubProjectsFolder)) {
    New-Item $SubProjectsFolder -ItemType Directory
}

# Create SubProjects (Can be AppHosted Services or other Solutions)

# Create Packages and Containers Project based on white-label.packagesandcontainers

Set-Location $SubProjectsFolder

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "new", "whitelabel-packages-and-containers", "-o $ProjectName.PackagesAndContainers"

$SubProjectPackagesAndContainersFolder = "$SubProjectsFolder\$ProjectName.PackagesAndContainers"

Set-Location $SubProjectPackagesAndContainersFolder

$ContainerRegistryPort = Get-InactiveTcpPort 10000 50000
$ContainerRegistryUserInterfacePort = Get-InactiveTcpPort 10000 50000
$PackageSourcePort = Get-InactiveTcpPort 10000 50000

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "run", $ProjectName, $ContainerRegistryPort, $ContainerRegistryUserInterfacePort, $PackageSourcePort

# Create Demo Project based on white-label.service template

Set-Location $SubProjectsFolder

$DemoProjectName = "$ProjectName.Sample.Demo";

$DemoProjectFolder = "$SubProjectsFolder\$DemoProjectName"

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "new", "whitelabel-service", "-o $DemoProjectName"

# Pack and Push Service Defaults Project to Baget

Set-Location $AspireServiceDefaultsFolder

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"

Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$AspireProject.ServiceDefaults.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"

# Copy Nuget File to Folders Where Needed 

$NugetConfigFilePath = "$SubProjectPackagesAndContainersFolder\nuget.config"

Copy-Item -Path $NugetConfigFilePath -Destination "$DemoProjectFolder\src\Application\UserInterface\$DemoProjectName.UserInterface\"
Copy-Item -Path $NugetConfigFilePath -Destination "$DemoProjectFolder\src\Application\$DemoProjectName.WebApi\"
Copy-Item -Path $NugetConfigFilePath -Destination "$AspireProjectFolder\$ProjectName.Aspire.AppHost\"
                                                       
# Write Output to Console

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "==========================================================================="
Write-Host "The following docker containers have been setup for this project: "
Write-Host ""
Write-Host "  Container Registry: http://localhost:$ContainerRegistryPort"
Write-Host "  Container Registry UI: http://localhost:$ContainerRegistryUserInterfacePort"
Write-Host "  Package Source UI: http://localhost:$PackageSourcePort"
Write-Host ""
Write-Host "==========================================================================="
Write-Host "Please run the following command:"
Write-Host ""
Write-Host ".\RUNME.ps1 -aspireProjectName `"$AspireProject`" -aspireSolutionFolder `"$AspireProjectFolder`" -serviceDefaultsPackage `"$ProjectName.Aspire.ServiceDefaults`" -packagesAndContainersSolutionFolder `"$SubProjectPackagesAndContainersFolder`""
Write-Host ""
Write-Host "==========================================================================="
#
# Put User in Correct Folder to Run Demo Setup Script

Set-Location $DemoProjectFolder




