# Alternative Simple Database Setup Script
# This version uses basic SQL commands instead of dbatools for initial setup

Write-Host "🗄️ Creating workshop databases (Alternative method)..." -ForegroundColor Green

# Connection parameters
$serverInstance = "localhost"
$username = "sa"
$password = "Workshop2024!"

try {
    Write-Host "Testing basic SQL connection..." -ForegroundColor Cyan
    
    # Create connection string for SQL authentication
    $connectionString = "Server=$serverInstance;Database=master;User Id=$username;Password=$password;TrustServerCertificate=true;Integrated Security=false;Connection Timeout=30;"
    
    # Test connection
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "✅ SQL Server connection successful" -ForegroundColor Green
    
    # Function to execute SQL commands
    function Invoke-SqlCommand {
        param(
            [string]$CommandText,
            [System.Data.SqlClient.SqlConnection]$Connection
        )
        
        $command = New-Object System.Data.SqlClient.SqlCommand($CommandText, $Connection)
        $command.CommandTimeout = 60
        return $command.ExecuteNonQuery()
    }
    
    # Create databases
    Write-Host "`nCreating databases..." -ForegroundColor Cyan
    $databases = @("WorkshopDB", "TestDB", "SampleCompany")
    
    foreach ($dbName in $databases) {
        Write-Host "  → Creating $dbName..." -ForegroundColor Gray
        
        try {
            # Check if database exists
            $checkDbSql = "SELECT COUNT(*) FROM sys.databases WHERE name = '$dbName'"
            $checkCommand = New-Object System.Data.SqlClient.SqlCommand($checkDbSql, $connection)
            $exists = $checkCommand.ExecuteScalar()
            
            if ($exists -eq 0) {
                $createDbSql = "CREATE DATABASE [$dbName]"
                Invoke-SqlCommand -CommandText $createDbSql -Connection $connection
                Write-Host "    ✅ Created successfully" -ForegroundColor Green
            } else {
                Write-Host "    ℹ️ Already exists, skipping" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Switch to WorkshopDB and create tables
    Write-Host "`nCreating sample data..." -ForegroundColor Cyan
    $connection.ChangeDatabase("WorkshopDB")
    
    # Create tables
    Write-Host "  → Creating tables..." -ForegroundColor Gray
    $createTablesSql = @"
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
    
    Invoke-SqlCommand -CommandText $createTablesSql -Connection $connection
    
    # Insert sample data
    Write-Host "  → Inserting sample data..." -ForegroundColor Gray
    $insertDataSql = @"
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
    
    Invoke-SqlCommand -CommandText $insertDataSql -Connection $connection
    
    # Verify data creation
    $employeeCountSql = "SELECT COUNT(*) FROM Employees"
    $deptCountSql = "SELECT COUNT(*) FROM Departments"
    
    $empCommand = New-Object System.Data.SqlClient.SqlCommand($employeeCountSql, $connection)
    $deptCommand = New-Object System.Data.SqlClient.SqlCommand($deptCountSql, $connection)
    
    $employeeCount = $empCommand.ExecuteScalar()
    $deptCount = $deptCommand.ExecuteScalar()
    
    Write-Host "  ✅ Created $employeeCount employees in $deptCount departments" -ForegroundColor Green
    
    # Close connection
    $connection.Close()
    
    # Now try to show summary using dbatools (this should work now that databases exist)
    Write-Host "`n📋 Workshop Environment Summary:" -ForegroundColor Yellow
    try {
        Import-Module dbatools -Force
        $credential = New-Object PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
        
        $allDatabases = Get-DbaDatabase -SqlInstance $serverInstance -SqlCredential $credential | 
            Where-Object { $_.Name -in @("WorkshopDB", "TestDB", "SampleCompany") } |
            Select-Object Name, Status, CreateDate, @{Name="Size(MB)";Expression={[math]::Round($_.Size,2)}}
        
        $allDatabases | Format-Table -AutoSize
    } catch {
        Write-Host "  (Summary unavailable - but databases were created successfully)" -ForegroundColor Gray
    }
    
    Write-Host "🎉 Workshop databases ready!" -ForegroundColor Green
    Write-Host "   → Use credentials: sa / Workshop2024!" -ForegroundColor Gray
    Write-Host "   → Main database: WorkshopDB" -ForegroundColor Gray
    Write-Host "   → Connection tested and working" -ForegroundColor Gray
    
} catch {
    Write-Host "`n❌ Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Check if SQL Server container is running:" -ForegroundColor Yellow
    Write-Host "   docker ps | grep sqlserver" -ForegroundColor Gray
    Write-Host "   docker logs sqlserver-workshop" -ForegroundColor Gray
} finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}