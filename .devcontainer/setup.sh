#!/bin/bash

# DBA Tools Workshop Setup - Certificate-Free Environment
echo "🚀 Setting up DBA Tools Workshop environment..."

# Install PowerShell modules
echo "📦 Installing PowerShell modules..."
pwsh -Command "
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module dbatools -Force -Scope AllUsers -Verbose:\$false
    Install-Module SqlServer -Force -Scope AllUsers -Verbose:\$false
    Install-Module ImportExcel -Force -Scope AllUsers -Verbose:\$false
    Write-Host '✅ PowerShell modules installed'
"

# Start SQL Server with specific configuration to avoid certificate issues
echo "🗄️ Starting SQL Server with certificate configuration..."
docker run -d \
  --name sqlserver-workshop \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=Workshop2024!" \
  -e "MSSQL_PID=Developer" \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest

# Wait for SQL Server to be ready
echo "⏳ Waiting for SQL Server to initialize..."
for i in {1..30}; do
    if docker exec sqlserver-workshop /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "Workshop2024!" -Q "SELECT 1" &>/dev/null; then
        echo "✅ SQL Server is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️ SQL Server taking longer than expected"
        break
    fi
    sleep 5
done

# Configure dbatools to handle certificates properly
echo "🔧 Configuring dbatools for secure connections..."
pwsh -Command "
    # Set global configuration to handle certificates properly
    Set-DbatoolsConfig -FullName sql.connection.trustcert -Value \$true -PassThru
    Set-DbatoolsConfig -FullName sql.connection.encrypt -Value \$false -PassThru
    Write-Host '✅ dbatools configured for workshop environment'
"

# Create sample databases
echo "📊 Creating sample databases..."
pwsh -File /workspaces/Code/.devcontainer/create-workshop-db-simple.ps1
echo "🎉 DBA Tools Workshop environment ready!"
echo ""
echo "🔗 Connection Details:"
echo "  Server: localhost"
echo "  Username: sa"  
echo "  Password: Workshop2024!"
echo ""
echo "🚀 Test connection: Get-DbaDatabase -SqlInstance localhost -SqlCredential (Get-Credential)"