# Environment Validation Script
# Run this to verify the DBA tools workshop environment is working correctly

Write-Host "🔍 Validating DBA Tools Workshop Environment..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if dbatools module is available
Write-Host "1️⃣ Checking dbatools module..." -ForegroundColor Yellow
try {
    Import-Module dbatools -ErrorAction Stop
    $dbatoolsVersion = (Get-Module dbatools).Version
    Write-Host "   ✅ dbatools $dbatoolsVersion loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to load dbatools module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Check SQL Server container status
Write-Host "2️⃣ Checking SQL Server container..." -ForegroundColor Yellow
try {
    $containerStatus = docker ps --filter "name=sqlserver-workshop" --format "table {{.Status}}"
    if ($containerStatus -match "Up") {
        Write-Host "   ✅ SQL Server container is running" -ForegroundColor Green
    } else {
        Write-Host "   ❌ SQL Server container is not running" -ForegroundColor Red
        Write-Host "   📝 Try running: docker start sqlserver-workshop" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ❌ Failed to check container status: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Test database connection
Write-Host "3️⃣ Testing database connection..." -ForegroundColor Yellow
try {
    # Create secure credential
    $password = ConvertTo-SecureString "Workshop2024!" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential("sa", $password)
    
    # Wait a moment for SQL Server to be fully ready
    Start-Sleep -Seconds 5
    
    # Test connection with certificate trust
    $testResult = Test-DbaConnection -SqlInstance localhost -SqlCredential $cred -TrustServerCertificate
    
    if ($testResult.ConnectSuccess) {
        Write-Host "   ✅ Database connection successful" -ForegroundColor Green
        Write-Host "   📊 SQL Server Version: $($testResult.SqlVersion)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Database connection failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   💡 SQL Server might still be starting up. Wait 30 seconds and try again." -ForegroundColor Yellow
    exit 1
}

# Test 4: Check if sample databases exist
Write-Host "4️⃣ Checking sample databases..." -ForegroundColor Yellow
try {
    $databases = Get-DbaDatabase -SqlInstance localhost -SqlCredential $cred -TrustServerCertificate
    $workshopDb = $databases | Where-Object { $_.Name -eq "WorkshopDB" }
    
    if ($workshopDb) {
        Write-Host "   ✅ WorkshopDB found" -ForegroundColor Green
        
        # Check for sample data
        $employeeCount = Invoke-DbaQuery -SqlInstance localhost -SqlCredential $cred -Database WorkshopDB -TrustServerCertificate -Query "SELECT COUNT(*) as Count FROM Employees"
        Write-Host "   📈 Employee records: $($employeeCount.Count)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ WorkshopDB not found" -ForegroundColor Red
        Write-Host "   💡 Run create-workshop-db.ps1 to create sample databases" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Failed to check databases: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test a few common dbatools commands
Write-Host "5️⃣ Testing key dbatools commands..." -ForegroundColor Yellow
try {
    # Test database listing
    $dbCount = (Get-DbaDatabase -SqlInstance localhost -SqlCredential $cred -TrustServerCertificate).Count
    Write-Host "   ✅ Get-DbaDatabase: Found $dbCount databases" -ForegroundColor Green
    
    # Test backup history
    $backupHistory = Get-DbaDbBackupHistory -SqlInstance localhost -SqlCredential $cred -TrustServerCertificate | Select-Object -First 1
    Write-Host "   ✅ Get-DbaDbBackupHistory: Command executed successfully" -ForegroundColor Green
    
    # Test space usage
    $spaceInfo = Get-DbaDbSpace -SqlInstance localhost -SqlCredential $cred -TrustServerCertificate | Select-Object -First 1
    Write-Host "   ✅ Get-DbaDbSpace: Command executed successfully" -ForegroundColor Green
    
} catch {
    Write-Host "   ⚠️ Some dbatools commands may have issues: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Environment Validation Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📖 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open DBA-TOOLS-WORKSHOP-GUIDE.md for exercises"
Write-Host "   2. Start with Exercise 1: Basic Connection and Discovery"
Write-Host "   3. Use the credential: sa / Workshop2024!"
Write-Host ""
Write-Host "🔧 If you encounter issues:" -ForegroundColor Yellow
Write-Host "   • Check that Docker is running"
Write-Host "   • Restart SQL Server: docker restart sqlserver-workshop"
Write-Host "   • Re-create databases: .\.devcontainer\create-workshop-db.ps1"
Write-Host ""