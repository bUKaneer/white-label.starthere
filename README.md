# ASP.NET Aspire Cloud Native Applications

This project provides tooling to make getting up and running in Aspire as quickly and cleanly as possible.

## Required Software

To use the White Label eco-system you will need the following software installed.

- [.NET 8 SDK](https://dotnet.microsoft.com/en-us/download)
- [Docker](https://docs.docker.com/get-docker/)
- Aspire Workload
  - `dotnet workload update`
  - `dotnet workload install aspire`
- [Powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3)
- [Git](https://git-scm.com/downloads)

## Get Started

### Clone the Start Here repository

`git clone https://github.com/bUKaneer/white-label.starthere.git`

### Run the RUNME script to setup the environment

`.\RUNME.ps1 -n "WhiteLabel"`

## What is the White Label project

It tries to solve the following problems.

- Q: Where should I store my App Hosted Projects and Solutions?
  - A: The White Label system is a collection of `dotnet new` templates and `PowerShell` scripts so you can store them any way you prefer with a little
  tinkering. However a sensible default Solution/Project layout has been chosen to
  all maximum flexibility regards source control.
- Q: How should I deal with source control?
  - A: The default solution/project layout allows for multiple "levels" of git.
    - Easy: `git init` at the top level folder and everthing is in one git repository.
    - Medium: `git init` at Aspire Solution/PackageAndContainers/AspireProjects folders, you have three repositorys with all the big pieces in.
    - Hard: 'git init' for the Aspire Solution, PackagesAndContainers and then at Service solution (Individual Aspire.Projects) level too. This will give you n+2 repositories where n is the number of Service solutions.
- Q: How can I reliably create a distributed cloud native development environment?
  - A: Use this tool to generate a "Development Environment per Distributed System" for thats what it does running the `.\RUNME.ps1` from the `starthere` folder. Each time you do a new clean encironment will be created with a bootstrapped cloud native system ready to spring to life.
- Q: Where should my containers & packages live?
  - A: One of the templates provided by White Label is a PackagesAndContainer project. This is installed and run during installation and is responsible for create a Docker Composition with a unique name (YourProject) and a unique set of ports for a local nuget (Baget) package manager and a local Container Registry. Both include a web interface and can be reached via Docker Desktop. Your containers and packages will be stored locally on disk isolated from each other. Your whole project live together isolated in it owm unqiue (but automated) environment.
- Q: How do I stay Clean in all of this?
  - A: Keep using the tools, im dog fooding this solution and enjoying every second as I code.

## What next

Fire up your terminal and `.\RUNME.ps1`.

## Supporting Repositories

This project makes use of several other templates and scripts, each of which may be used independently to fulfil a separate purpose.

The "Start here" project leverages their functionality together to provide a unique working environment automatically but each can be modified as required.

### Service (Meta)

The [Service (Meta) Project](https://github.com/bUKaneer/white-label.templates.ServiceMeta) provides a `dotnet new` template and serves as a default "Service" implementation. It is used by "Start Here" to generate the "DemoService".

It offers a UI (Blazor Auto) and Api alongside Domain, Infrastructure and Use Case class library projects.

A `-ApiOnly 1` switch can be used to generate only the WebApi "App" project and not the "UI" project.

### Packages and Containers

The [Packages and Containers Project](https://github.com/bUKaneer/white-label.templates.Projects.PackagesAndContainers) provides a `docker-compose.yaml` file that sets up unique-to-the-project Docker Registry, Docker Registry UI and Nuget UI infrastructure.

The Container registry can be used to publish "Apps" (UI/WebAPI) project to and can be hosted in Aspire via the `AddContainer`. This allows you to simulate a test environment locally and check the container works as expected before it enters a remote testing environment.

The Nuget (Baget) resource allows for the pushing of shared class libraries such as the Service Defaults from Aspire, Domain, Infrastructure and UseCase libraries and the Shared Kernel project, amongst anything else you may wish to add and share between your projects.

### Shared Kernel

The [Shared Kernel Project](https://github.com/bUKaneer/white-label.templates.SharedKernel) is a port of Ardalis' Clean Architecture project Shared Kernel. It provides a base for customisation of common code across many Services.

### Samples

Samples is the odd one out in this list. This project contains various implementations and demonstrations of the output of White Label Projects. Each folder contained within is a Project in its own right that can be spun up and referenced as required.

Each folder is an Experiment or Demonstration of a particular implementation detail.

At time of writing these are:

- Gateway: Yarp gateway and Api project implementation. inspired by the eShopLite project from the Aspire team.
- ApiClient: NSwag generated ClientSdk project referenced and used by the UI.
- ContainerTest: Projects hosted as normal in App host but addition AppHost.TestEnvironment added that hosts the Containers published to the local docker registry directly using `AddContainer` syntax.

## Feedback

I would dearly love to hear your thoughts and feedback be it positive or otherwise. Id love to hear what you think of the project, how you would like to see it evolve.

Im `bUKaneer` on Twitter and GitHub. So please do let me know your thoughts.

## Why?

I built this project to get more familiar with the technologies and techniques that were demonstrated at .net conf 2023.

Additionally I wanted to get really good with cloud native approach whilst using clean architecture. Finally I really wanted to be able to create and destroy distributed systems at will so that I could quickly spin up an environment so that I could spend more time experimenting and less time creating an environment in which to experiment.

I learnt so much from this project and look forward to hearing your feedback on where it should go next.

## Special Thanks & Further Resources

- [ardalis/CleanArchitecture: Clean Architecture Solution Template: A starting point for Clean Architecture with ASP.NET Core](https://github.com/ardalis/CleanArchitecture)
- [Ardalis is Steve Smith](https://ardalis.com/)
- [dotnet/aspire: .NET Aspire](https://github.com/dotnet/aspire)
- [Nick Chapsas - YouTube](https://www.youtube.com/@nickchapsas)
- [Zoran Horvat - YouTube](https://www.youtube.com/@zoran-horvat)
- [Milan Jovanović - YouTube](https://www.youtube.com/@MilanJovanovicTech)
- [dotnet/eShop: A reference .NET application implementing an eCommerce site](https://github.com/dotnet/eshop)
