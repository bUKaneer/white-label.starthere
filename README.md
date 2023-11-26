# ASP.NET Aspire with Clean Architecture in 3 commands!

## First Command

Get the start here repo:

`git clone https://github.com/bUKaneer/white-label.starthere.git`

## Second Command

Run the RUNME script to setup the environment:

`.\RUNME.ps1 -n "WhiteLabel"`

## Third Command

Integrate the generated Service with Aspire. This is generated at the end of the first step for the Demo Service that is created.

When generating your own services you will need to run the script with parameters suitable for your new service.

`.\RUNME.ps1 -aspireProjectName "WhiteLabel.Aspire" -aspireSolutionFolder "C:\wl\WhiteLabel\WhiteLabel.Aspire" -serviceDefaultsPackage "WhiteLabel.Aspire.ServiceDefaults"`

## Required Software

To use the White Label eco-system you will need the following software installed.

- [.NET 8 SDK](https://dotnet.microsoft.com/en-us/download)
- [Docker](https://docs.docker.com/get-docker/)
- Aspire Workload 
  - `dotnet workload install aspire`
- [Powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3)
- [Git](https://git-scm.com/downloads)
