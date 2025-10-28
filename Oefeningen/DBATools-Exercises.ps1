# PowerShell DBA Tools Workshop - Exercises
# Workshop 2025 - Axxes
# This workshop builds on the Secure Passwords exercises where Azure Key Vault credentials were set up

# =============================================================================
# PREREQUISITES
# =============================================================================
# Before starting this workshop, ensure you have completed:
# 1. SecurePasswords-Exercises.ps1 (Azure Key Vault setup with database credentials)
# 2. The following secrets should exist in your Azure Key Vault:
#    - DB-Username: Database username (e.g., "sa")
#    - DB-Password: Database password
#    - DB-Server: Database server connection string (e.g., "localhost" or server name)
#    - Access to a SQL Server instance (local or remote)

# =============================================================================
# OEFENING 1: Module Installation and Verification
# =============================================================================
# TODO: Check if the dbatools module is installed
# If not installed, you'll need to install it: Install-Module dbatools -Force

# Your code here:


# TODO: Check if Azure modules are available (Az.Accounts, Az.KeyVault)
# These should be available from the SecurePasswords exercises

# Your code here:


# TODO: Import the required modules and display their versions

# Your code here:


# TODO: Get a count of available dbatools commands to verify the module is working
# Hint: Use Get-Command -Module dbatools

# Your code here:


# =============================================================================
# OEFENING 2: Azure Key Vault Connection Setup
# =============================================================================
# TODO: Connect to Azure if not already connected
# Hint: Check Get-AzContext first

# Your code here:


# TODO: Set your Key Vault name (use the same one from SecurePasswords exercises)
$keyVaultName = "your-keyvault-name-here"  # Replace with your actual Key Vault name

# TODO: Test access to your Key Vault by listing the secrets
# Verify that DB-Username, DB-Password, and DB-Server exist

# Your code here:


# =============================================================================
# OEFENING 3: Secure Database Connection Function
# =============================================================================
# TODO: Create a function to retrieve database connection parameters from Azure Key Vault
# This function should return a hashtable that can be used with dbatools commands

function Get-DbaConnectionFromKeyVault {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName
    )
    
    # Your code here:
    # 1. Retrieve the three secrets from Key Vault
    # 2. Create a PSCredential object
    # 3. Return a hashtable with SqlInstance and SqlCredential
    
}

# TODO: Test your function
# Call the function and verify it returns the correct connection parameters

# Your code here:


# =============================================================================
# OEFENING 4: Basic Database Connectivity Testing
# =============================================================================
# TODO: Use Test-DbaConnection to verify you can connect to your database
# Use the connection parameters from your function

# Your code here:


# TODO: Create a comprehensive connection test function that includes error handling
function Test-SecureDatabaseConnection {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName
    )
    
    # Your code here:
    # 1. Get connection parameters
    # 2. Test the connection
    # 3. Return detailed connection information
    # 4. Include proper error handling
    
}

# TODO: Test your comprehensive connection function

# Your code here:


# =============================================================================
# OEFENING 5: Database Discovery and Information Gathering
# =============================================================================
# TODO: Use Get-DbaDatabase to list all databases on your server
# Use the secure connection from your Key Vault

# Your code here:


# TODO: Get detailed information about your SQL Server instance
# Hint: Use Get-DbaInstanceProperty

# Your code here:


# TODO: Check disk space usage for all databases
# Hint: Use Get-DbaDbSpace

# Your code here:


# TODO: Get information about database files and their growth settings
# Hint: Use Get-DbaDbFile

# Your code here:


# =============================================================================
# OEFENING 6: Database Security Analysis
# =============================================================================
# TODO: List all database logins and their properties
# Hint: Use Get-DbaLogin

# Your code here:


# TODO: Check for users in each database
# Hint: Use Get-DbaUser for each database

# Your code here:


# TODO: Identify members of the sysadmin server role
# Hint: Use Get-DbaServerRoleMember

# Your code here:


# TODO: Check for databases with simple recovery model (potential security concern)

