FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install PowerShell
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        wget \
        apt-transport-https \
        software-properties-common

# Add Microsoft repository and install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell

# Install SQL Server command line tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Install Git and other development tools
RUN apt-get install -y git curl unzip

# Create workspace directory
RUN mkdir -p /workspace
WORKDIR /workspace

# Set PowerShell as default shell for vscode user
USER vscode
RUN echo 'export SHELL=/usr/bin/pwsh' >> ~/.bashrc