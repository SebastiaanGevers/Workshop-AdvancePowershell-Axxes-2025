# DBA Tools Certificate Fix

## 🔧 Quick Fix for "Certificate failed chain validation" Error

If you're getting this error when using dbatools:
```
Get-DbaDatabase] Failure | Certificate failed chain validation
```

## ⚡ Quick Solution

Run this command first:
```powershell
# Fix certificate validation issues
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false
```

Then test your connection:
```powershell
$cred = Get-Credential -UserName "sa" -Message "Enter SA password: DBATools2024!"
Get-DbaDatabase -SqlInstance sqlserver -SqlCredential $cred -TrustServerCertificate
```

## 🔍 Alternative Solutions

### Option 1: Use TrustServerCertificate Parameter
```powershell
Get-DbaDatabase -SqlInstance sqlserver -SqlCredential $cred -TrustServerCertificate
```

### Option 2: Connection String Method
```powershell
$connString = "Server=sqlserver;User Id=sa;Password=DBATools2024!;TrustServerCertificate=true;"
Invoke-DbaQuery -SqlInstance $connString -Query "SELECT @@VERSION"
```

### Option 3: Alternative Server Names
```powershell
# Try localhost instead of sqlserver
Get-DbaDatabase -SqlInstance "localhost,1433" -SqlCredential $cred -TrustServerCertificate

# Or try IP address
Get-DbaDatabase -SqlInstance "127.0.0.1,1433" -SqlCredential $cred -TrustServerCertificate
```

## 🚀 For the Complete Fix Script

Run this file for comprehensive troubleshooting:
```powershell
.\.devcontainer\fix-certificate-issues.ps1
Set-QuickFix
```

This issue occurs because SQL Server containers use self-signed certificates that don't pass standard certificate validation. The solutions above bypass this validation safely for development environments.