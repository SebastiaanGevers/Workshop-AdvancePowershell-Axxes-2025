# PowerShell Performance Analysis - Deliberately Slow Code Sample
# Workshop 2025 - Axxes
# This script contains intentionally inefficient code patterns for profiler demonstration
# Install-Module Profiler
# $Temp = Trace-Script -ScriptBlock {& .\Demeo\Profiler.ps1}


Write-Host "=== PowerShell Performance Analysis - Slow Code Sample ===" -ForegroundColor Red
Write-Host "This script demonstrates common performance anti-patterns for profiler analysis" -ForegroundColor Yellow

# =============================================================================
# SLOW PATTERN 1: Dynamic Array Growth (Quadratic Performance)
# =============================================================================
function Test-SlowArrayGrowth {
    param([int]$Size = 5000)
    
    Write-Host "1. Testing Dynamic Array Growth (Very Slow!)..." -ForegroundColor Red
    
    $dynamicArray = @()
    $startTime = Get-Date
    
    # This creates a new array every time += is used!
    for ($i = 1; $i -le $Size; $i++) {
        $dynamicArray += [PSCustomObject]@{
            Id = $i
            Name = "User$i"
            Email = "user$i@example.com"
            Department = switch ($i % 4) {
                0 { "IT" }
                1 { "HR" }
                2 { "Finance" }
                3 { "Marketing" }
            }
            Salary = Get-Random -Minimum 30000 -Maximum 120000
        }
        
        # Show progress for long operations
        if ($i % 1000 -eq 0) {
            Write-Host "  Created $i objects..." -NoNewline
            Write-Host " Array size: $($dynamicArray.Count)" -ForegroundColor Cyan
        }
    }
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Completed in $duration ms" -ForegroundColor Red
    
    return $dynamicArray
}

# =============================================================================
# SLOW PATTERN 2: Multiple Pipeline Filters
# =============================================================================
function Test-SlowPipelineFilters {
    param([array]$Data)
    
    Write-Host "2. Testing Multiple Pipeline Filters (Inefficient)..." -ForegroundColor Red
    
    $startTime = Get-Date
    
    # Multiple Where-Object calls instead of combining conditions
    $result = $Data | 
              Where-Object { $_.Department -eq "IT" } |
              Where-Object { $_.Salary -gt 50000 } |
              Where-Object { $_.Id % 2 -eq 0 } |
              Where-Object { $_.Name -match "User\d+" } |
              Sort-Object Salary |
              Select-Object Id, Name, Email, Salary
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Found $($result.Count) matching records in $duration ms" -ForegroundColor Red
    
    return $result
}

# =============================================================================
# SLOW PATTERN 3: Regex Compilation in Loop
# =============================================================================
function Test-SlowRegexInLoop {
    param([array]$Data)
    
    Write-Host "3. Testing Regex Compilation in Loop (Very Inefficient)..." -ForegroundColor Red
    
    $startTime = Get-Date
    $validEmails = @()
    
    foreach ($user in $Data) {
        # Regex is compiled on every iteration!
        if ($user.Email -match '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') {
            $validEmails += $user.Email
        }
        
        # Additional expensive regex operations
        if ($user.Name -match '^User(\d+)$') {
            $user | Add-Member -NotePropertyName "UserNumber" -NotePropertyValue $matches[1] -Force
        }
        
        # More regex patterns compiled repeatedly
        if ($user.Department -match '^(IT|HR)$') {
            $user | Add-Member -NotePropertyName "TechDepartment" -NotePropertyValue $true -Force
        }
    }
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Validated $($validEmails.Count) emails in $duration ms" -ForegroundColor Red
    
    return $validEmails
}

# =============================================================================
# SLOW PATTERN 4: Inefficient String Operations
# =============================================================================
function Test-SlowStringOperations {
    param([array]$Data)
    
    Write-Host "4. Testing Inefficient String Operations..." -ForegroundColor Red
    
    $startTime = Get-Date
    $report = ""
    
    foreach ($user in $Data) {
        # String concatenation creates new string each time
        $report += "User: $($user.Name)`n"
        $report += "Email: $($user.Email)`n"
        $report += "Department: $($user.Department)`n"
        $report += "Salary: $($user.Salary)`n"
        $report += "---`n"
        
        # More expensive string operations
        $upperName = $user.Name.ToUpper()
        $lowerEmail = $user.Email.ToLower()
        $formattedSalary = $user.Salary.ToString("C")
        
        # Unnecessary string replacements in loop
        $cleanName = $user.Name.Replace("User", "Employee").Replace("0", "Zero").Replace("1", "One")
    }
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Generated report with $($report.Length) characters in $duration ms" -ForegroundColor Red
    
    return $report
}

# =============================================================================
# SLOW PATTERN 5: Nested Loops with Inefficient Lookups
# =============================================================================
function Test-SlowNestedLoops {
    param([array]$Data)
    
    Write-Host "5. Testing Nested Loops with Inefficient Lookups..." -ForegroundColor Red
    
    $startTime = Get-Date
    $departments = @("IT", "HR", "Finance", "Marketing")
    $results = @()
    
    foreach ($dept in $departments) {
        $deptEmployees = @()
        
        # Inefficient: Searching entire array for each department
        foreach ($user in $Data) {
            if ($user.Department -eq $dept) {
                $deptEmployees += $user
                
                # Additional nested loop for comparison
                $sameDepTCount = 0
                foreach ($otherUser in $Data) {
                    if ($otherUser.Department -eq $dept) {
                        $sameDepTCount++
                    }
                }
                
                $user | Add-Member -NotePropertyName "DepartmentSize" -NotePropertyValue $sameDepTCount -Force
            }
        }
        
        # More inefficient operations
        $avgSalary = 0
        foreach ($emp in $deptEmployees) {
            $avgSalary += $emp.Salary
        }
        if ($deptEmployees.Count -gt 0) {
            $avgSalary = $avgSalary / $deptEmployees.Count
        }
        
        $results += [PSCustomObject]@{
            Department = $dept
            EmployeeCount = $deptEmployees.Count
            AverageSalary = $avgSalary
        }
    }
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Processed $($departments.Count) departments in $duration ms" -ForegroundColor Red
    
    return $results
}

