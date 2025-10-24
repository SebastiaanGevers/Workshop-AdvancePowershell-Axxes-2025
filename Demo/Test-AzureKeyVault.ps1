# Azure Key Vault Testing Script for VS Code
# Test different authentication methods for accessing Azure Key Vault

# =============================================================================
# Configuration - Update these values for your environment
# =============================================================================
$keyVaultName = "your-keyvault-name"  # Replace with your Key Vault name
$secretName = "test-secret"           # Replace with your secret name
$tenantId = "your-tenant-id"          # Replace with your tenant ID

Write-Host "=== Azure Key Vault Testing from VS Code ===" -ForegroundColor Green

# =============================================================================
# Method 1: User Authentication (Interactive)
# =============================================================================
Write-Host "`n1. Testing with User Authentication..." -ForegroundColor Yellow

try {
    # Check if already connected
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Connecting to Azure..." -ForegroundColor Cyan
        Connect-AzAccount
    } else {
        Write-Host "Already connected as: $($context.Account.Id)" -ForegroundColor Green
    }
    
    # Test Key Vault access
    Write-Host "Attempting to access Key Vault: $keyVaultName" -ForegroundColor Cyan
    $secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -AsPlainText -ErrorAction Stop
    Write-Host "✅ Successfully retrieved secret!" -ForegroundColor Green
    Write-Host "Secret value: $($secret.Substring(0, [Math]::Min(10, $secret.Length)))..." -ForegroundColor Green
}
catch {
    Write-Host "❌ Error accessing Key Vault: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- Key Vault name is incorrect" -ForegroundColor Yellow
    Write-Host "- Secret name doesn't exist" -ForegroundColor Yellow
    Write-Host "- Insufficient permissions (need Get secret permission)" -ForegroundColor Yellow
}

# =============================================================================
# Method 2: Check Current Permissions
# =============================================================================
Write-Host "`n2. Checking Current User Permissions..." -ForegroundColor Yellow

try {
    $vault = Get-AzKeyVault -VaultName $keyVaultName -ErrorAction Stop
    Write-Host "✅ Can access Key Vault properties" -ForegroundColor Green
    Write-Host "Vault URI: $($vault.VaultUri)" -ForegroundColor Cyan
    
    # List accessible secrets (metadata only)
    $secrets = Get-AzKeyVaultSecret -VaultName $keyVaultName -ErrorAction Stop
    Write-Host "✅ Can list secrets. Found $($secrets.Count) secrets:" -ForegroundColor Green
    $secrets | Select-Object Name, Enabled, Created | Format-Table
}
catch {
    Write-Host "❌ Cannot access Key Vault metadata: $($_.Exception.Message)" -ForegroundColor Red
}
