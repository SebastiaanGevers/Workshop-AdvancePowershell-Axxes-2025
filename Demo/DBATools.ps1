# DBA Tools Course - Test Environment Setup Guide
# Workshop 2025 - Axxes

Write-Host "=== DBA Tools Course - Test Environment Setup ===" -ForegroundColor Green
Write-Host "Complete guide for setting up DBA tools test environment" -ForegroundColor Cyan

# =============================================================================
# ENVIRONMENT SETUP OPTIONS
# =============================================================================

function Show-EnvironmentOptions {
    Write-Host "`n🗄️ Database Environment Options for DBA Tools Course:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Option 1: 🐋 Docker SQL Server (RECOMMENDED)" -ForegroundColor Green
    Write-Host "  ✅ Full SQL Server features" -ForegroundColor White
    Write-Host "  ✅ Easy setup and teardown" -ForegroundColor White
    Write-Host "  ✅ Isolated environment" -ForegroundColor White
    Write-Host "  ✅ Works with full dbatools module" -ForegroundColor White
    Write-Host "  ❌ Requires Docker Desktop" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "Option 2: 🌐 SQL Server LocalDB" -ForegroundColor Green
    Write-Host "  ✅ Lightweight SQL Server" -ForegroundColor White
    Write-Host "  ✅ No Docker required" -ForegroundColor White
    Write-Host "  ✅ Perfect for development" -ForegroundColor White
    Write-Host "  ❌ Windows only" -ForegroundColor Red
    Write-Host "  ❌ Limited features vs full SQL Server" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "Option 3: 📱 SQLite" -ForegroundColor Green
    Write-Host "  ✅ Zero configuration" -ForegroundColor White
    Write-Host "  ✅ Single file database" -ForegroundColor White
    Write-Host "  ✅ Cross-platform" -ForegroundColor White
    Write-Host "  ❌ Limited SQL Server specific features" -ForegroundColor Red
    Write-Host "  ❌ No advanced DBA scenarios" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "Option 4: ☁️ Azure SQL Database" -ForegroundColor Green
    Write-Host "  ✅ Full cloud SQL Server" -ForegroundColor White
    Write-Host "  ✅ Latest features" -ForegroundColor White
    Write-Host "  ❌ Requires Azure subscription" -ForegroundColor Red
    Write-Host "  ❌ Ongoing costs" -ForegroundColor Red
}

# =============================================================================
# OPTION 1: DOCKER SQL SERVER SETUP (RECOMMENDED)
# =============================================================================

