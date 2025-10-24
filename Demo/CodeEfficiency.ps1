# PowerShell Code Efficiency - Pipelining Examples

#region Inefficient Pipelining
Write-Host "`n=== Inefficient Pipelining ===" -ForegroundColor Yellow

# Example 1: Multiple pipeline operations that could be combined
Measure-Command {
    $result = Get-Process | Where-Object { $_.WorkingSet64 -gt 100MB } | 
              Select-Object Name, Id, WorkingSet64 | 
              Sort-Object WorkingSet64 -Descending
}

# Example 2: Using ForEach-Object when not needed
Measure-Command {
    $numbers = 1..1000
    $doubled = $numbers | ForEach-Object { $_ * 2 }
}

# Example 3: Multiple Where-Object filters
Measure-Command {
    $processes = Get-Process | 
                 Where-Object { $_.WorkingSet64 -gt 50MB } | 
                 Where-Object { $_.CPU -gt 10 }
}

#endregion

#region Efficient Pipelining
Write-Host "`n=== Efficient Pipelining ===" -ForegroundColor Green

# Example 1: Combine filters into single Where-Object
Measure-Command {
    $result = Get-Process | 
              Where-Object { $_.WorkingSet64 -gt 100MB } | 
              Sort-Object WorkingSet64 -Descending |
              Select-Object Name, Id, WorkingSet64
}

# Example 2: Use array operations instead of ForEach-Object
Measure-Command {
    $numbers = 1..1000
    $doubled = $numbers.ForEach({ $_ * 2 })  # Faster intrinsic method
}

# Example 3: Combine conditions in single Where-Object
Measure-Command {
    $processes = Get-Process | 
                 Where-Object { $_.WorkingSet64 -gt 50MB -and $_.CPU -gt 10 }
}

# Example 4: Use -Filter parameter instead of Where-Object (when available)
Measure-Command {
    # Inefficient
    $files = Get-ChildItem -Path C:\Windows -Recurse -ErrorAction SilentlyContinue | 
             Where-Object { $_.Extension -eq '.log' }
}

Measure-Command {
    # Efficient
    $files = Get-ChildItem -Path C:\Windows -Filter *.log -Recurse -ErrorAction SilentlyContinue
}

#endregion

#region Best Practices
Write-Host "`n=== Pipelining Best Practices ===" -ForegroundColor Cyan

# 1. Filter early in the pipeline
# Bad: Sort first, then filter
$bad = Get-Process | Sort-Object WorkingSet64 | Where-Object { $_.WorkingSet64 -gt 100MB }

# Good: Filter first, then sort
$good = Get-Process | Where-Object { $_.WorkingSet64 -gt 100MB } | Sort-Object WorkingSet64

# 2. Use foreach loop instead of ForEach-Object for complex operations
$collection = 1..10000

# Slower
Measure-Command {
    $result = $collection | ForEach-Object { 
        [PSCustomObject]@{
            Number = $_
            Square = $_ * $_
            Cube   = $_ * $_ * $_
        }
    }
}

# Faster
Measure-Command {
    $result = foreach ($item in $collection) {
        [PSCustomObject]@{
            Number = $item
            Square = $item * $item
            Cube   = $item * $item * $item
        }
    }
}
<#
ForEach-Object: Indirect access through pipeline
$collection | ForEach-Object { 
    # PowerShell must:
    # 1. Pull object from pipeline
    # 2. Set $_ automatic variable
    # 3. Execute script block
    # 4. Pass result to next pipeline stage
}

foreach: Direct memory access
foreach ($item in $collection) {
    # PowerShell directly:
    # 1. Accesses object from collection
    # 2. Assigns to $item variable
    # 3. Executes code block
}
#>

# 3. Avoid unnecessary pipeline operations
# Don't use pipeline if you don't need streaming
$inefficient = 1..100 | Measure-Object -Sum
$efficient = (1..100 | Measure-Object -Sum).Sum

#endregion

Write-Host "`nPipelining efficiency examples completed!" -ForegroundColor Green

#region Loop Efficiency
Write-Host "`n=== Loop Efficiency Demonstrations ===" -ForegroundColor Magenta

# =============================================================================
# Loop Type Comparisons - Performance Analysis
# =============================================================================

$testData = 1..10000
$results = @{}