# Your code here:


# =============================================================================
# OEFENING 7: Performance Monitoring and Analysis
# =============================================================================
# TODO: Get current wait statistics to identify performance bottlenecks
# Hint: Use Get-DbaWaitStatistic

# Your code here:


# TODO: Check for currently running queries
# Hint: Use Get-DbaRunningQuery

# Your code here:


# TODO: Look for blocking processes
# Hint: Use Get-DbaBlocking

# Your code here:


# TODO: Get CPU utilization information
# Hint: Use Get-DbaComputerSystem

# Your code here:


# =============================================================================
# OEFENING 8: Backup Operations with Secure Credentials
# =============================================================================
# TODO: Create a secure backup function that uses Azure Key Vault credentials
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
    
    # Your code here:
    # 1. Get connection parameters from Key Vault
    # 2. Verify database exists
    # 3. Create backup directory if it doesn't exist
    # 4. Perform the backup
    # 5. Verify backup was successful
    # 6. Return backup information
    
}

# TODO: Test your backup function (use a small database like 'master' for testing)
# Be careful about disk space!

# Your code here:


# =============================================================================
# OEFENING 9: Database Maintenance Automation
# =============================================================================
# TODO: Create a function to update database statistics using secure credentials
function Update-DatabaseStatistics {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [Parameter(Mandatory)]
        [string]$DatabaseName
    )
    
    # Your code here:
    # 1. Get connection parameters
    # 2. Update statistics for the specified database
    # 3. Return results
    
}

# TODO: Create a function to check and rebuild fragmented indexes
function Optimize-DatabaseIndexes {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [Parameter(Mandatory)]
        [string]$DatabaseName,
        [int]$FragmentationThreshold = 30
    )
    
    # Your code here:
    # 1. Get connection parameters
    # 2. Check index fragmentation
    # 3. Rebuild indexes above threshold
    # 4. Return optimization results
    
}

# TODO: Test your maintenance functions

# Your code here:


# =============================================================================
# OEFENING 10: Comprehensive Database Health Check
# =============================================================================
# TODO: Create a comprehensive health check function that combines multiple checks
function Get-DatabaseHealthReport {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [string]$DatabaseName = $null  # If null, check all databases
    )
    
    # Your code here:
    # Create a comprehensive health check that includes:
    # 1. Connection test
    # 2. Database status
    # 3. Disk space usage
    # 4. Backup status (last backup dates)
    # 5. Index fragmentation summary
    # 6. Growth events
    # 7. Error log entries (recent)
    # 8. Security issues
    # Return a detailed report object
    
}

# TODO: Test your health check function

# Your code here:


# =============================================================================
# OEFENING 11: Error Handling and Logging
# =============================================================================
# TODO: Create a wrapper function that adds comprehensive logging to any DBA operation
function Invoke-SecureDbaOperation {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [Parameter(Mandatory)]
        [scriptblock]$Operation,
        [string]$OperationName = "DatabaseOperation",
        [string]$LogPath = "C:\Temp\DBALogs"
    )
    
    # Your code here:
    # 1. Set up logging directory
    # 2. Get connection parameters from Key Vault
    # 3. Execute the operation with try/catch
    # 4. Log all activities (start, success, errors)
    # 5. Return operation results with status
    
}

# TODO: Test your logging wrapper with different operations
# Example: Test with a simple database query

# Your code here:


# =============================================================================
# OEFENING 12: Advanced Monitoring and Alerting Setup
# =============================================================================
# TODO: Create a function to monitor critical database metrics
function Start-DatabaseMonitoring {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [int]$IntervalSeconds = 60,
        [int]$DurationMinutes = 5
    )
    
    # Your code here:
    # 1. Set up monitoring loop
    # 2. Collect metrics every interval:
    #    - CPU usage
    #    - Memory usage
    #    - Disk space
    #    - Active connections
    #    - Blocking processes
    #    - Wait statistics
    # 3. Save metrics to file or display
    # 4. Alert on thresholds
    
}

