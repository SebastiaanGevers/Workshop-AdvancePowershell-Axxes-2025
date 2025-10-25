# PowerShell DBA Tools Workshop - Solutions
# Workshop 2025 - Axxes

Write-Host @"
=============================================================================
DBA TOOLS WORKSHOP - SOLUTIONS
=============================================================================
"@

# =============================================================================
# OEFENING 1: Module Installation and Verification - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 1: Module Installation and Verification ===" -ForegroundColor Green

# Check if the dbatools module is installed
$dbatoolsModule = Get-Module -ListAvailable -Name dbatools
if ($dbatoolsModule) {
    Write-Host "dbatools module is installed - Version: $($dbatoolsModule.Version)" -ForegroundColor Green
    Import-Module dbatools -Force
} else {
    Write-Host "dbatools module is NOT installed" -ForegroundColor Red
    Write-Host "To install: Install-Module dbatools -Force" -ForegroundColor Yellow
}

# Check if Azure modules are available
$azAccountsModule = Get-Module -ListAvailable -Name Az.Accounts
$azKeyVaultModule = Get-Module -ListAvailable -Name Az.KeyVault

if ($azAccountsModule) {
    Write-Host "Az.Accounts module is available - Version: $($azAccountsModule.Version)" -ForegroundColor Green
    Import-Module Az.Accounts -Force
} else {
    Write-Host "Az.Accounts module is NOT available" -ForegroundColor Red
}

if ($azKeyVaultModule) {
    Write-Host "Az.KeyVault module is available - Version: $($azKeyVaultModule.Version)" -ForegroundColor Green
    Import-Module Az.KeyVault -Force
} else {
    Write-Host "Az.KeyVault module is NOT available" -ForegroundColor Red
}

# Get a count of available dbatools commands
try {
    $dbatoolsCommands = Get-Command -Module dbatools
    Write-Host "dbatools module loaded with $($dbatoolsCommands.Count) commands available" -ForegroundColor Green
    
    # Show some popular commands
    $popularCommands = $dbatoolsCommands | Where-Object { $_.Name -match "Get-Dba|Test-Dba|Backup-Dba" } | Select-Object -First 10
    Write-Host "Sample dbatools commands:"
    $popularCommands | ForEach-Object { Write-Host "  - $($_.Name)" }
} catch {
    Write-Host "Error loading dbatools commands: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# OEFENING 2: Azure Key Vault Connection Setup - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 2: Azure Key Vault Connection Setup ===" -ForegroundColor Green

# Connect to Azure if not already connected
$azContext = Get-AzContext
if (-not $azContext) {
    try {
        Connect-AzAccount
        Write-Host "Connected to Azure successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to connect to Azure: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Already connected to Azure as: $($azContext.Account.Id)" -ForegroundColor Green
}

# Set your Key Vault name (replace with actual name)
$keyVaultName = "kv-workshop-student01"  # Replace with your actual Key Vault name
Write-Host "Using Key Vault: $keyVaultName"

# Test access to your Key Vault by listing the secrets
try {
    $secrets = Get-AzKeyVaultSecret -VaultName $keyVaultName
    Write-Host "Successfully accessed Key Vault '$keyVaultName'" -ForegroundColor Green
    Write-Host "Available secrets:"
    $secrets | ForEach-Object { Write-Host "  - $($_.Name)" }
    
    # Verify required secrets exist
    $requiredSecrets = @("DB-Username", "DB-Password", "DB-Server")
    $missingSecrets = @()
    
    foreach ($required in $requiredSecrets) {
        if ($secrets.Name -contains $required) {
            Write-Host "  $required - Found" -ForegroundColor Green
        } else {
            Write-Host "  $required - Missing" -ForegroundColor Red
            $missingSecrets += $required
        }
    }
    
    if ($missingSecrets.Count -eq 0) {
        Write-Host "All required database secrets are present" -ForegroundColor Green
    } else {
        Write-Host "Missing required secrets: $($missingSecrets -join ', ')" -ForegroundColor Red
        Write-Host "Please complete the SecurePasswords exercises first to set up these secrets" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Failed to access Key Vault: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# OEFENING 3: Secure Database Connection Function - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 3: Secure Database Connection Function ===" -ForegroundColor Green

function Get-DbaConnectionFromKeyVault {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName
    )
    
    try {
        Write-Verbose "Retrieving database credentials from Key Vault: $KeyVaultName"
        
        # 1. Retrieve the three secrets from Key Vault
        $dbUsername = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "DB-Username" -AsPlainText)
        $dbPassword = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "DB-Password" -AsPlainText)
        $dbServer = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "DB-Server" -AsPlainText)
        
        # 2. Create a PSCredential object
        $securePassword = ConvertTo-SecureString $dbPassword -AsPlainText -Force
        $credential = [PSCredential]::new($dbUsername, $securePassword)
        
        # 3. Return a hashtable with SqlInstance and SqlCredential
        $connectionParams = @{
            SqlInstance = $dbServer
            SqlCredential = $credential
        }
        
        Write-Verbose "Successfully retrieved connection parameters for server: $dbServer"
        return $connectionParams
        
    } catch {
        Write-Error "Failed to retrieve database connection from Key Vault: $($_.Exception.Message)"
        return $null
    }
}

