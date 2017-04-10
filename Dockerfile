FROM microsoft/windowsservercore
MAINTAINER Raymond Piller <VertigoRay@vertigion.com>


# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command \
        "Import-Module ServerManager; Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter"

ADD webserver /webserver

EXPOSE 8080
WORKDIR /webserver
CMD @powershell -NoProfile -ExecutionPolicy Bypass -File main.ps1