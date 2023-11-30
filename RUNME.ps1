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

$WhiteLabelCommonProjectsFolder = "$StartFolder\WhiteLabel.Template"

if (!(Test-Path $WhiteLabelCommonProjectsFolder)) {
    New-Item $WhiteLabelCommonProjectsFolder -ItemType Directory
}

# Add Service Meta Project

Set-Location $WhiteLabelCommonProjectsFolder
$ServiceMetaProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.ServiceMeta"

if (!(Test-Path $ServiceMetaProjectFolder)) {
    $Process = Start-Process -NoNewWindow -PassThru $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.ServiceMeta.git"
    $Process.WaitForExit()
}

Set-Location $ServiceMetaProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "install .\", ""
$Process.WaitForExit()

# Add Packages and Containers Project

Set-Location $WhiteLabelCommonProjectsFolder

$PackagesAndContainersProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.Projects.PackagesAndContainers"

if (!(Test-Path $PackagesAndContainersProjectFolder)) {
    $Process = Start-Process -NoNewWindow -PassThru $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.Projects.PackagesAndContainers.git"
    $Process.WaitForExit()
}

Set-Location $PackagesAndContainersProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "install .\", ""
$Process.WaitForExit()

# Add Shared Kernel Template

Set-Location $WhiteLabelCommonProjectsFolder
$SharedKernelTemplateProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.SharedKernel"

if (!(Test-Path $SharedKernelTemplateProjectFolder)) {
    $Process = Start-Process -NoNewWindow -PassThru $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.SharedKernel.git"
    $Process.WaitForExit()
}

Set-Location $SharedKernelTemplateProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "install .\", ""
$Process.WaitForExit()

# Create Aspire.HostedProjects Project Folder
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
    $Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "aspire", "-o $AspireProject" 
    $Process.WaitForExit()
}

Set-Location $AspireProjectFolder

$AspireServiceDefaultsFolder = "$AspireProjectFolder\$AspireProject.ServiceDefaults"

Set-Location $AspireServiceDefaultsFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "build" 
$Process.WaitForExit()

# Create Packages and Containers Project based on white-label.packagesandcontainers

Set-Location $ProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "whitelabel-packages-and-containers", "-o $ProjectName.PackagesAndContainers"  
$Process.WaitForExit()

$ProjectPackagesAndContainersFolder = "$ProjectFolder\$ProjectName.PackagesAndContainers"

Set-Location $ProjectPackagesAndContainersFolder

$ContainerRegistryPort = Get-InactiveTcpPort 10000 50000
$ContainerRegistryUserInterfacePort = Get-InactiveTcpPort 10000 50000
$PackageSourcePort = Get-InactiveTcpPort 10000 50000

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "run", $ProjectName, $ContainerRegistryPort, $ContainerRegistryUserInterfacePort, $PackageSourcePort  
$Process.WaitForExit()

# Create Sub-Projects Folder (A folder into which you can place all your supporting code, Service Solutions, Templates, Project bound for Nuget etc)

Set-Location $ProjectFolder

$SubProjectsFolder = "$ProjectFolder\$ProjectName.Projects"

if (!(Test-Path $SubProjectsFolder)) {
    New-Item $SubProjectsFolder -ItemType Directory
}

# Create SubProjects 

# Create Demo Project based on white-label.service template

Set-Location $SubProjectsFolder

$DemoProjectName = "$ProjectName.Sample.Demo";

$DemoProjectFolder = "$SubProjectsFolder\$DemoProjectName"

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "whitelabel-service", "-o $DemoProjectName"  
$Process.WaitForExit()

$DemoUserInterfaceProjectFolder = "$DemoProjectFolder\src\Application\UserInterface\$DemoProjectName.UserInterface\"

# Create Shared Kernel based on white-label.sharedkernel template

Set-Location $SubProjectsFolder

$SharedKernelProjectName = "$ProjectName.SharedKernel";

$SharedKernelProjectFolder = "$SubProjectsFolder\$SharedKernelProjectName"

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "whitelabel-sharedkernel", "-o $SharedKernelProjectName" 
$Process.WaitForExit()

# Copy Nuget File to Folders Where Needed 

$NugetConfigFilePath = "$ProjectPackagesAndContainersFolder\nuget.config"

Copy-Item -Path $NugetConfigFilePath -Destination "$DemoUserInterfaceProjectFolder"
Copy-Item -Path $NugetConfigFilePath -Destination "$DemoProjectFolder\src\Application\$DemoProjectName.WebApi\"
Copy-Item -Path $NugetConfigFilePath -Destination "$AspireProjectFolder\$ProjectName.Aspire.AppHost\"

# Pack and Push Service Defaults Project to Baget

Set-Location $AspireServiceDefaultsFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$AspireProject.ServiceDefaults.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

# Pack and Push Shared Kernel Project to Baget

Set-Location $SharedKernelProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$SharedKernelProjectName.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

# Save Config, Give Intructions to User and start Demo Project Creation.
Set-Location $ProjectFolder

$ProjectConfigFileFullPath = "$ProjectFolder\$ProjectName.setup.config.json"
$DemoProjectConfigFileFullPath = "$DemoProjectFolder\$ProjectName.config.json"