# TODO: Create threshold-based alerting
function Test-DatabaseThresholds {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [int]$CpuThreshold = 80,
        [int]$DiskSpaceThreshold = 85,
        [int]$BlockingThreshold = 5
    )
    
    # Your code here:
    # Check current metrics against thresholds
    # Return alert information if thresholds exceeded
    
}

# TODO: Test your monitoring functions (use short duration for testing)

# Your code here:


# =============================================================================
# OEFENING 13: Disaster Recovery Preparation
# =============================================================================
# TODO: Create a function to document current database configuration
function Export-DatabaseConfiguration {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [string]$ExportPath = "C:\Temp\DR_Documentation"
    )
    
    # Your code here:
    # Document and export:
    # 1. Database list and properties
    # 2. Login information
    # 3. Database file locations and sizes
    # 4. Backup locations and schedules
    # 5. Instance configuration
    # Save as JSON or XML for disaster recovery
    
}

# TODO: Create a function to validate backup files
function Test-DatabaseBackups {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [string]$BackupPath = "C:\Temp\Backups"
    )
    
    # Your code here:
    # 1. Find all backup files
    # 2. Verify each backup file integrity
    # 3. Check backup dates
    # 4. Report on backup status
    
}

# TODO: Test your disaster recovery functions

# Your code here:


# =============================================================================
# OEFENING 14: Automation and Scheduling
# =============================================================================
# TODO: Create a daily maintenance script that uses your secure functions
function Start-DailyMaintenance {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [string[]]$DatabaseNames = @(),  # Empty means all databases
        [switch]$WhatIf
    )
    
    # Your code here:
    # Create a comprehensive daily maintenance routine:
    # 1. Health check all databases
    # 2. Update statistics for user databases
    # 3. Check index fragmentation
    # 4. Verify recent backups
    # 5. Check disk space
    # 6. Review error logs
    # 7. Generate summary report
    # Use WhatIf to show what would be done without executing
    
}

# TODO: Create a function to generate maintenance reports
function New-MaintenanceReport {
    param(
        [Parameter(Mandatory)]
        [object[]]$MaintenanceResults,
        [string]$ReportPath = "C:\Temp\Reports",
        [switch]$EmailReport
    )
    
    # Your code here:
    # 1. Generate HTML or text report
    # 2. Include charts/graphs if possible
    # 3. Optionally email the report
    # 4. Archive old reports
    
}

# TODO: Test your automation functions with WhatIf

# Your code here:


# =============================================================================
# OEFENING 15: Security Audit and Compliance
# =============================================================================
# TODO: Create a comprehensive security audit function
function Start-DatabaseSecurityAudit {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [string]$AuditReportPath = "C:\Temp\SecurityAudit"
    )
    
    # Your code here:
    # Perform security audit checking:
    # 1. Weak passwords (if possible to detect)
    # 2. Unnecessary permissions
    # 3. Disabled logins that should be removed
    # 4. Databases with weak recovery models
    # 5. Unencrypted connections
    # 6. Missing security updates
    # 7. Audit trail configuration
    # Generate compliance report
    
}

# TODO: Create a function to check for compliance with security standards
function Test-DatabaseCompliance {
    param(
        [Parameter(Mandatory)]
        [string]$KeyVaultName,
        [ValidateSet("CIS", "NIST", "Custom")]
        [string]$Standard = "CIS"
    )
    
    # Your code here:
    # Check against security standards
    # Return compliance score and recommendations
    
}

# TODO: Test your security audit functions

# Your code here:


# =============================================================================
# CLEANUP AND SESSION MANAGEMENT
# =============================================================================
# TODO: Create a function to clean up the session securely
function Complete-DbaSession {
    param(
        [string]$KeyVaultName
    )
    
    # Your code here:
    # 1. Clear any cached credentials
    # 2. Close database connections
    # 3. Clear sensitive variables
    # 4. Log session end
    # 5. Optionally disconnect from Azure
    
}

# TODO: Execute cleanup

# Your code here:

