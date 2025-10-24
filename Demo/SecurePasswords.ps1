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

# Install a vault provider (example: KeePass)
# Install-Module SecretManagement.KeePass -Force

# Register a new secret vault
Register-SecretVault -Name "MySecretVault" -ModuleName Microsoft.PowerShell.SecretStore
Register-SecretVault -Name "Keepass" -ModuleName SecretManagement.KeePass
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

# Remove all vaults (be careful!)
# Get-SecretVault | Unregister-SecretVault
