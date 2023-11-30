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

## Feedback

OI would dearly love to hear your thoughts and feedback be it positive or otherwise. Id love to hear what you think of the project, whow you would like to see it evolve.

Im `bUKaneer` on Twitter and GitHub. So please do let me know your thoughts.

## Why?

I built this project to get more familiar with the technologies and techniques that were demonstrated at .net conf 2023.

Additionally I wanted to get really good with cloud native approachs whilst using clean architecture. Finally I really wanted to be able to create and destroy distributed systems at will so that I could quickly spin up an environment so that I could spend more time experimenting and less time creating an environment in which to experiment.

I learnt so much from this project and look forward to hearing your feedback on where it should go next.