Write-Host "`n--- Comparing Different Loop Types ---" -ForegroundColor Yellow

# Traditional For Loop
Write-Host "Testing traditional for loop..." -NoNewline
$results['ForLoop'] = Measure-Command {
    $sum = 0
    for ($i = 0; $i -lt $testData.Count; $i++) {
        $sum += $testData[$i]
    }
}
Write-Host " Completed in $($results['ForLoop'].TotalMilliseconds)ms"

# ForEach Loop
Write-Host "Testing foreach loop..." -NoNewline
$results['ForEachLoop'] = Measure-Command {
    $sum = 0
    foreach ($item in $testData) {
        $sum += $item
    }
}
Write-Host " Completed in $($results['ForEachLoop'].TotalMilliseconds)ms"

# ForEach-Object Pipeline
Write-Host "Testing ForEach-Object pipeline..." -NoNewline
$results['ForEachObject'] = Measure-Command {
    $sum = 0
    $testData | ForEach-Object { $sum += $_ }
}
Write-Host " Completed in $($results['ForEachObject'].TotalMilliseconds)ms"

# Array ForEach Method (Fastest)
Write-Host "Testing array .ForEach() method..." -NoNewline
$results['ArrayForEach'] = Measure-Command {
    $sum = 0
    $testData.ForEach({ $sum += $_ })
}
Write-Host " Completed in $($results['ArrayForEach'].TotalMilliseconds)ms"

# While Loop
Write-Host "Testing while loop..." -NoNewline
$results['WhileLoop'] = Measure-Command {
    $sum = 0
    $i = 0
    while ($i -lt $testData.Count) {
        $sum += $testData[$i]
        $i++
    }
}
Write-Host " Completed in $($results['WhileLoop'].TotalMilliseconds)ms"

# Display Results
Write-Host "`n--- Performance Comparison Results ---" -ForegroundColor Cyan
$sortedResults = $results.GetEnumerator() | Sort-Object { $_.Value.TotalMilliseconds }
foreach ($result in $sortedResults) {
    $performance = switch ($result.Name) {
        { $_ -eq $sortedResults[0].Name } { "🥇 Fastest" }
        { $_ -eq $sortedResults[1].Name } { "🥈 Second" }
        { $_ -eq $sortedResults[-1].Name } { "🐌 Slowest" }
        default { "   Normal" }
    }
    Write-Host "$performance - $($result.Name): $($result.Value.TotalMilliseconds)ms"
}

# =============================================================================
# Loop Optimization Techniques
# =============================================================================

Write-Host "`n--- Loop Optimization Techniques ---" -ForegroundColor Yellow

# 1. Pre-allocating Collections
Write-Host "`n1. Collection Pre-allocation vs Dynamic Growth"

# Inefficient: Dynamic array growth
Write-Host "Dynamic growth..." -NoNewline
$dynamicTime = Measure-Command {
    $dynamicArray = @()
    for ($i = 1; $i -le 5000; $i++) {
        $dynamicArray += $i * 2
    }
}
Write-Host " $($dynamicTime.TotalMilliseconds)ms"

# Efficient: Pre-allocated array
Write-Host "Pre-allocated array..." -NoNewline
$preallocTime = Measure-Command {
    $prealloc = New-Object System.Collections.Generic.List[int] 5000
    for ($i = 1; $i -le 5000; $i++) {
        $prealloc.Add($i * 2)
    }
}
Write-Host " $($preallocTime.TotalMilliseconds)ms"

Write-Host "Pre-allocation is $([math]::Round($dynamicTime.TotalMilliseconds / $preallocTime.TotalMilliseconds, 2))x faster!"

# 2. Avoiding Expensive Operations in Loops
Write-Host "`n2. Moving Expensive Operations Outside Loops"

$testCollection = 1..1000

# Inefficient: Regex compilation in loop
Write-Host "Regex compilation inside loop..." -NoNewline
$inefficientRegex = Measure-Command {
    $matches = foreach ($item in $testCollection) {
        if ($item -match '^\d{1,3}$') { $item }
    }
}
Write-Host " $($inefficientRegex.TotalMilliseconds)ms"

# Efficient: Pre-compiled regex
Write-Host "Pre-compiled regex..." -NoNewline
$efficientRegex = Measure-Command {
    $regex = [regex]'^\d{1,3}$'
    $matches = foreach ($item in $testCollection) {
        if ($regex.IsMatch($item.ToString())) { $item }
    }
}
Write-Host " $($efficientRegex.TotalMilliseconds)ms"

