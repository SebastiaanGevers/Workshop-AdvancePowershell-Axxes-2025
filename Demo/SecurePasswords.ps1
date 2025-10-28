# PowerShell Secure Password Management Examples
# =============================================================================
# Traditional SecureString Approach
# =============================================================================

# Create and persist an encrypted password (CurrentUser scope)
$secure = ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force
$enc    = $secure | ConvertFrom-SecureString
$enc | Set-Content -Path .\pw.txt

# Proof the password is in there
$secure2 =  Get-Content .\pw.txt | ConvertTo-SecureString
$Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($secure2)
$result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
$result

# Later (same user/machine): recover and use as PSCredential
$secure2 =  Get-Content .\pw.txt | ConvertTo-SecureString
$cred    = [pscredential]::new('Axxes\Testuser', $secure2)

# =============================================================================
# PowerShell SecretManagement Module Examples (Modern Approach)
# =============================================================================

# Install the SecretManagement module (if not already installed)
# Install-Module Microsoft.PowerShell.SecretManagement -Force

# Install a vault provider (example: SecretStore)
# Install-Module Microsoft.PowerShell.SecretStore -Force


# Register a new secret vault
Register-SecretVault -Name "MySecretVault" -ModuleName Microsoft.PowerShell.SecretStore

# Store a secret (password)
$securePassword = ConvertTo-SecureString 'MySecretPassword123!' -AsPlainText -Force
Set-Secret -Name "DatabasePassword" -Secret $securePassword -Vault "MySecretVault"

# Store a secret (plain text)
Set-Secret -Name "APIKey" -Secret "sk-1234567890abcdef" -Vault "MySecretVault"

# Retrieve a secret
$retrievedPassword = Get-Secret -Name "DatabasePassword" -Vault "MySecretVault"
$apiKey = Get-Secret -Name "APIKey" -Vault "MySecretVault" -AsPlainText

# List all secrets in a vault
Get-SecretInfo -Vault "MySecretVault"

# Remove a secret
Remove-Secret -Name "APIKey" -Vault "MySecretVault"

# List all registered vaults
Get-SecretVault

# Remove a secret vault (corrected syntax)
Unregister-SecretVault -Name "MySecretVault"

# Alternative: Remove vault with confirmation prompt
# Unregister-SecretVault -Name "MySecretVault" -Confirm


# =============================================================================
# AZ-Keyvault - Module Requirements and Installation
# =============================================================================
Write-Host "=== Checking Azure PowerShell Module Dependencies ===" -ForegroundColor Cyan

# Required modules for Azure Key Vault operations
$requiredModules = @('Az.Accounts', 'Az.KeyVault')

foreach ($module in $requiredModules) {
    Write-Host "Checking for module: $module..." -NoNewline
    
    if (Get-Module -ListAvailable -Name $module) {
        Write-Host " Found" -ForegroundColor Green
        
        # Import if not already loaded
        if (-not (Get-Module -Name $module)) {
            Write-Host "  Importing $module..." -ForegroundColor Yellow
            Import-Module $module -Force
        }
    } else {
        Write-Host " Not found" -ForegroundColor Red
        Write-Host "  Installing $module..." -ForegroundColor Yellow
        try {
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            Import-Module $module -Force
            Write-Host "  Successfully installed and imported $module" -ForegroundColor Green
        }
        catch {
            Write-Host "  Failed to install $module : $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  Please run: Install-Module -Name $module -Force" -ForegroundColor Yellow
            exit 1
        }
    }
}

Write-Host "Module check completed!" -ForegroundColor Green

# =============================================================================
# Configuration - Update these values for your environment
# =============================================================================
$keyVaultName = "PS-KEY"  # Replace with your Key Vault name
$secretName = "test-secret"           # Replace with your secret name
$tenantId = "edd1c3b6-be87-43bb-92d4-7a911c5cee17"          # Replace with your tenant ID

Write-Host "=== Azure Key Vault Testing from VS Code ===" -ForegroundColor Green

# =============================================================================
# Method 1: User Authentication (Interactive)
# =============================================================================
Write-Host "1. Testing with User Authentication..." -ForegroundColor Yellow

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
    Write-Host "Successfully retrieved secret!" -ForegroundColor Green
    Write-Host "Secret value: $($secret)..." -ForegroundColor Green
}
catch {
    Write-Host "Error accessing Key Vault: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# Create Secret 
# =============================================================================
Write-Host "2. CreatingSecret in Key Vault..." -ForegroundColor Yellow
    $secretName = "DemoSecret"
    $secretValue = "MySuperSecretValue" 
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue (ConvertTo-SecureString $secretValue -AsPlainText -Force)

    Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName
    
