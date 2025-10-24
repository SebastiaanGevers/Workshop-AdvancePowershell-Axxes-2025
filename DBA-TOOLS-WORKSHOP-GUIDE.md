# DBA Tools Workshop - Student Guide

## 🚀 Getting Started

This workshop provides a complete DBA tools learning environment with SQL Server 2022, pre-configured to avoid certificate authentication issues.

## 🔗 Connection Information

**Server:** `localhost`  
**Username:** `sa`  
**Password:** `Workshop2024!`

## 📋 Pre-configured Environment

The environment is automatically configured with:
- ✅ Certificate trust settings configured
- ✅ SSL encryption properly handled  
- ✅ Sample databases with realistic data
- ✅ All necessary PowerShell modules installed

## 🎯 Workshop Exercises

### Exercise 1: Basic Connection and Discovery

```powershell
# Import the dbatools module
Import-Module dbatools

# Create credentials (password: Workshop2024!)
$cred = Get-Credential -UserName "sa"

# Test connection - should work without certificate errors
Test-DbaConnection -SqlInstance localhost -SqlCredential $cred

# List all databases
Get-DbaDatabase -SqlInstance localhost -SqlCredential $cred | 
    Select-Object Name, Status, CreateDate, Size

# Get detailed information about WorkshopDB
Get-DbaDatabase -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB |
    Select-Object Name, Owner, CreateDate, Size, SpaceAvailable
```

### Exercise 2: Querying Sample Data

```powershell
# Query employee data
Invoke-DbaQuery -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB -Query "
    SELECT 
        FirstName + ' ' + LastName as FullName,
        Department,
        Position,
        Salary,
        HireDate
    FROM Employees
    ORDER BY Salary DESC
"

# Department summary
Invoke-DbaQuery -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB -Query "
    SELECT 
        Department,
        COUNT(*) as EmployeeCount,
        AVG(Salary) as AverageSalary,
        MAX(Salary) as MaxSalary
    FROM Employees
    GROUP BY Department
    ORDER BY AverageSalary DESC
"
```

### Exercise 3: Database Administration Tasks

```powershell
# Check database space usage
Get-DbaDbSpace -SqlInstance localhost -SqlCredential $cred

# View database files
Get-DbaDbFile -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB

# Check database properties
Get-DbaDbProperty -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB

# List all tables in WorkshopDB
Get-DbaDbTable -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB
```

### Exercise 4: Index Analysis

```powershell
# Find missing indexes
Get-DbaMissingIndex -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB

# Check existing indexes
Get-DbaDbIndex -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB

# Index usage statistics
Get-DbaIndexUsage -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB
```

### Exercise 5: Backup Operations

```powershell
# Create a full backup
Backup-DbaDatabase -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB -Path "/tmp"

# View backup history
Get-DbaDbBackupHistory -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB | 
    Select-Object Database, Type, Start, End, Size

# Test backup integrity
Test-DbaLastBackup -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB
```

### Exercise 6: Security and Permissions

```powershell
# List database users
Get-DbaDbUser -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB

# Check database roles
Get-DbaDbRole -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB

# View server logins
Get-DbaLogin -SqlInstance localhost -SqlCredential $cred
```

### Exercise 7: Performance Monitoring

```powershell
# Check current processes
Get-DbaProcess -SqlInstance localhost -SqlCredential $cred

# Monitor wait statistics
Get-DbaWaitStatistic -SqlInstance localhost -SqlCredential $cred

# Database growth information
Get-DbaDbGrowthEvent -SqlInstance localhost -SqlCredential $cred
```

### Exercise 8: Advanced Administration

```powershell
# Create a new database
New-DbaDatabase -SqlInstance localhost -SqlCredential $cred -Name "StudentDB"

# Copy data between databases
Copy-DbaDbTableData -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB -Table Employees -DestinationDatabase StudentDB

# Generate database documentation
Get-DbaDatabase -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB | 
    Export-Csv -Path "database-info.csv" -NoTypeInformation
```

## 🔧 Troubleshooting

If you encounter any issues:

1. **Check SQL Server status:**
   ```bash
   docker ps | grep sqlserver-workshop
   ```

2. **Restart SQL Server if needed:**
   ```bash
   docker restart sqlserver-workshop
   ```

3. **Re-run database setup:**
   ```powershell
   .\.devcontainer\create-workshop-db.ps1
   ```

## 📚 Key Learning Points

- **No certificate errors** - Environment pre-configured
- **Real SQL Server features** - Full SQL Server 2022 Developer Edition
- **dbatools commands** - 500+ PowerShell cmdlets for SQL Server
- **Practical scenarios** - Real-world database administration tasks
- **Performance monitoring** - Index analysis, wait statistics, backups
- **Security management** - Users, roles, permissions

## 🎓 Additional Resources

- [dbatools.io](https://dbatools.io) - Official documentation
- [SQL Server PowerShell](https://docs.microsoft.com/en-us/sql/powershell/) - Microsoft docs
- Sample databases are reset each time the environment starts

---

**Happy Learning! 🎉**

This environment provides everything you need to learn PowerShell database administration without the frustration of connection issues.