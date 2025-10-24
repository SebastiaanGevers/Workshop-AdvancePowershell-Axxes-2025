# DBA Tools Workshop - GitHub Codespace Setup

This repository provides a complete DBA Tools learning environment using GitHub Codespaces with Docker SQL Server.

## 🚀 Quick Start

### Option 1: GitHub Codespaces (Recommended)
1. Click the **"Code"** button on this repository
2. Select **"Codespaces"** tab
3. Click **"Create codespace on main"**
4. Wait for the environment to initialize (3-5 minutes)
5. SQL Server will be automatically set up and ready to use!

### Option 2: Local Development Container
1. Clone this repository
2. Open in VS Code
3. Install the "Dev Containers" extension
4. Press `F1` → "Dev Containers: Reopen in Container"
5. Wait for setup to complete

## 🗄️ What's Included

### Database Environment
- **SQL Server 2022 Developer Edition** running in Docker
- **Pre-configured sample databases:**
  - `WorkshopDB` - Main learning database with employees/departments
  - `TestDB` - Empty database for experimentation
  - `SampleCompany` - Additional practice database

### PowerShell Modules
- **dbatools** - 500+ SQL Server PowerShell commands
- **SqlServer** - Official Microsoft SQL Server module
- **ImportExcel** - Excel integration for reports
- **PSWriteHTML** - HTML report generation
- **Pester** - Testing framework

### VS Code Extensions
- PowerShell extension with IntelliSense
- SQL Server (mssql) extension
- Docker extension for container management

## 🔗 Connection Details

**Server:** `sqlserver` (or `localhost` from VS Code)  
**Port:** `1433`  
**Username:** `sa`  
**Password:** `DBATools2024!`

## 🎯 Getting Started with DBA Tools

### 1. Test Your Connection
```powershell
# Import the module
Import-Module dbatools

# Test connection
$cred = Get-Credential -UserName "sa" -Message "Enter SA password: DBATools2024!"
Test-DbaConnection -SqlInstance sqlserver -SqlCredential $cred
```

### 2. Explore Your Databases
```powershell
# List all databases
Get-DbaDatabase -SqlInstance sqlserver -SqlCredential $cred

# Get detailed database information
Get-DbaDatabase -SqlInstance sqlserver -SqlCredential $cred -Database WorkshopDB | 
    Select-Object Name, Status, CreateDate, Size, SpaceAvailable
```

### 3. Query Sample Data
```powershell
# Query the sample data
Invoke-DbaQuery -SqlInstance sqlserver -SqlCredential $cred -Database WorkshopDB -Query "
    SELECT 
        e.FirstName + ' ' + e.LastName as FullName,
        e.Department,
        e.Position,
        e.Salary
    FROM Employees e
    ORDER BY e.Salary DESC
"
```

### 4. Database Administration Tasks
```powershell
# Check database space usage
Get-DbaDbSpace -SqlInstance sqlserver -SqlCredential $cred

# View recent backups
Get-DbaDbBackupHistory -SqlInstance sqlserver -SqlCredential $cred

# Monitor active connections
Get-DbaProcess -SqlInstance sqlserver -SqlCredential $cred
```

## 📚 Learning Modules

### Module 1: Connection and Basic Operations
- Connecting to SQL Server instances
- Discovering databases and objects
- Basic querying with Invoke-DbaQuery

### Module 2: Database Administration
- Database creation and management
- User and permission management
- Database space and growth monitoring

### Module 3: Backup and Recovery
- Creating database backups
- Restoring from backups
- Backup history and verification

### Module 4: Performance Monitoring
- Index analysis and optimization
- Query performance monitoring
- Wait statistics analysis

### Module 5: Security and Compliance
- User access auditing
- Permission reporting
- Security best practices

## 🛠️ Troubleshooting

### SQL Server Not Ready
If SQL Server isn't ready when the codespace starts:
```bash
# Check container status
docker ps

# Restart SQL Server container if needed
docker restart dbatools-sqlserver

# Check SQL Server logs
docker logs dbatools-sqlserver
```

### PowerShell Module Issues
```powershell
# Reinstall modules if needed
Install-Module dbatools -Force -AllowClobber
Import-Module dbatools -Force
```

### Connection Issues
```powershell
# Test different connection methods
Test-DbaConnection -SqlInstance localhost
Test-DbaConnection -SqlInstance sqlserver
Test-DbaConnection -SqlInstance "localhost,1433"
```

## 🎓 Exercise Files

Sample exercise files are included in the `/Exercises` folder:
- `01-Basic-Connections.ps1`
- `02-Database-Administration.ps1`  
- `03-Backup-Recovery.ps1`
- `04-Performance-Monitoring.ps1`
- `05-Security-Auditing.ps1`

## 📖 Additional Resources

- [dbatools Official Documentation](https://dbatools.io)
- [SQL Server PowerShell Documentation](https://docs.microsoft.com/en-us/sql/powershell/)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)

## 🤝 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review container logs: `docker logs dbatools-sqlserver`
3. Create an issue in this repository

---

**Happy Learning! 🎉**

This environment provides everything you need to learn PowerShell database administration with real SQL Server features in a cloud-based development environment.