# Test the function
try {
    $connectionParams = Get-DbaConnectionFromKeyVault -KeyVaultName $keyVaultName
    if ($connectionParams) {
        Write-Host "  Successfully retrieved connection parameters" -ForegroundColor Green
        Write-Host "  SQL Instance: $($connectionParams.SqlInstance)"
        Write-Host "  Username: $($connectionParams.SqlCredential.UserName)"
        Write-Host "  Password: [PROTECTED]"
    } else {
        Write-Host "Failed to retrieve connection parameters" -ForegroundColor Red
    }
} catch {
    Write-Host "Error testing connection function: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# OEFENING 4: Basic Database Connectivity Testing - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 4: Basic Database Connectivity Testing ===" -ForegroundColor Green

# Test database connection using dbatools
if ($connectionParams) {
    try {
        Write-Host "Testing database connection..."
        $connectionTest = Test-DbaConnection @connectionParams
        
        if ($connectionTest.ConnectSuccess) {
            Write-Host "  Database connection successful!" -ForegroundColor Green
            Write-Host "  SQL Server: $($connectionTest.SqlInstance)"
            Write-Host "  Version: $($connectionTest.SqlVersion)"
            Write-Host "  Edition: $($connectionTest.Edition)"
            Write-Host "  Authentication: $($connectionTest.AuthType)"
            Write-Host "  Connect Time: $($connectionTest.ConnectingTime) ms"
        } else {
            Write-Host "  Database connection failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Connection test error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Comprehensive connection test function
function Test-SecureDatabaseConnection {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName
    )
    
    try {
        Write-Host "Starting comprehensive database connection test..." -ForegroundColor Cyan
        
        # 1. Get connection parameters
        Write-Host "1. Retrieving credentials from Key Vault..."
        $connectionParams = Get-DbaConnectionFromKeyVault -KeyVaultName $KeyVaultName
        if (-not $connectionParams) {
            throw "Failed to retrieve connection parameters"
        }
        Write-Host "     Credentials retrieved successfully"
        
        # 2. Test the connection
        Write-Host "2. Testing database connectivity..."
        $connectionTest = Test-DbaConnection @connectionParams
        
        if (-not $connectionTest.ConnectSuccess) {
            throw "Database connection failed"
        }
        Write-Host "     Database connection successful"
        
        # 3. Test query execution
        Write-Host "3. Testing query execution..."
        $queryResult = Invoke-DbaQuery @connectionParams -Query "SELECT @@VERSION as SqlVersion, GETDATE() as CurrentTime, @@SERVERNAME as ServerName"
        Write-Host "     Query execution successful"
        
        # 4. Return detailed connection information
        $result = @{
            Success = $true
            SqlInstance = $connectionTest.SqlInstance
            SqlVersion = $connectionTest.SqlVersion
            Edition = $connectionTest.Edition
            AuthType = $connectionTest.AuthType
            ConnectTime = $connectionTest.ConnectingTime
            ServerTime = $queryResult.CurrentTime
            ServerName = $queryResult.ServerName
        }
        
        return $result
        
    } catch {
        Write-Error "Comprehensive connection test failed: $($_.Exception.Message)"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Test the comprehensive function
$connectionResult = Test-SecureDatabaseConnection -KeyVaultName $keyVaultName
if ($connectionResult.Success) {
    Write-Host "  Comprehensive connection test passed!" -ForegroundColor Green
    Write-Host "  Server: $($connectionResult.ServerName)"
    Write-Host "  Server Time: $($connectionResult.ServerTime)"
} else {
    Write-Host "  Comprehensive connection test failed: $($connectionResult.Error)" -ForegroundColor Red
}

# =============================================================================
# OEFENING 5: Database Discovery and Information Gathering - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 5: Database Discovery and Information Gathering ===" -ForegroundColor Green

if ($connectionParams) {
    try {
        # List all databases
        Write-Host "Getting database list..."
        $databases = Get-DbaDatabase @connectionParams
        Write-Host "  Found $($databases.Count) databases:" -ForegroundColor Green
        $databases | Select-Object Name, Status, RecoveryModel, SizeMB, CreateDate | Format-Table -AutoSize
        
        # Get SQL Server instance information
        Write-Host "Getting SQL Server instance information..."
        $instanceProperties = Get-DbaInstanceProperty @connectionParams
        $keyProperties = $instanceProperties | Where-Object { $_.Name -in @('ServerName', 'ProductVersion', 'Edition', 'ProcessorCount', 'PhysicalMemoryMB') }
        Write-Host "Instance Information:" -ForegroundColor Green
        $keyProperties | Format-Table Name, Value -AutoSize
        
        # Check disk space usage
        Write-Host "Checking database disk space usage..."
        $diskSpace = Get-DbaDbSpace @connectionParams
        Write-Host "Database Space Usage:" -ForegroundColor Green
        $diskSpace | Select-Object Database, FileType, SizeMB, UsedMB, AvailableMB, PercentUsed | Format-Table -AutoSize
        
        # Get database file information
        Write-Host "Getting database file information..."
        $dbFiles = Get-DbaDbFile @connectionParams
        Write-Host "Database Files:" -ForegroundColor Green
        $dbFiles | Select-Object Database, LogicalName, TypeDescription, SizeMB, GrowthMB, MaxSizeMB | Format-Table -AutoSize
        
    } catch {
        Write-Host "Error in database discovery: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# OEFENING 6: Database Security Analysis - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 6: Database Security Analysis ===" -ForegroundColor Green

if ($connectionParams) {
    try {
        # List all database logins
        Write-Host "Analyzing database security..."
        $logins = Get-DbaLogin @connectionParams
        Write-Host "Found $($logins.Count) logins:" -ForegroundColor Green
        $logins | Select-Object Name, LoginType, IsDisabled, CreateDate, LastLogin | Format-Table -AutoSize
        
        # Check users in each database
        Write-Host "Checking database users..."
        foreach ($db in ($databases | Where-Object { -not $_.IsSystemObject })) {
            $users = Get-DbaUser @connectionParams -Database $db.Name
            if ($users) {
                Write-Host "Database: $($db.Name) - Users: $($users.Count)"
                $users | Select-Object Name, UserType, DefaultSchema | Format-Table -AutoSize
            }
        }
        
        # Check sysadmin role members
        Write-Host "Checking sysadmin role members..."
        $sysadminMembers = Get-DbaServerRoleMember @connectionParams -Role 'sysadmin'
        Write-Host "Sysadmin members:" -ForegroundColor Green
        $sysadminMembers | Select-Object Name, LoginType | Format-Table -AutoSize
        
        # Check databases with simple recovery model
        $simpleRecoveryDbs = $databases | Where-Object { $_.RecoveryModel -eq 'Simple' -and -not $_.IsSystemObject }
        if ($simpleRecoveryDbs) {
            Write-Host "Databases with Simple recovery model (potential backup concern):" -ForegroundColor Yellow
            $simpleRecoveryDbs | Select-Object Name, RecoveryModel | Format-Table -AutoSize
        }
        
    } catch {
        Write-Host "Error in security analysis: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# OEFENING 7: Performance Monitoring and Analysis - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 7: Performance Monitoring and Analysis ===" -ForegroundColor Green

if ($connectionParams) {
    try {
        # Get wait statistics
        Write-Host "Analyzing performance metrics..."
        $waitStats = Get-DbaWaitStatistic @connectionParams | Sort-Object WaitTime_ms -Descending | Select-Object -First 10
        if ($waitStats) {
            Write-Host "Top 10 Wait Statistics:" -ForegroundColor Green
            $waitStats | Select-Object WaitType, WaitTime_ms, WaitCount, Percentage | Format-Table -AutoSize
        }
        
        # Check for running queries
        $runningQueries = Get-DbaRunningQuery @connectionParams
        Write-Host "Currently running queries: $($runningQueries.Count)" -ForegroundColor Green
        if ($runningQueries) {
            $runningQueries | Select-Object SessionId, Status, Command, ElapsedTime | Format-Table -AutoSize
        }
        
        # Look for blocking processes
        $blockingProcesses = Get-DbaBlocking @connectionParams
        if ($blockingProcesses) {
            Write-Host "Blocking processes detected: $($blockingProcesses.Count)" -ForegroundColor Yellow
            $blockingProcesses | Select-Object BlockedSessionId, BlockingSessionId, WaitTime | Format-Table -AutoSize
        } else {
            Write-Host "No blocking processes detected" -ForegroundColor Green
        }
        
        # Get system information
        $systemInfo = Get-DbaComputerSystem @connectionParams
        if ($systemInfo) {
            Write-Host "System Information:" -ForegroundColor Green
            Write-Host "  Computer: $($systemInfo.ComputerName)"
            Write-Host "  OS: $($systemInfo.OperatingSystem)"
            Write-Host "  Total Memory: $([math]::Round($systemInfo.TotalPhysicalMemoryMB/1024, 2)) GB"
            Write-Host "  Processors: $($systemInfo.ProcessorCount)"
        }
        
    } catch {
        Write-Host "Error in performance analysis: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# OEFENING 8: Backup Operations with Secure Credentials - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 8: Backup Operations with Secure Credentials ===" -ForegroundColor Green

function Start-SecureDatabaseBackup {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [Parameter(Mandatory)]
        [string]$DatabaseName,
        [string]$BackupPath = "C:\Temp\Backups",
        [ValidateSet("Full", "Differential", "Log")]
        [string]$BackupType = "Full"
    )
    
    try {
        Write-Host "Starting secure database backup process..." -ForegroundColor Cyan
        
        # 1. Get connection parameters from Key Vault
        Write-Host "1. Retrieving credentials from Key Vault..."
        $connectionParams = Get-DbaConnectionFromKeyVault -KeyVaultName $KeyVaultName
        if (-not $connectionParams) {
            throw "Failed to retrieve connection parameters"
        }
        Write-Host "   Credentials retrieved successfully"
        
        # 2. Verify database exists
        Write-Host "2. Verifying database exists..."
        $database = Get-DbaDatabase @connectionParams | Where-Object { $_.Name -eq $DatabaseName }
        if (-not $database) {
            throw "Database '$DatabaseName' not found"
        }
        Write-Host "   Database '$DatabaseName' found"
        
        # 3. Create backup directory if it doesn't exist
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force
            Write-Host "   Created backup directory: $BackupPath"
        }
        
        # 4. Perform the backup
        Write-Host "3. Creating $BackupType backup..."
        $backupResult = Backup-DbaDatabase @connectionParams -Database $DatabaseName -Type $BackupType -Path $BackupPath
        
        # 5. Verify backup was successful
        if ($backupResult) {
            Write-Host "   Backup completed successfully!"
            Write-Host "   File: $($backupResult.Path)"
            Write-Host "   Size: $([math]::Round($backupResult.UncompressedBackupSizeKB/1024, 2)) MB"
            Write-Host "   Duration: $($backupResult.Duration)"
            
            # 6. Return backup information
            return @{
                Success = $true
                Path = $backupResult.Path
                SizeMB = [math]::Round($backupResult.UncompressedBackupSizeKB/1024, 2)
                Duration = $backupResult.Duration
                Database = $DatabaseName
                BackupType = $BackupType
            }
        } else {
            throw "Backup operation returned no result"
        }
        
    } catch {
        Write-Error "Secure backup failed: $($_.Exception.Message)"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Test backup function (commented out to avoid disk usage)
Write-Host "Backup function created. Test with small database if needed:"
Write-Host "# `$backupResult = Start-SecureDatabaseBackup -KeyVaultName `$keyVaultName -DatabaseName 'master'"

# =============================================================================
# OEFENING 9: Database Maintenance Automation - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 9: Database Maintenance Automation ===" -ForegroundColor Green

function Update-DatabaseStatistics {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [Parameter(Mandatory)]
        [string]$DatabaseName
    )
    
    try {
        Write-Host "Updating statistics for database: $DatabaseName" -ForegroundColor Cyan
        
        # 1. Get connection parameters
        $connectionParams = Get-DbaConnectionFromKeyVault -KeyVaultName $KeyVaultName
        if (-not $connectionParams) {
            throw "Failed to retrieve connection parameters"
        }
        
        # 2. Update statistics for the specified database
        $updateResult = Update-DbaStatistics @connectionParams -Database $DatabaseName
        
        # 3. Return results
        return @{
            Success = $true
            Database = $DatabaseName
            TablesUpdated = $updateResult.Count
            Details = $updateResult
        }
        
    } catch {
        Write-Error "Failed to update statistics: $($_.Exception.Message)"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Optimize-DatabaseIndexes {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [Parameter(Mandatory)]
        [string]$DatabaseName,
        [int]$FragmentationThreshold = 30
    )
    
    try {
        Write-Host "Optimizing indexes for database: $DatabaseName" -ForegroundColor Cyan
        
        # 1. Get connection parameters
        $connectionParams = Get-DbaConnectionFromKeyVault -KeyVaultName $KeyVaultName
        
        # 2. Check index fragmentation
        $fragmentedIndexes = Get-DbaDbFragmentation @connectionParams -Database $DatabaseName | 
            Where-Object { $_.AvgFragmentationInPercent -gt $FragmentationThreshold }
        
        if ($fragmentedIndexes) {
            Write-Host "Found $($fragmentedIndexes.Count) fragmented indexes above $FragmentationThreshold% threshold"
            
            # 3. Rebuild indexes above threshold (commented out for safety in demo)
            # $rebuildResults = $fragmentedIndexes | Invoke-DbaDbIndexDefrag @connectionParams
            
            return @{
                Success = $true
                Database = $DatabaseName
                FragmentedIndexes = $fragmentedIndexes.Count
                Threshold = $FragmentationThreshold
                IndexDetails = $fragmentedIndexes
                # RebuildResults = $rebuildResults
            }
        } else {
            Write-Host "No fragmented indexes found above $FragmentationThreshold% threshold"
            return @{
                Success = $true
                Database = $DatabaseName
                FragmentedIndexes = 0
                Message = "No optimization needed"
            }
        }
        
    } catch {
        Write-Error "Failed to optimize indexes: $($_.Exception.Message)"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Test maintenance functions
if ($connectionParams) {
    Write-Host "Testing maintenance functions with 'master' database..."
    
    # Test statistics update
    $statsResult = Update-DatabaseStatistics -KeyVaultName $keyVaultName -DatabaseName "master"
    if ($statsResult.Success) {
        Write-Host "Statistics update completed for $($statsResult.TablesUpdated) objects" -ForegroundColor Green
    }
    
    # Test index optimization check
    $indexResult = Optimize-DatabaseIndexes -KeyVaultName $keyVaultName -DatabaseName "master"
    if ($indexResult.Success) {
        Write-Host "Index optimization check completed - $($indexResult.FragmentedIndexes) fragmented indexes found" -ForegroundColor Green
    }
}

# =============================================================================
# OEFENING 10: Comprehensive Database Health Check - SOLUTIONS
# =============================================================================
Write-Host "`n=== OEFENING 10: Comprehensive Database Health Check ===" -ForegroundColor Green

function Get-DatabaseHealthReport {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [string]$DatabaseName = $null  # If null, check all databases
    )
    
    try {
        Write-Host "Generating comprehensive database health report..." -ForegroundColor Cyan
        
        # Get connection parameters
        $connectionParams = Get-DbaConnectionFromKeyVault -KeyVaultName $KeyVaultName
        if (-not $connectionParams) {
            throw "Failed to retrieve connection parameters"
        }
        
        $report = @{
            GeneratedOn = Get-Date
            ServerName = ""
            OverallHealth = "Unknown"
            Checks = @{}
        }
        
        # 1. Connection test
        Write-Host "1. Testing connection..."
        $connectionTest = Test-DbaConnection @connectionParams
        $report.ServerName = $connectionTest.SqlInstance
        $report.Checks.Connection = @{
            Status = if ($connectionTest.ConnectSuccess) { "Healthy" } else { "Failed" }
            Details = $connectionTest
        }
        
        # 2. Database status
        Write-Host "2. Checking database status..."
        $databases = Get-DbaDatabase @connectionParams
        if ($DatabaseName) {
            $databases = $databases | Where-Object { $_.Name -eq $DatabaseName }
        }
        
        $offlineDatabases = $databases | Where-Object { $_.Status -ne "Normal" }
        $report.Checks.DatabaseStatus = @{
            Status = if ($offlineDatabases.Count -eq 0) { "Healthy" } else { "Warning" }
            TotalDatabases = $databases.Count
            OfflineDatabases = $offlineDatabases.Count
            Details = $offlineDatabases
        }
        
        # 3. Disk space usage
        Write-Host "3. Checking disk space..."
        $diskSpace = Get-DbaDbSpace @connectionParams
        $lowSpaceDatabases = $diskSpace | Where-Object { $_.PercentUsed -gt 90 }
        $report.Checks.DiskSpace = @{
            Status = if ($lowSpaceDatabases.Count -eq 0) { "Healthy" } else { "Warning" }
            LowSpaceCount = $lowSpaceDatabases.Count
            Details = $lowSpaceDatabases
        }
        
        # 4. Backup status
        Write-Host "4. Checking backup status..."
        $backupHistory = Get-DbaBackupHistory @connectionParams -Since (Get-Date).AddDays(-7)
        $databasesWithoutRecentBackup = $databases | Where-Object { 
            -not $_.IsSystemObject -and 
            $_.Name -notin $backupHistory.Database 
        }
        $report.Checks.BackupStatus = @{
            Status = if ($databasesWithoutRecentBackup.Count -eq 0) { "Healthy" } else { "Warning" }
            DatabasesWithoutRecentBackup = $databasesWithoutRecentBackup.Count
            Details = $databasesWithoutRecentBackup
        }
        
        # 5. Performance indicators
        Write-Host "5. Checking performance indicators..."
        $blockingProcesses = Get-DbaBlocking @connectionParams
        $report.Checks.Performance = @{
            Status = if ($blockingProcesses.Count -eq 0) { "Healthy" } else { "Warning" }
            BlockingProcesses = $blockingProcesses.Count
            Details = $blockingProcesses
        }
        
        # 6. Calculate overall health
        $healthyChecks = ($report.Checks.Values | Where-Object { $_.Status -eq "Healthy" }).Count
        $totalChecks = $report.Checks.Count
        $healthPercentage = ($healthyChecks / $totalChecks) * 100
        
        if ($healthPercentage -eq 100) {
            $report.OverallHealth = "Healthy"
        } elseif ($healthPercentage -ge 80) {
            $report.OverallHealth = "Good"
        } elseif ($healthPercentage -ge 60) {
            $report.OverallHealth = "Warning"
        } else {
            $report.OverallHealth = "Critical"
        }
        
        $report.HealthPercentage = $healthPercentage
        
        return $report
        
    } catch {
        Write-Error "Health check failed: $($_.Exception.Message)"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Test health check function
if ($connectionParams) {
    Write-Host "Running comprehensive health check..."
    $healthReport = Get-DatabaseHealthReport -KeyVaultName $keyVaultName
    
    if ($healthReport.OverallHealth) {
        Write-Host "Health check completed!" -ForegroundColor Green
        Write-Host "  Server: $($healthReport.ServerName)"
        Write-Host "  Overall Health: $($healthReport.OverallHealth) ($($healthReport.HealthPercentage)%)"
        Write-Host "  Generated: $($healthReport.GeneratedOn)"
        
        Write-Host "`nHealth Check Summary:"
        foreach ($check in $healthReport.Checks.Keys) {
            $status = $healthReport.Checks[$check].Status
            $color = switch ($status) {
                "Healthy" { "Green" }
                "Warning" { "Yellow" }
                "Critical" { "Red" }
                default { "White" }
            }
            Write-Host "  $check : $status" -ForegroundColor $color
        }
    }
}

# =============================================================================
# CLEANUP AND SESSION MANAGEMENT - SOLUTIONS
# =============================================================================
Write-Host "`n=== CLEANUP AND SESSION MANAGEMENT ===" -ForegroundColor Green

function Complete-DbaSession {
    param(
        [string]$KeyVaultName
    )
    
    try {
        Write-Host "Completing DBA session cleanup..." -ForegroundColor Cyan
        
        # 1. Clear any cached credentials
        Write-Host "1. Clearing cached credentials..."
        $credentialVars = Get-Variable -Name "*credential*", "*password*" -ErrorAction SilentlyContinue
        foreach ($var in $credentialVars) {
            Remove-Variable -Name $var.Name -Force -ErrorAction SilentlyContinue
        }
        
        # 2. Close database connections (dbatools doesn't maintain persistent connections)
        Write-Host "2. Clearing SQL connection pools..."
        [System.Data.SqlClient.SqlConnection]::ClearAllPools()
        
        # 3. Clear sensitive variables
        Write-Host "3. Clearing session variables..."
        $sensitiveVars = @('connectionParams', 'keyVaultName')
        foreach ($varName in $sensitiveVars) {
            if (Get-Variable -Name $varName -ErrorAction SilentlyContinue) {
                Remove-Variable -Name $varName -Scope Global -Force -ErrorAction SilentlyContinue
            }
        }
        
        # 4. Log session end
        Write-Host "4. Session completed at: $(Get-Date)"
        
        # 5. Optionally disconnect from Azure
        $azContext = Get-AzContext
        if ($azContext) {
            Write-Host "5. Azure context still active. To disconnect, run: Disconnect-AzAccount"
        }
        
        Write-Host "DBA session cleanup completed successfully" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Error "Session cleanup failed: $($_.Exception.Message)"
        return $false
    }
}

# Execute cleanup
$cleanupResult = Complete-DbaSession -KeyVaultName $keyVaultName
if ($cleanupResult) {
    Write-Host "Session cleanup completed" -ForegroundColor Green
}

