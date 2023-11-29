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

Set-Location $WhiteLabelCommonProjectsFolder

# Add Service Meta Project

Set-Location $WhiteLabelCommonProjectsFolder
$ServiceMetaProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.ServiceMeta"

if (!(Test-Path $ServiceMetaProjectFolder)) {
    $Process = Start-Process -NoNewWindow -PassThru $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.ServiceMeta.git"
    $Process.WaitForExit()
}

Set-Location $ServiceMetaProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "install .\", "--force"
$Process.WaitForExit()

# Add Packages and Containers Project

Set-Location $WhiteLabelCommonProjectsFolder

$PackagesAndContainersProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.Projects.PackagesAndContainers"

if (!(Test-Path $PackagesAndContainersProjectFolder)) {
    $Process = Start-Process -NoNewWindow -PassThru $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.Projects.PackagesAndContainers.git"
    $Process.WaitForExit()
}

Set-Location $PackagesAndContainersProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "install .\", "--force"
$Process.WaitForExit()

# Add Shared Kernel Template

Set-Location $WhiteLabelCommonProjectsFolder
$SharedKernelProjectFolder = "$WhiteLabelCommonProjectsFolder\white-label.templates.SharedKernel"

if (!(Test-Path $SharedKernelProjectFolder)) {
    $Process = Start-Process -NoNewWindow -PassThru $GitExecutablePath -ArgumentList "clone", "https://github.com/bUKaneer/white-label.templates.SharedKernel.git"
    $Process.WaitForExit()
}

Set-Location $SharedKernelProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "new", "install .\", "--force"
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

# Write Output to Console

$ReadMe = @"
# Development Environment Information 

The following docker containers have been setup for this project: "

- Container Registry: http://localhost:$ContainerRegistryPort"
- Container Registry UI: http://localhost:$ContainerRegistryUserInterfacePort"
- Package Source UI: http://localhost:$PackageSourcePort"

To add a new HostedProject (Service) first create the Project using the following command:

`dotnet new whitelabel-service -o YourProjectPrefix.YourProjectName`

Once created:

`cd .\YourProjectPrefix.YourProjectName\'

Then run the following command to reference the Demo Projects from Aspire:"

Example (Change values as required):

`.\RUNME.ps1 -aspireProjectName "$AspireProject" -aspireSolutionFolder "$AspireProjectFolder" -serviceDefaultsPackage `"$ProjectName.Aspire.ServiceDefaults`" -packagesAndContainersSolutionFolder "$ProjectPackagesAndContainersFolder"`

"@

Set-Location $ProjectFolder 

New-Item -Path ".\README.md" -ItemType File
Set-Content -Path ".\README.md" $ReadMe

# Put User in Correct Folder to Run Demo Setup Script

Set-Location $DemoProjectFolder

Write-Host @"

*****************************************************************************

Please run the following command to reference the Demo Project from Aspire:"

`.\RUNME.ps1 -aspireProjectName "$AspireProject" -aspireSolutionFolder "$AspireProjectFolder" -serviceDefaultsPackage `"$ProjectName.Aspire.ServiceDefaults`" -packagesAndContainersSolutionFolder "$ProjectPackagesAndContainersFolder"`

*****************************************************************************

"@
