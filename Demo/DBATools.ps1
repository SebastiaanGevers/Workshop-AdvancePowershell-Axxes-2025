# Prerequisites and Setup
# STEP 0: Prerequisites and Setup
# ------------------------------
# 1. Import dbatools module
Install-Module dbatools
Import-Module dbatools -Force

# 2. Set up connection credentials
$serverInstance = "localhost"
$username = "sa"
$password = "Workshop2024!"
$credential = New-Object PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))

# 3. Connection parameters for all commands
$connectionParams = @{
    SqlInstance = $serverInstance
    SqlCredential = $credential
}

# Setup complete!

#region Step 1 - Connection and Discovery
# STEP 1: Connection Testing and Server Discovery
# --------------------------------------------------
# 1.1 Test Database Connection
# Command: Test-DbaConnection
$connectionTest = Test-DbaConnection @connectionParams # Example not everything works on all operating systems
$connectionTest | Select-Object SqlInstance, ConnectSuccess, SqlVersion, Edition, ProductLevel | Format-Table -AutoSize

# 1.2 Get Server Information
# Command: Get-DbaComputerSystem
try {
    Get-DbaComputerSystem @connectionParams | 
        Select-Object ComputerName, TotalPhysicalMemory, NumberLogicalProcessors, Domain | 
        Format-Table -AutoSize
} catch {
    # (Server system info not available in container)
}

# 1.3 Get SQL Server Configuration
# Command: Get-DbaSpConfigure
Get-DbaSpConfigure @connectionParams | 
    Where-Object { $_.Name -match "memory|cpu|degree" } |
    Select-Object Name, ConfiguredValue, RunningValue, Description | 
    Format-Table -Wrap

#endregion

#region Step 2 - Database Management
# STEP 2: Database Management and Information
# ---------------------------------------------

# 2.1 List All Databases
# Command: Get-DbaDatabase
Get-DbaDatabase @connectionParams | 
    Select-Object Name, Status, RecoveryModel, CreateDate, @{Name="Size(MB)";Expression={[math]::Round($_.Size,2)}} |
    Format-Table -AutoSize

# 2.2 Get Database Details for WorkshopDB
# Command: Get-DbaDatabase -Database WorkshopDB
Get-DbaDatabase @connectionParams -Database WorkshopDB |
    Select-Object Name, Owner, Collation, CompatibilityLevel, PageVerify, AutoShrink |
    Format-List

# 2.3 Check Database Space Usage
# Command: Get-DbaDbSpace
Get-DbaDbSpace @connectionParams | 
    Where-Object { $_.Database -eq "WorkshopDB" } |
    Select-Object Database, FileType, @{Name="SizeMB";Expression={[math]::Round($_.SizeMB,2)}}, @{Name="UsedMB";Expression={[math]::Round($_.UsedMB,2)}}, @{Name="AvailableMB";Expression={[math]::Round($_.AvailableMB,2)}} |
    Format-Table -AutoSize

# 2.4 List Database Files
# Command: Get-DbaDbFile
Get-DbaDbFile @connectionParams -Database WorkshopDB |
    Select-Object Database, LogicalName, TypeDescription, @{Name="SizeMB";Expression={[math]::Round($_.Size/1MB,2)}}, Growth |
    Format-Table -AutoSize

#endregion

#region Step 3 - Table and Schema Information
# STEP 3: Table and Schema Management
# ----------------------------------------

# 3.1 List All Tables in WorkshopDB
# Command: Get-DbaDbTable
Get-DbaDbTable @connectionParams -Database WorkshopDB |
    Select-Object Database, Schema, Name, RowCount, @{Name="DataSpaceUsedKB";Expression={$_.DataSpaceUsed}} |
    Format-Table -AutoSize

# 3.2 Get Table Column Information
# Command: Get-DbaDbTable (for detailed table info)
Get-DbaDbTable @connectionParams -Database WorkshopDB |
    Select-Object Database, Schema, Name, RowCount, 
        @{Name="DataSizeMB";Expression={[math]::Round($_.DataSpaceUsed/1024, 2)}},
        @{Name="IndexSizeMB";Expression={[math]::Round($_.IndexSpaceUsed/1024, 2)}},
        @{Name="TotalSizeMB";Expression={[math]::Round(($_.DataSpaceUsed + $_.IndexSpaceUsed)/1024, 2)}} |
    Format-Table -AutoSize

# 3.3 Query Sample Data
# Command: Invoke-DbaQuery
$sampleQuery = @"
SELECT TOP 5 
    FirstName + ' ' + LastName as FullName,
    Department,
    Position,
    Salary
FROM Employees
ORDER BY Salary DESC
"@

Invoke-DbaQuery @connectionParams -Database WorkshopDB -Query $sampleQuery | Format-Table -AutoSize

#endregion

#region Step 5 - Security and Users
# STEP 5: Security and User Management
# ----------------------------------------

# 5.1 List Server Logins
# Command: Get-DbaLogin
Get-DbaLogin @connectionParams |
    Select-Object Name, LoginType, CreateDate, LastLogin, IsDisabled |
    Format-Table -AutoSize

# 5.2 List Database Users
# Command: Get-DbaDbUser
Get-DbaDbUser @connectionParams -Database WorkshopDB |
    Select-Object Database, Name, LoginType, CreateDate, DefaultSchema |
    Format-Table -AutoSize

# 5.3 Database Roles
# Command: Get-DbaDbRole
Get-DbaDbRole @connectionParams -Database WorkshopDB |
    Select-Object Database, Name, Owner, IsFixedRole |
    Format-Table -AutoSize

