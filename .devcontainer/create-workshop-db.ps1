# Create Workshop Databases - Certificate Error Free
Write-Host "🗄️ Creating workshop databases..." -ForegroundColor Green

# Connection parameters - configured to avoid certificate issues
$serverInstance = "localhost"
$password = "Workshop2024!"
$credential = New-Object System.Management.Automation.PSCredential("sa", (ConvertTo-SecureString $password -AsPlainText -Force))

try {
    # Import dbatools and configure for certificate-free connections
    Import-Module dbatools -Force
    
    # Ensure certificate trust is configured
    Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -PassThru | Out-Null
    Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -PassThru | Out-Null
    
    Write-Host "Testing SQL Server connection..." -ForegroundColor Cyan
    
    # Connect with explicit certificate handling
    $connectionParams = @{
        SqlInstance = $serverInstance
        SqlCredential = $credential
        TrustServerCertificate = $true
        EnableException = $true
    }
    
    # Test connection first
    $testResult = Test-DbaConnection @connectionParams
    if (-not $testResult.ConnectSuccess) {
        throw "Connection test failed"
    }
    
    Write-Host "✅ SQL Server connection successful" -ForegroundColor Green
    
    # Create workshop databases
    $databases = @("WorkshopDB", "TestDB", "SampleCompany")
    
    foreach ($dbName in $databases) {
        Write-Host "Creating database: $dbName" -ForegroundColor Cyan
        
        try {
            # Check if database exists
            $existingDb = Get-DbaDatabase @connectionParams -Database $dbName -ErrorAction SilentlyContinue
            
            if (-not $existingDb) {
                # Create new database
                New-DbaDatabase @connectionParams -Name $dbName | Out-Null
                Write-Host "✅ Database '$dbName' created" -ForegroundColor Green
            } else {
                Write-Host "ℹ️ Database '$dbName' already exists" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Failed to create database '$dbName': $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Create sample tables in WorkshopDB
    Write-Host "`nCreating sample data in WorkshopDB..." -ForegroundColor Cyan
    
    $sampleDataScript = @"
USE [WorkshopDB]

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
    )
END

-- Create Departments table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Departments')
BEGIN
    CREATE TABLE Departments (
        DepartmentID int IDENTITY(1,1) PRIMARY KEY,
        DepartmentName nvarchar(50) UNIQUE NOT NULL,
        Budget decimal(12,2),
        Location nvarchar(100)
    )
END

-- Insert sample departments
IF NOT EXISTS (SELECT * FROM Departments)
BEGIN
    INSERT INTO Departments (DepartmentName, Budget, Location) VALUES
    ('Information Technology', 1500000.00, 'Building A - Floor 3'),
    ('Human Resources', 800000.00, 'Building A - Floor 1'),
    ('Finance', 1200000.00, 'Building B - Floor 2'),
    ('Marketing', 900000.00, 'Building A - Floor 2'),
    ('Operations', 2000000.00, 'Building C - Floor 1')
END

-- Insert sample employees
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
    ('Amanda', 'Thomas', 'amanda.thomas@company.com', 'Information Technology', 'Junior Developer', 55000.00, '2023-01-15')
END

-- Create indexes for performance demonstrations
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employees_Department' AND object_id = OBJECT_ID('Employees'))
BEGIN
    CREATE INDEX IX_Employees_Department ON Employees(Department)
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employees_Salary' AND object_id = OBJECT_ID('Employees'))
BEGIN
    CREATE INDEX IX_Employees_Salary ON Employees(Salary DESC)
END
"@

    try {
        Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query $sampleDataScript
        Write-Host "✅ Sample data created successfully" -ForegroundColor Green
        
        # Verify data creation
        $employeeCount = Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query "SELECT COUNT(*) as Count FROM Employees"
        $deptCount = Invoke-DbaQuery @connectionParams -Database "WorkshopDB" -Query "SELECT COUNT(*) as Count FROM Departments"
        
        Write-Host "📊 Created $($employeeCount.Count) employees in $($deptCount.Count) departments" -ForegroundColor Cyan
        
    } catch {
        Write-Host "❌ Failed to create sample data: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Display summary
    Write-Host "`n📋 Workshop Environment Summary:" -ForegroundColor Yellow
    $databases = Get-DbaDatabase @connectionParams | Where-Object { $_.Name -in @("WorkshopDB", "TestDB", "SampleCompany") }
    $databases | Select-Object Name, Status, CreateDate, @{Name="Size(MB)";Expression={[math]::Round($_.Size,2)}} | Format-Table -AutoSize
    
    Write-Host "🎉 Workshop databases ready for DBA tools demonstrations!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Database setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This may be normal if SQL Server is still starting up. Try running this script again in a few minutes." -ForegroundColor Yellow
}