# =============================================================================
# SLOW PATTERN 6: Expensive File Operations in Loop
# =============================================================================
function Test-SlowFileOperations {
    param([array]$Data)
    
    Write-Host "6. Testing Expensive File Operations in Loop..." -ForegroundColor Red
    
    $startTime = Get-Date
    $tempDir = Join-Path $env:TEMP "SlowPowerShellTest"
    
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    foreach ($user in $Data[0..100]) {  # Limit to first 100 to avoid too many files
        # Individual file creation for each user (very inefficient)
        $userFile = Join-Path $tempDir "User_$($user.Id).txt"
        $content = "User: $($user.Name)`nEmail: $($user.Email)`nDepartment: $($user.Department)`nSalary: $($user.Salary)"
        
        # Write to file
        Set-Content -Path $userFile -Value $content
        
        # Read it back immediately (unnecessary)
        $readContent = Get-Content -Path $userFile
        
        # Check if file exists (redundant)
        if (Test-Path $userFile) {
            $fileInfo = Get-Item $userFile
            $user | Add-Member -NotePropertyName "FileSize" -NotePropertyValue $fileInfo.Length -Force
        }
    }
    
    # Cleanup
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Created and processed 100 files in $duration ms" -ForegroundColor Red
}

# =============================================================================
# SLOW PATTERN 7: Inefficient Object Creation with ForEach-Object
# =============================================================================
function Test-SlowObjectCreation {
    param([int]$Count = 2000)
    
    Write-Host "7. Testing Inefficient Object Creation with ForEach-Object..." -ForegroundColor Red
    
    $startTime = Get-Date
    
    # Using ForEach-Object instead of foreach for object creation (slower)
    $numbers = 1..$Count
    $objects = $numbers | ForEach-Object {
        [PSCustomObject]@{
            Number = $_
            Square = $_ * $_
            Cube = $_ * $_ * $_
            IsEven = $_ % 2 -eq 0
            IsPrime = Test-IsPrime $_  # Expensive calculation
            Factorial = Get-Factorial $_  # Very expensive calculation
        }
    }
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    Write-Host "  Created $($objects.Count) complex objects in $duration ms" -ForegroundColor Red
    
    return $objects
}

# Helper function: Inefficient prime checking
function Test-IsPrime {
    param([int]$Number)
    
    if ($Number -le 1) { return $false }
    if ($Number -eq 2) { return $true }
    
    # Inefficient algorithm - checks all numbers up to n
    for ($i = 2; $i -lt $Number; $i++) {
        if ($Number % $i -eq 0) { return $false }
    }
    return $true
}

# Helper function: Inefficient factorial calculation
function Get-Factorial {
    param([int]$Number)
    
    if ($Number -le 1) { return 1 }
    
    # Inefficient recursive approach without memoization
    return $Number * (Get-Factorial ($Number - 1))
}

# =============================================================================
# MAIN EXECUTION - Run All Slow Patterns
# =============================================================================
function Start-SlowCodeAnalysis {
    Write-Host "=== Starting Slow Code Analysis ===" -ForegroundColor Yellow
    Write-Host "This will take several minutes to complete..." -ForegroundColor Yellow
    
    $totalStart = Get-Date
    
    # Pattern 1: Dynamic Array Growth
    $userData = Test-SlowArrayGrowth -Size 3000
    
    # Pattern 2: Multiple Pipeline Filters  
    $filteredData = Test-SlowPipelineFilters -Data $userData
    
    # Pattern 3: Regex in Loop
    $validEmails = Test-SlowRegexInLoop -Data $userData
    
    # Pattern 4: String Operations
    $report = Test-SlowStringOperations -Data $filteredData
    
    # Pattern 5: Nested Loops
    $deptStats = Test-SlowNestedLoops -Data $userData
    
    # Pattern 6: File Operations
    Test-SlowFileOperations -Data $userData
    
    # Pattern 7: Object Creation
    $complexObjects = Test-SlowObjectCreation -Count 1000
    
    $totalEnd = Get-Date
    $totalDuration = ($totalEnd - $totalStart).TotalSeconds
    
    Write-Host "=== Analysis Complete ===" -ForegroundColor Green
    Write-Host "Total execution time: $totalDuration seconds" -ForegroundColor Green
    Write-Host "1. Install Profiler Module:" -ForegroundColor Yellow
    Write-Host "   Install-Module -Name Profiler -Force" -ForegroundColor White
    Write-Host "2. Profile this script:" -ForegroundColor Yellow
    Write-Host "   Import-Module Profiler" -ForegroundColor White
    Write-Host "Now run the PowerShell Profiler to analyze performance bottlenecks!" -ForegroundColor Cyan
    Write-Host "Example: $Temp = Trace-Script { .\Profiler.ps1 }" -ForegroundColor Cyan
}

# Uncomment the line below to run the analysis automatically
Start-SlowCodeAnalysis