function Install-DockerSQLServer {
    Write-Host "`n🐋 Setting up Docker SQL Server Environment..." -ForegroundColor Green
    
    # Check if Docker is installed
    try {
        $dockerVersion = docker --version
        Write-Host "✅ Docker detected: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker not found. Please install Docker Desktop first:" -ForegroundColor Red
        Write-Host "   https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "`nDocker commands to set up SQL Server:" -ForegroundColor Cyan
    
    $dockerCommands = @"
# Pull SQL Server 2022 image
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Create and run SQL Server container
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=DBATools2024!" \
   -p 1433:1433 --name sql-dbatools-workshop \
   -d mcr.microsoft.com/mssql/server:2022-latest

# Verify container is running
docker ps

# Connect to the container (optional)
docker exec -it sql-dbatools-workshop /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "DBATools2024!"
"@
    
    Write-Host $dockerCommands -ForegroundColor White
    Write-Host "`nConnection Details:" -ForegroundColor Yellow
    Write-Host "  Server: localhost,1433" -ForegroundColor White
    Write-Host "  Username: sa" -ForegroundColor White  
    Write-Host "  Password: DBATools2024!" -ForegroundColor White
    
    return $true
}

# =============================================================================
# OPTION 2: SQL SERVER LOCALDB SETUP
# =============================================================================

function Install-SQLServerLocalDB {
    Write-Host "`n🌐 Setting up SQL Server LocalDB..." -ForegroundColor Green
    
    # Check if LocalDB is installed
    try {
        $localDBInfo = SqlLocalDB info
        Write-Host "✅ LocalDB detected" -ForegroundColor Green
    } catch {
        Write-Host "❌ LocalDB not found. Installing..." -ForegroundColor Yellow
        Write-Host "`nDownload and install SQL Server LocalDB:" -ForegroundColor Cyan
        Write-Host "https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/sql-server-express-localdb" -ForegroundColor White
        return $false
    }
    
    Write-Host "`nLocalDB Setup Commands:" -ForegroundColor Cyan
    
    $localDBCommands = @"
# Create LocalDB instance
SqlLocalDB create "DBAToolsWorkshop" -s

# Start the instance
SqlLocalDB start "DBAToolsWorkshop"

# Get connection info
SqlLocalDB info "DBAToolsWorkshop"
"@
    
    Write-Host $localDBCommands -ForegroundColor White
    Write-Host "`nConnection String:" -ForegroundColor Yellow
    Write-Host '  Server=(LocalDB)\DBAToolsWorkshop' -ForegroundColor White
    Write-Host "  Integrated Security: True" -ForegroundColor White
    
    return $true
}

# =============================================================================
# OPTION 3: SQLITE SETUP (SIMPLE OPTION)
# =============================================================================

function Install-SQLiteEnvironment {
    Write-Host "`n📱 Setting up SQLite Environment..." -ForegroundColor Green
    
    # Check for PSSQLite module
    if (Get-Module -ListAvailable -Name PSSQLite) {
        Write-Host "✅ PSSQLite module found" -ForegroundColor Green
    } else {
        Write-Host "Installing PSSQLite module..." -ForegroundColor Yellow
        try {
            Install-Module PSSQLite -Force -Scope CurrentUser
            Write-Host "✅ PSSQLite module installed" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to install PSSQLite module" -ForegroundColor Red
            Write-Host "Manual installation: Install-Module PSSQLite -Force" -ForegroundColor Yellow
            return $false
        }
    }
    
    Write-Host "`nSQLite is ready to use!" -ForegroundColor Green
    Write-Host "Database files will be created as needed" -ForegroundColor Cyan
    
    return $true
}

# =============================================================================
# DBATOOLS MODULE INSTALLATION
# =============================================================================

function Install-DBAToolsModule {
    Write-Host "`n🔧 Installing DBATools Module..." -ForegroundColor Green
    
    # Check if dbatools is already installed
    if (Get-Module -ListAvailable -Name dbatools) {
        $version = (Get-Module -ListAvailable -Name dbatools | Sort-Object Version -Descending | Select-Object -First 1).Version
        Write-Host "✅ DBATools module found (Version: $version)" -ForegroundColor Green
        
        # Check if update is available
        Write-Host "Checking for updates..." -ForegroundColor Cyan
        try {
            $latestVersion = Find-Module dbatools
            if ($latestVersion.Version -gt $version) {
                Write-Host "📦 Update available: $($latestVersion.Version)" -ForegroundColor Yellow
                Write-Host "Run: Update-Module dbatools" -ForegroundColor White
            } else {
                Write-Host "✅ DBATools is up to date" -ForegroundColor Green
            }
        } catch {
            Write-Host "Could not check for updates" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Installing DBATools module..." -ForegroundColor Yellow
        try {
            Install-Module dbatools -Force -Scope CurrentUser -AllowClobber
            Write-Host "✅ DBATools module installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to install DBATools module" -ForegroundColor Red
            Write-Host "Manual installation: Install-Module dbatools -Force" -ForegroundColor Yellow
            return $false
        }
    }
    
    # Import the module
    try {
        Import-Module dbatools
        Write-Host "✅ DBATools module imported" -ForegroundColor Green
        
        # Show some basic info
        $commands = Get-Command -Module dbatools | Measure-Object
        Write-Host "📊 Available commands: $($commands.Count)" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Failed to import DBATools module" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# =============================================================================
# ADDITIONAL TOOLS INSTALLATION
# =============================================================================

function Install-AdditionalTools {
    Write-Host "`n🛠️ Installing Additional DBA Tools..." -ForegroundColor Green
    
    $recommendedModules = @{
        'SqlServer' = 'Official SQL Server PowerShell module'
        'ImportExcel' = 'Excel import/export for reports'
        'PSWriteHTML' = 'HTML report generation'
        'Pester' = 'Testing framework for database tests'
    }
    
    foreach ($module in $recommendedModules.Keys) {
        Write-Host "`nChecking $module..." -ForegroundColor Cyan
        if (Get-Module -ListAvailable -Name $module) {
            Write-Host "✅ $module already installed" -ForegroundColor Green
        } else {
            Write-Host "Installing $module - $($recommendedModules[$module])" -ForegroundColor Yellow
            try {
                Install-Module $module -Force -Scope CurrentUser -AllowClobber
                Write-Host "✅ $module installed" -ForegroundColor Green
            } catch {
                Write-Host "❌ Failed to install $module" -ForegroundColor Red
            }
        }
    }
    
    # Optional GUI tools recommendations
    Write-Host "`n🖥️ Recommended GUI Tools:" -ForegroundColor Yellow
    Write-Host "  • SQL Server Management Studio (SSMS)" -ForegroundColor White
    Write-Host "  • Azure Data Studio" -ForegroundColor White
    Write-Host "  • DB Browser for SQLite" -ForegroundColor White
    Write-Host "  • Docker Desktop" -ForegroundColor White
}

# =============================================================================
# SAMPLE DATABASE CREATION
# =============================================================================

function New-SampleDatabases {
    param(
        [string]$DatabaseType = "SQLite",
        [string]$ConnectionString = ""
    )
    
    Write-Host "`n📊 Creating Sample Databases..." -ForegroundColor Green
    
    switch ($DatabaseType) {
        "SQLite" {
            return New-SQLiteSampleDB
        }
        "SQLServer" {
            return New-SQLServerSampleDB -ConnectionString $ConnectionString
        }
        "LocalDB" {
            return New-LocalDBSampleDB
        }
        default {
            Write-Host "❌ Unknown database type: $DatabaseType" -ForegroundColor Red
            return $false
        }
    }
}

function New-SQLiteSampleDB {
    Write-Host "Creating SQLite sample database..." -ForegroundColor Cyan
    
    $dbPath = ".\DBAToolsWorkshop.db"
    
    # Remove existing database
    if (Test-Path $dbPath) {
        Remove-Item $dbPath -Force
        Write-Host "Removed existing database" -ForegroundColor Yellow
    }
    
    try {
        # Import PSSQLite
        Import-Module PSSQLite -ErrorAction Stop
        
        # Create sample tables and data
        $createScript = @"
CREATE TABLE Employees (
    EmployeeID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    Email TEXT UNIQUE,
    Department TEXT,
    Salary DECIMAL(10,2),
    HireDate DATE
);

CREATE TABLE Departments (
    DepartmentID INTEGER PRIMARY KEY,
    DepartmentName TEXT UNIQUE,
    Budget DECIMAL(12,2)
);

INSERT INTO Departments VALUES (1, 'IT', 1500000.00);
INSERT INTO Departments VALUES (2, 'HR', 800000.00);
INSERT INTO Departments VALUES (3, 'Finance', 1200000.00);

INSERT INTO Employees VALUES (1, 'John', 'Smith', 'john@company.com', 'IT', 75000.00, '2023-01-15');
INSERT INTO Employees VALUES (2, 'Sarah', 'Johnson', 'sarah@company.com', 'HR', 65000.00, '2023-02-20');
INSERT INTO Employees VALUES (3, 'Mike', 'Wilson', 'mike@company.com', 'Finance', 70000.00, '2023-03-10');
"@
        
        Invoke-SqliteQuery -DataSource $dbPath -Query $createScript
        Write-Host "✅ SQLite sample database created: $dbPath" -ForegroundColor Green
        return $dbPath
        
    } catch {
        Write-Host "❌ Failed to create SQLite database: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# =============================================================================
# CONNECTION TESTING
# =============================================================================

function Test-DatabaseConnections {
    Write-Host "`n🔗 Testing Database Connections..." -ForegroundColor Green
    
    # Test SQLite if available
    if (Test-Path ".\DBAToolsWorkshop.db") {
        try {
            Import-Module PSSQLite -ErrorAction Stop
            $result = Invoke-SqliteQuery -DataSource ".\DBAToolsWorkshop.db" -Query "SELECT COUNT(*) as Count FROM Employees"
            Write-Host "✅ SQLite: Connected successfully - $($result.Count) employees found" -ForegroundColor Green
        } catch {
            Write-Host "❌ SQLite: Connection failed" -ForegroundColor Red
        }
    }
    
    # Test SQL Server (Docker)
    try {
        Import-Module dbatools -ErrorAction Stop
        $instance = Connect-DbaInstance -SqlInstance "localhost,1433" -SqlCredential (Get-Credential -UserName "sa" -Message "Enter SA password") -ErrorAction Stop
        Write-Host "✅ SQL Server (Docker): Connected successfully" -ForegroundColor Green
        $instance.Disconnect()
    } catch {
        Write-Host "❌ SQL Server (Docker): Connection failed or not available" -ForegroundColor Yellow
    }
    
    # Test LocalDB
    try {
        $instance = Connect-DbaInstance -SqlInstance "(LocalDB)\DBAToolsWorkshop" -ErrorAction Stop
        Write-Host "✅ LocalDB: Connected successfully" -ForegroundColor Green
        $instance.Disconnect()
    } catch {
        Write-Host "❌ LocalDB: Connection failed or not available" -ForegroundColor Yellow
    }
}

# =============================================================================
# COURSE VERIFICATION
# =============================================================================

function Test-CourseEnvironment {
    Write-Host "`n✅ Course Environment Verification..." -ForegroundColor Green
    
    $results = @{
        DBAToolsModule = $false
        Database = $false
        AdditionalTools = $false
        SampleData = $false
    }
    
    # Check DBATools module
    if (Get-Module -ListAvailable -Name dbatools) {
        $results.DBAToolsModule = $true
        Write-Host "✅ DBATools module: Ready" -ForegroundColor Green
    } else {
        Write-Host "❌ DBATools module: Missing" -ForegroundColor Red
    }
    
    # Check database availability
    if ((Test-Path ".\DBAToolsWorkshop.db") -or (Get-Process -Name "sqlservr" -ErrorAction SilentlyContinue)) {
        $results.Database = $true
        Write-Host "✅ Database: Available" -ForegroundColor Green
    } else {
        Write-Host "❌ Database: Not available" -ForegroundColor Red
    }
    
    # Check additional modules
    $additionalModules = @('SqlServer', 'ImportExcel', 'PSSQLite')
    $moduleCount = 0
    foreach ($module in $additionalModules) {
        if (Get-Module -ListAvailable -Name $module) {
            $moduleCount++
        }
    }
    
    if ($moduleCount -eq $additionalModules.Count) {
        $results.AdditionalTools = $true
        Write-Host "✅ Additional tools: All installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Additional tools: $moduleCount/$($additionalModules.Count) installed" -ForegroundColor Yellow
    }
    
    # Overall readiness
    $readyCount = ($results.Values | Where-Object { $_ -eq $true }).Count
    $totalChecks = $results.Count
    
    Write-Host "`n📊 Environment Readiness: $readyCount/$totalChecks" -ForegroundColor Cyan
    
    if ($readyCount -eq $totalChecks) {
        Write-Host "🎉 Your DBA Tools course environment is ready!" -ForegroundColor Green
    } elseif ($readyCount -ge 2) {
        Write-Host "⚠️ Environment partially ready - can proceed with limitations" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Environment needs more setup before starting course" -ForegroundColor Red
    }
    
    return $results
}

# =============================================================================
# MAIN SETUP WORKFLOW
# =============================================================================

function Start-DBAToolsSetup {
    param(
        [ValidateSet("Docker", "LocalDB", "SQLite", "Interactive")]
        [string]$DatabaseType = "Interactive"
    )
    
    Write-Host "🚀 Starting DBA Tools Course Environment Setup..." -ForegroundColor Green
    
    # Show options if interactive
    if ($DatabaseType -eq "Interactive") {
        Show-EnvironmentOptions
        
        do {
            $choice = Read-Host "`nSelect database option (1-4, or 'q' to quit)"
            switch ($choice) {
                "1" { $DatabaseType = "Docker"; break }
                "2" { $DatabaseType = "LocalDB"; break }
                "3" { $DatabaseType = "SQLite"; break }
                "4" { Write-Host "Azure SQL Database setup requires manual configuration"; return }
                "q" { Write-Host "Setup cancelled"; return }
                default { Write-Host "Invalid choice. Please select 1-4 or 'q'." -ForegroundColor Red }
            }
        } while ($choice -notin @("1", "2", "3", "4", "q"))
    }
    
    # Install DBATools module first
    if (-not (Install-DBAToolsModule)) {
        Write-Host "❌ Cannot proceed without DBATools module" -ForegroundColor Red
        return
    }
    
    # Setup database environment
    switch ($DatabaseType) {
        "Docker" {
            if (Install-DockerSQLServer) {
                Write-Host "`n⏳ Waiting for SQL Server container to start..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
            }
        }
        "LocalDB" {
            Install-SQLServerLocalDB
        }
        "SQLite" {
            Install-SQLiteEnvironment
            New-SQLiteSampleDB
        }
    }
    
    # Install additional tools
    Install-AdditionalTools
    
    # Test connections
    Test-DatabaseConnections
    
    # Final verification
    Test-CourseEnvironment
    
    Write-Host "`n🎯 Setup Complete! Ready for DBA Tools course." -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Review the connection details above" -ForegroundColor White
    Write-Host "2. Test connections with your chosen database" -ForegroundColor White
    Write-Host "3. Start with basic DBATools commands" -ForegroundColor White
    Write-Host "4. Explore the sample databases created" -ForegroundColor White
}

# =============================================================================
# QUICK START COMMANDS
# =============================================================================

Write-Host "`n🚀 Quick Start Commands:" -ForegroundColor Cyan
Write-Host ""
Write-Host "# Full interactive setup:" -ForegroundColor Green
Write-Host "Start-DBAToolsSetup" -ForegroundColor White
Write-Host ""
Write-Host "# Quick SQLite setup:" -ForegroundColor Green  
Write-Host "Start-DBAToolsSetup -DatabaseType SQLite" -ForegroundColor White
Write-Host ""
Write-Host "# Docker SQL Server setup:" -ForegroundColor Green
Write-Host "Start-DBAToolsSetup -DatabaseType Docker" -ForegroundColor White
Write-Host ""
Write-Host "# Test environment only:" -ForegroundColor Green
Write-Host "Test-CourseEnvironment" -ForegroundColor White

# Uncomment to run setup automatically
# Start-DBAToolsSetup
