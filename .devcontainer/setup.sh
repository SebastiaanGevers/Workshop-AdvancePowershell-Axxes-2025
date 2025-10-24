#!/bin/bash

# DBA Tools Workshop - Devcontainer Setup Script
echo "🚀 Setting up DBA Tools Workshop environment..."

# Wait for SQL Server to be ready
echo "⏳ Waiting for SQL Server to start..."
for i in {1..30}; do
    if /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "DBATools2024!" -Q "SELECT 1" &> /dev/null; then
        echo "✅ SQL Server is ready!"
        break
    fi
    echo "  Attempt $i/30: SQL Server not ready yet, waiting..."
    sleep 10
done

# Install PowerShell modules
echo "📦 Installing PowerShell modules..."
pwsh -Command "
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module dbatools -Force -Scope AllUsers
    Install-Module SqlServer -Force -Scope AllUsers
    Install-Module ImportExcel -Force -Scope AllUsers
    Install-Module PSWriteHTML -Force -Scope AllUsers
    Install-Module Pester -Force -Scope AllUsers
    Write-Host '✅ PowerShell modules installed successfully'
"

# Create sample databases and data
echo "📊 Creating sample databases..."
pwsh -File /workspace/.devcontainer/create-sample-db.ps1

# Set permissions
echo "🔧 Setting up permissions..."
sudo chown -R vscode:vscode /workspace

echo "🎉 DBA Tools Workshop environment is ready!"
echo ""
echo "🔗 Connection details:"
echo "  Server: sqlserver"
echo "  Port: 1433"
echo "  Username: sa"
echo "  Password: DBATools2024!"
echo ""
echo "🚀 Try running: Get-DbaDatabase -SqlInstance sqlserver -SqlCredential (Get-Credential)"