# 3. Loop Unrolling for Small, Fixed Iterations
Write-Host "`n3. Loop Unrolling for Small Operations"

$numbers = 1..4

# Standard loop
Write-Host "Standard loop..." -NoNewline
$standardLoop = Measure-Command {
    1..10000 | ForEach-Object {
        $sum = 0
        foreach ($num in $numbers) {
            $sum += $num * $num
        }
    }
}
Write-Host " $($standardLoop.TotalMilliseconds)ms"

# Unrolled loop
Write-Host "Unrolled loop..." -NoNewline
$unrolledLoop = Measure-Command {
    1..10000 | ForEach-Object {
        $sum = (1*1) + (2*2) + (3*3) + (4*4)
    }
}
Write-Host " $($unrolledLoop.TotalMilliseconds)ms"

# =============================================================================
# Advanced Loop Patterns
# =============================================================================

Write-Host "`n--- Advanced Loop Patterns ---" -ForegroundColor Yellow

# 1. Parallel Processing with ForEach-Object -Parallel
Write-Host "`n1. Parallel vs Sequential Processing"

$heavyWork = 1..100

# Sequential processing
Write-Host "Sequential processing..." -NoNewline
$sequential = Measure-Command {
    $results = $heavyWork | ForEach-Object {
        Start-Sleep -Milliseconds 10  # Simulate work
        $_ * $_
    }
}
Write-Host " $($sequential.TotalMilliseconds)ms"

# Parallel processing (PowerShell 7+)
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "Parallel processing..." -NoNewline
    $parallel = Measure-Command {
        $results = $heavyWork | ForEach-Object -Parallel {
            Start-Sleep -Milliseconds 10  # Simulate work
            $_ * $_
        } -ThrottleLimit 10
    }
    Write-Host " $($parallel.TotalMilliseconds)ms"
    Write-Host "Parallel processing is $([math]::Round($sequential.TotalMilliseconds / $parallel.TotalMilliseconds, 2))x faster!"
} else {
    Write-Host "Parallel processing requires PowerShell 7+" -ForegroundColor Red
}

# 2. Early Exit Strategies
Write-Host "`n2. Early Exit Strategies"

$largeDataset = 1..100000

# Without early exit
Write-Host "Without early exit..." -NoNewline
$noEarlyExit = Measure-Command {
    $found = @()
    foreach ($item in $largeDataset) {
        if ($item % 7 -eq 0 -and $item % 11 -eq 0) {
            $found += $item
        }
    }
}
Write-Host " Found $($found.Count) items in $($noEarlyExit.TotalMilliseconds)ms"

# With early exit (find first 5)
Write-Host "With early exit (first 5)..." -NoNewline
$earlyExit = Measure-Command {
    $found = @()
    foreach ($item in $largeDataset) {
        if ($item % 7 -eq 0 -and $item % 11 -eq 0) {
            $found += $item
            if ($found.Count -eq 5) { break }
        }
    }
}
Write-Host " Found $($found.Count) items in $($earlyExit.TotalMilliseconds)ms"

# 3. Loop with Continue for Efficiency
Write-Host "`n3. Using Continue for Cleaner Logic"

$mixedData = @(1..50) + @('a'..'z') + @(51..100)

# Without continue (nested if)
Write-Host "Without continue..." -NoNewline
$withoutContinue = Measure-Command {
    $processed = foreach ($item in $mixedData) {
        if ($item -is [int]) {
            if ($item % 2 -eq 0) {
                if ($item -gt 10) {
                    $item * 2
                }
            }
        }
    }
}
Write-Host " $($withoutContinue.TotalMilliseconds)ms"

# With continue (flatter logic)
Write-Host "With continue..." -NoNewline
$withContinue = Measure-Command {
    $processed = foreach ($item in $mixedData) {
        if ($item -isnot [int]) { continue }
        if ($item % 2 -ne 0) { continue }
        if ($item -le 10) { continue }
        $item * 2
    }
}
Write-Host " $($withContinue.TotalMilliseconds)ms"

#endregion

Write-Host "`nLoop efficiency demonstrations completed!" -ForegroundColor Green

