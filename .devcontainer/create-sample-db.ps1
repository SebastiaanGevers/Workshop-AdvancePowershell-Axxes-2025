# Create Sample Databases for DBA Tools Workshop
Write-Host "🗄️ Creating sample databases..." -ForegroundColor Green

# Connection parameters
$serverInstance = "sqlserver"
$credential = New-Object System.Management.Automation.PSCredential("sa", (ConvertTo-SecureString "DBATools2024!" -AsPlainText -Force))

try {
    # Import dbatools module
    Import-Module dbatools -Force

    # Test connection with SSL/Certificate settings
    Write-Host "Testing connection to SQL Server..." -ForegroundColor Cyan
    
    # Connect with TrustServerCertificate to bypass certificate validation
    $connectionParams = @{
        SqlInstance = $serverInstance
        SqlCredential = $credential
        TrustServerCertificate = $true
        EnableException = $true
    }
    
    $server = Connect-DbaInstance @connectionParams
    Write-Host "✅ Connected to SQL Server successfully" -ForegroundColor Green

    # Create sample databases
    $databases = @("WorkshopDB", "TestDB", "SampleCompany")
    
    foreach ($dbName in $databases) {
        Write-Host "Creating database: $dbName" -ForegroundColor Cyan
        
        # Create database
        $createDbQuery = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$dbName')
BEGIN
    CREATE DATABASE [$dbName]
END
"@
        Invoke-DbaQuery -SqlInstance $server -Query $createDbQuery -EnableException
        
        # Create sample tables in WorkshopDB
        if ($dbName -eq "WorkshopDB") {
            $sampleDataQuery = @"
USE [WorkshopDB]

-- Create Employees table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Employees' AND xtype='U')
BEGIN
    CREATE TABLE Employees (
        EmployeeID int IDENTITY(1,1) PRIMARY KEY,
        FirstName nvarchar(50) NOT NULL,
        LastName nvarchar(50) NOT NULL,
        Email nvarchar(100) UNIQUE,
        Department nvarchar(50),
        Position nvarchar(100),
        Salary decimal(10,2),
        HireDate date,
        ManagerID int
    )
END

-- Create Departments table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Departments' AND xtype='U')
BEGIN
    CREATE TABLE Departments (
        DepartmentID int IDENTITY(1,1) PRIMARY KEY,
        DepartmentName nvarchar(50) UNIQUE NOT NULL,
        Budget decimal(12,2),
        ManagerID int
    )
END

-- Insert sample data
IF NOT EXISTS (SELECT * FROM Employees)
BEGIN
    INSERT INTO Departments (DepartmentName, Budget) VALUES
    ('IT', 1500000.00),
    ('HR', 800000.00),
    ('Finance', 1200000.00),
    ('Marketing', 900000.00),
    ('Operations', 2000000.00)

    INSERT INTO Employees (FirstName, LastName, Email, Department, Position, Salary, HireDate) VALUES
    ('John', 'Smith', 'john.smith@company.com', 'IT', 'IT Director', 95000.00, '2023-01-15'),
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', 'HR', 'HR Manager', 75000.00, '2023-03-20'),
    ('Michael', 'Brown', 'michael.brown@company.com', 'Finance', 'Finance Director', 90000.00, '2023-06-10'),
    ('Emma', 'Wilson', 'emma.wilson@company.com', 'Marketing', 'Marketing Manager', 70000.00, '2023-02-14'),
    ('David', 'Lee', 'david.lee@company.com', 'IT', 'Senior Developer', 80000.00, '2023-05-01'),
    ('Lisa', 'Garcia', 'lisa.garcia@company.com', 'IT', 'Database Administrator', 75000.00, '2023-08-15'),
    ('Robert', 'Martinez', 'robert.martinez@company.com', 'Finance', 'Senior Accountant', 65000.00, '2023-11-30'),
    ('Jennifer', 'Taylor', 'jennifer.taylor@company.com', 'HR', 'HR Specialist', 55000.00, '2023-01-10'),
    ('William', 'Anderson', 'william.anderson@company.com', 'Marketing', 'Digital Marketing Specialist', 60000.00, '2023-04-20'),
    ('Amanda', 'Thomas', 'amanda.thomas@company.com', 'IT', 'Junior Developer', 55000.00, '2023-01-15')
END

-- Create some indexes for performance testing
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employees_Department')
BEGIN
    CREATE INDEX IX_Employees_Department ON Employees(Department)
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employees_Salary')
BEGIN
    CREATE INDEX IX_Employees_Salary ON Employees(Salary)
END
"@
            Invoke-DbaQuery -SqlInstance $server -Database $dbName -Query $sampleDataQuery -EnableException
            Write-Host "✅ Sample data created in $dbName" -ForegroundColor Green
        }
    }

    # Create a backup for testing restore scenarios
    Write-Host "Creating sample backup..." -ForegroundColor Cyan
    Backup-DbaDatabase -SqlInstance $server -Database "WorkshopDB" -Path "/tmp" -Type Full
    Write-Host "✅ Sample backup created" -ForegroundColor Green

    # Display summary
    Write-Host "`n📊 Database Setup Summary:" -ForegroundColor Yellow
    $dbList = Get-DbaDatabase -SqlInstance $server | Where-Object { $_.Name -in $databases }
    $dbList | Select-Object Name, Status, CreateDate | Format-Table -AutoSize

    Write-Host "🎉 Sample databases created successfully!" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to create sample databases: $($_.Exception.Message)"
    Write-Host "This is normal if SQL Server is still starting up" -ForegroundColor Yellow
}