# 5.4 Server Permissions
# Command: Get-DbaServerRole
Get-DbaServerRole @connectionParams |
    Select-Object Name, Owner, IsFixedRole |
    Format-Table -AutoSize

#endregion

#region Step 6 - Backup and Recovery
# STEP 6: Backup and Recovery Operations
# ------------------------------------------

# 6.1 View Backup History
# Command: Get-DbaDbBackupHistory
$backupHistory = Get-DbaDbBackupHistory @connectionParams -Database WorkshopDB -Last
if ($backupHistory) {
    $backupHistory | Select-Object Database, Type, Start, End, @{Name="SizeMB";Expression={[math]::Round($_.TotalSize/1MB,2)}} | Format-Table -AutoSize
} else {
    # No backup history found
}

# 6.2 Create a Database Backup
# Command: Backup-DbaDatabase
try {
    $backupResult = Backup-DbaDatabase @connectionParams -Database WorkshopDB -Type Full -CompressBackup
    $backupResult | Select-Object Database, Type, Start, End, Path, @{Name="SizeMB";Expression={[math]::Round($_.UncompressedBackupSizeKB/1024,2)}} | Format-Table -AutoSize
    # Backup completed successfully!
} catch {
    # Backup operation failed: $($_.Exception.Message)
}

# 6.3 Test Last Backup
# Command: Test-DbaLastBackup
try {
    $testResult = Test-DbaLastBackup @connectionParams -Database WorkshopDB
    if ($testResult) {
        $testResult | Select-Object Database, FileExists, RestoreResult, BackupDate | Format-Table -AutoSize
    }
} catch {
    # Test backup operation not available in this environment
}

#endregion

#region Step 7 - Performance Monitoring
# STEP 7: Performance Monitoring and Analysis
# ---------------------------------------------

# 7.1 Current Database Processes
# Command: Get-DbaProcess
Get-DbaProcess @connectionParams |
    Where-Object { $_.Database -ne $null } |
    Select-Object Spid, Database, Login, Status, Command, CpuTime, ElapsedTime |
    Format-Table -AutoSize

# 7.2 Wait Statistics
# Command: Get-DbaWaitStatistic
try {
    Get-DbaWaitStatistic @connectionParams |
        Sort-Object WaitTimeMs -Descending |
        Select-Object -First 10 |
        Select-Object WaitType, WaitingTasksCount, @{Name="WaitTimeSec";Expression={[math]::Round($_.WaitTimeMs/1000,2)}}, @{Name="AvgWaitTimeSec";Expression={[math]::Round($_.AverageWaitTimeMs/1000,2)}} |
        Format-Table -AutoSize
} catch {
    # Wait statistics require server activity
}

# 7.3 Database Growth Events
# Command: Get-DbaDbGrowthEvent
try {
    $growthEvents = Get-DbaDbGrowthEvent @connectionParams -Database WorkshopDB
    if ($growthEvents) {
        $growthEvents | Select-Object Database, EventTime, FileName, @{Name="GrowthMB";Expression={[math]::Round($_.Growth/1024,2)}} | Format-Table -AutoSize
    } else {
        # No recent database growth events
    }
} catch {
    # Growth event history not available
}

# 7.4 Database Space Growth Trend
# Command: Get-DbaDbSpace (current usage)
Get-DbaDbSpace @connectionParams |
    Where-Object { $_.Database -eq "WorkshopDB" } |
    Select-Object Database, @{Name="UsedPercent";Expression={[math]::Round(($_.UsedMB / $_.SizeMB) * 100, 2)}}, @{Name="FreeSpaceMB";Expression={[math]::Round($_.AvailableMB,2)}} |
    Format-Table -AutoSize

#endregion

#region Step 9 - Data Migration and Copy
# STEP 9: Data Migration and Copy Operations
# ---------------------------------------------

# 9.1 Copy Database Schema to TestDB
# Command: Copy-DbaDbTableData
try {
    # First ensure TestDB exists and copy table structure
    # Creating Employees table in TestDB...
    $createTableSql = @"
    USE TestDB;
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employees_Copy')
    BEGIN
        SELECT TOP 0 * INTO Employees_Copy FROM WorkshopDB.dbo.Employees;
    END
"@
    Invoke-DbaQuery @connectionParams -Query $createTableSql
    
    # Copy some data
    Copy-DbaDbTableData @connectionParams -Database WorkshopDB -Table Employees -DestinationDatabase TestDB -DestinationTable Employees_Copy -Query "SELECT TOP 3 * FROM Employees"
    
    # Verify the copy
    Invoke-DbaQuery @connectionParams -Database TestDB -Query "SELECT COUNT(*) as Count FROM Employees_Copy" | Out-Null
    # Data copied successfully to TestDB.Employees_Copy
    
    # Show the copied data
    Invoke-DbaQuery @connectionParams -Database TestDB -Query "SELECT FirstName, LastName, Department FROM Employees_Copy" | Format-Table -AutoSize
    
} catch {
    # Data copy operation failed: $($_.Exception.Message)
}

#endregion

# Key Learning Points:
#   • dbatools provides 700+ PowerShell commands for SQL Server
#   • Consistent parameter naming across all commands
#   • Works with SQL Server 2000 through 2022
#   • Pipeline-friendly output for easy filtering and formatting
#   • Comprehensive coverage of DBA tasks

# Resources:
#   • Official Site: https://dbatools.io
#   • GitHub: https://github.com/dataplat/dbatools
#   • Documentation: https://docs.dbatools.io
