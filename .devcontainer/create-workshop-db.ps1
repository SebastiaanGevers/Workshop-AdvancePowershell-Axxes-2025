# Create Workshop Databases - Simple and Clean
Write-Host "🗄️ Creating workshop databases..." -ForegroundColor Green

# Connection parameters - using plain username/password to avoid Windows auth
$serverInstance = "localhost"
$username = "sa"
$password = "Workshop2024!"

try {
    # Import dbatools
    Import-Module dbatools -Force
    
    Write-Host "Testing SQL Server connection..." -ForegroundColor Cyan
    
    # Test connection using direct SQL auth (no Windows auth)
    try {
        Invoke-DbaQuery -SqlInstance $serverInstance -SqlCredential (New-Object PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))) -Query "SELECT 1" -Database master | Out-Null
        Write-Host "✅ SQL Server connection successful" -ForegroundColor Green
    } catch {
        throw "Connection failed: $($_.Exception.Message)"
    }
    
    # Connection parameters for all subsequent operations
    $connectionParams = @{
        SqlInstance = $serverInstance
        SqlCredential = (New-Object PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force)))
    }
    
    # Create workshop databases
    Write-Host "`nCreating databases..." -ForegroundColor Cyan
    $databases = @("WorkshopDB", "TestDB", "SampleCompany")
    
    foreach ($dbName in $databases) {
        Write-Host "  → Creating $dbName..." -ForegroundColor Gray
        
        try {
            # Check if database exists
            $existingDb = Get-DbaDatabase @connectionParams -Database $dbName -ErrorAction SilentlyContinue
            
            if (-not $existingDb) {
                # Create new database
                New-DbaDatabase @connectionParams -Name $dbName | Out-Null
                Write-Host "    ✅ Created successfully" -ForegroundColor Green
            } else {
                Write-Host "    ℹ️ Already exists, skipping" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Create sample tables and data in WorkshopDB
    Write-Host "`nCreating sample data..." -ForegroundColor Cyan
    
    $createTablesScript = @"
USE [WorkshopDB];

-- Create Departments table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Departments')
BEGIN
    CREATE TABLE Departments (
        DepartmentID int IDENTITY(1,1) PRIMARY KEY,
        DepartmentName nvarchar(50) UNIQUE NOT NULL,
        Budget decimal(12,2),
        Location nvarchar(100)
    );
END

-- Create Employees table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employees')
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
        IsActive bit DEFAULT 1
    );
END
"@

    $insertDataScript = @"
USE [WorkshopDB];

-- Insert sample departments (only if table is empty)
IF NOT EXISTS (SELECT * FROM Departments)
BEGIN
    INSERT INTO Departments (DepartmentName, Budget, Location) VALUES
    ('Information Technology', 1500000.00, 'Building A - Floor 3'),
    ('Human Resources', 800000.00, 'Building A - Floor 1'),
    ('Finance', 1200000.00, 'Building B - Floor 2'),
    ('Marketing', 900000.00, 'Building A - Floor 2'),
    ('Operations', 2000000.00, 'Building C - Floor 1');
END

-- Insert sample employees (only if table is empty)
IF NOT EXISTS (SELECT * FROM Employees)
BEGIN
    INSERT INTO Employees (FirstName, LastName, Email, Department, Position, Salary, HireDate) VALUES
    ('John', 'Smith', 'john.smith@company.com', 'Information Technology', 'IT Director', 95000.00, '2023-01-15'),
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', 'Human Resources', 'HR Manager', 75000.00, '2023-03-20'),
    ('Michael', 'Brown', 'michael.brown@company.com', 'Finance', 'Finance Director', 90000.00, '2023-06-10'),
    ('Emma', 'Wilson', 'emma.wilson@company.com', 'Marketing', 'Marketing Manager', 70000.00, '2023-02-14'),
    ('David', 'Lee', 'david.lee@company.com', 'Information Technology', 'Senior Developer', 80000.00, '2023-05-01'),
    ('Lisa', 'Garcia', 'lisa.garcia@company.com', 'Information Technology', 'Database Administrator', 75000.00, '2023-08-15'),
    ('Robert', 'Martinez', 'robert.martinez@company.com', 'Finance', 'Senior Accountant', 65000.00, '2023-11-30'),
    ('Jennifer', 'Taylor', 'jennifer.taylor@company.com', 'Human Resources', 'HR Specialist', 55000.00, '2023-01-10'),
    ('William', 'Anderson', 'william.anderson@company.com', 'Marketing', 'Digital Marketing Specialist', 60000.00, '2023-04-20'),
    ('Amanda', 'Thomas', 'amanda.thomas@company.com', 'Information Technology', 'Junior Developer', 55000.00, '2023-01-15');
END
"@

    try {
        Write-Host "  → Creating tables..." -ForegroundColor Gray
        Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query $createTablesScript
        
        Write-Host "  → Inserting sample data..." -ForegroundColor Gray
        Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query $insertDataScript
        
        # Verify data creation
        $employeeCount = Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query "SELECT COUNT(*) as Count FROM Employees"
        $deptCount = Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query "SELECT COUNT(*) as Count FROM Departments"
        
        Write-Host "  ✅ Created $($employeeCount.Count) employees in $($deptCount.Count) departments" -ForegroundColor Green
        
    } catch {
        Write-Host "  ❌ Failed to create sample data: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Display summary
    Write-Host "`n📋 Workshop Environment Summary:" -ForegroundColor Yellow
    $allDatabases = Get-DbaDatabase @connectionParams | 
        Where-Object { $_.Name -in @("WorkshopDB", "TestDB", "SampleCompany") } |
        Select-Object Name, Status, CreateDate, @{Name="Size(MB)";Expression={[math]::Round($_.Size,2)}}
    
    $allDatabases | Format-Table -AutoSize
    
    Write-Host "🎉 Workshop databases ready!" -ForegroundColor Green
    Write-Host "   → Use credentials: sa / Workshop2024!" -ForegroundColor Gray
    Write-Host "   → Main database: WorkshopDB" -ForegroundColor Gray
    
} catch {
    Write-Host "`n❌ Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 This may be normal if SQL Server is still starting up." -ForegroundColor Yellow
    Write-Host "   Try running this script again in a few minutes." -ForegroundColor Yellow
}