$ProjectProjectConfig = [pscustomobject]@{
    ProjectName                        = "$ProjectName"
    DotNetExecutablePath               = "$DotNetExecutablePath"
    GitExecutablePath                  = "$GitExecutablePath"
    WhiteLabelCommonProjectsFolder     = "$WhiteLabelCommonProjectsFolder"
    ServiceMetaProjectFolder           = "$ServiceMetaProjectFolder"
    PackagesAndContainersProjectFolder = "$PackagesAndContainersProjectFolder"
    SharedKernelTemplateProjectFolder  = "$SharedKernelProjectFolder"
    ProjectFolder                      = "$ProjectFolder"
    AspireProject                      = "$AspireProject"
    AspireProjectFolder                = "$AspireProjectFolder"
    AspireServiceDefaultsFolder        = "$AspireServiceDefaultsFolder"
    ProjectPackagesAndContainersFolder = "$ProjectPackagesAndContainersFolder"
    ContainerRegistryPort              = "$ContainerRegistryPort"
    ContainerRegistryUserInterfacePort = "$ContainerRegistryUserInterfacePort"
    PackageSourcePort                  = "$PackageSourcePort"
    SubProjectsFolder                  = "$SubProjectsFolder"
    DemoProjectName                    = "$DemoProjectName"
    DemoProjectFolder                  = "$DemoProjectName"
    DemoUserInterfaceProjectFolder     = "$DemoUserInterfaceProjectFolder"
    SharedKernelProjectName            = "$SharedKernelProjectName"
    SharedKernelProjectFolder          = "$SharedKernelProjectFolder"
    NugetConfigFilePath                = "$NugetConfigFilePath"
    ProjectConfigFileFullPath          = "$ProjectConfigFileFullPath"
    DemoProjectConfigFileFullPath      = "$DemoProjectConfigFileFullPath"
}

$ProjectConfigJson = $ProjectProjectConfig | ConvertTo-Json 

New-Item -Path "$ProjectConfigFileFullPath" -ItemType File
Set-Content -Path "$ProjectConfigFileFullPath" $ProjectConfigJson

$ReadMe = @"
# Development Environment Information 

The following docker containers have been setup for this project: "

- Container Registry: http://localhost:$ContainerRegistryPort"
- Container Registry UI: http://localhost:$ContainerRegistryUserInterfacePort"
- Package Source UI: http://localhost:$PackageSourcePort"

## Configuration Information 

The config file for this Cloud Native Applcation can be found here:

``$ProjectConfigFileFullPath``

The config file for the Demo Project can be found here:

``$DemoProjectConfigFileFullPath``

## Aspire AppHost Wire-up 

Use the following to replace the content of Program.cs in Aspire.AppHost folder.

```csharp
var builder = DistributedApplication.CreateBuilder(args);

var apiBackendForFrontEnd = builder.AddProject<Projects.WhiteLabel_Sample_Demo_WebApi>("website-api-backend-for-frontend")
.WithLaunchProfile("https");

var websiteFrontend = builder.AddProject<Projects.WhiteLabel_Sample_Demo_UserInterface>("website-frontend")
.WithLaunchProfile("https")
.WithReference(apiBackendForFrontEnd);

builder.Build().Run();
```

## Add additional Projects/Services

To add a new HostedProject (Service) first create the Project using the following command:

`dotnet new whitelabel-service -o YourProjectPrefix.YourProjectName`

Once created:

`cd .\YourProjectPrefix.YourProjectName\'

Then run the following command to reference the Demo Projects from Aspire:"

Example (Change values as required):

`.\RUNME.ps1 -projectNameBase "$projectName" -aspireProjectName "$AspireProject" -aspireSolutionFolder "$AspireProjectFolder" -serviceDefaultsPackage `"$ProjectName.Aspire.ServiceDefaults`" -packagesAndContainersSolutionFolder "$ProjectPackagesAndContainersFolder"`

"@

New-Item -Path ".\README.md" -ItemType File
Set-Content -Path ".\README.md" $ReadMe

# Create Demo Project Config File

Set-Location $DemoProjectFolder

$demoProjectConfig = [pscustomobject]@{
    projectNameBase                     = "$ProjectName"
    aspireProjectName                   = "$AspireProject"
    aspireSolutionFolder                = "$AspireProjectFolder"
    serviceDefaultsPackage              = "$ProjectName.Aspire.ServiceDefaults"
    packagesAndContainersSolutionFolder = "$ProjectPackagesAndContainersFolder"
}

$demoConfigJson = $demoProjectConfig | ConvertTo-Json

New-Item -Path "$DemoProjectConfigFileFullPath" -ItemType File
Set-Content -Path "$DemoProjectConfigFileFullPath" $demoConfigJson

# Put User in Correct Folder and Run Demo Setup Script

Set-Location $DemoProjectFolder

& .\RUNME.ps1 -projectNameBase "$ProjectName" -aspireProjectName "$AspireProject" -aspireSolutionFolder "$AspireProjectFolder" -serviceDefaultsPackage "$ProjectName.Aspire.ServiceDefaults" -packagesAndContainersSolutionFolder "$ProjectPackagesAndContainersFolder"`

<#

# FOR DEBUGGING PURPOSES

$key = Read-Host -Prompt "Setup $ProjectName Demo?"
if ($key -eq "y" || $key -eq "y") {

    & .\RUNME.ps1 -projectNameBase "$ProjectName" -aspireProjectName "$AspireProject" -aspireSolutionFolder "$AspireProjectFolder" -serviceDefaultsPackage "$ProjectName.Aspire.ServiceDefaults" -packagesAndContainersSolutionFolder "$ProjectPackagesAndContainersFolder"`

} 

exit 
#>