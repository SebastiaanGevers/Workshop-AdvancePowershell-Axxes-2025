# PowerShell Secure Password Management - Exercises SOLUTIONS
# Workshop 2025 - Axxes

# =============================================================================
# OEFENING 1: PSCredential Creation
# =============================================================================
# TODO: Create a PSCredential object using:
# Username: "Workshop\Student"
# Password: Use a SecureString with password "Exercise2024!"

# SOLUTION:
$securePassword = ConvertTo-SecureString "Exercise2024!" -AsPlainText -Force
$credential = [PSCredential]::new("Workshop\Student", $securePassword)

# TODO: Display the username and test if the credential object was created correctly

# SOLUTION:
Write-Host "Username: $($credential.UserName)"
Write-Host "Credential type: $($credential.GetType().Name)"
Write-Host "Has password: $($credential.Password -ne $null)"

# =============================================================================
# OEFENING 2: SecretManagement Module - Basic Operations
# =============================================================================
# TODO: Check if the Microsoft.PowerShell.SecretManagement module is installed
# If not installed, uncomment and run the install command below
# Install-Module Microsoft.PowerShell.SecretManagement -Force

# SOLUTION:
$secretMgmtModule = Get-Module -ListAvailable -Name Microsoft.PowerShell.SecretManagement
if ($secretMgmtModule) {
    Write-Host "SecretManagement module is installed - Version: $($secretMgmtModule.Version)"
} else {
    Write-Host "SecretManagement module is NOT installed"
    # Uncomment the line below to install
    # Install-Module Microsoft.PowerShell.SecretManagement -Force
}

# TODO: Check if the Microsoft.PowerShell.SecretStore module is installed
# If not installed, uncomment and run the install command below
# Install-Module Microsoft.PowerShell.SecretStore -Force

# SOLUTION:
$secretStoreModule = Get-Module -ListAvailable -Name Microsoft.PowerShell.SecretStore
if ($secretStoreModule) {
    Write-Host "SecretStore module is installed - Version: $($secretStoreModule.Version)"
} else {
    Write-Host "SecretStore module is NOT installed"
    # Uncomment the line below to install
    # Install-Module Microsoft.PowerShell.SecretStore -Force
}

# =============================================================================
# OEFENING 3: Secret Vault Management
# =============================================================================
# TODO: Register a new secret vault called "WorkshopVault"

# SOLUTION:
try {
    Register-SecretVault -Name "WorkshopVault" -ModuleName Microsoft.PowerShell.SecretStore
    Write-Host "Successfully registered WorkshopVault"
} catch {
    Write-Host "Error registering vault: $($_.Exception.Message)"
}

# TODO: List all registered vaults to verify your vault was created

# SOLUTION:
$vaults = Get-SecretVault
Write-Host "Registered vaults:"
$vaults | Format-Table Name, ModuleName, IsDefault

# =============================================================================
# OEFENING 4: Storing and Retrieving Secrets
# =============================================================================
# TODO: Store the following secrets in your "WorkshopVault":
# - Name: "DatabasePassword", Value: "DbSecret2024!"
# - Name: "APIToken", Value: "token-abc123def456"

# SOLUTION:
try {
    # Store database password as SecureString
    $dbPassword = ConvertTo-SecureString "DbSecret2024!" -AsPlainText -Force
    Set-Secret -Name "DatabasePassword" -Secret $dbPassword -Vault "WorkshopVault"
    Write-Host "Stored DatabasePassword successfully"
    
    # Store API token as plain text
    Set-Secret -Name "APIToken" -Secret "token-abc123def456" -Vault "WorkshopVault"
    Write-Host "Stored APIToken successfully"
} catch {
    Write-Host "Error storing secrets: $($_.Exception.Message)"
}

# TODO: Retrieve both secrets and display them (use -AsPlainText for the API token)

# SOLUTION:
try {
    $retrievedDbPassword = Get-Secret -Name "DatabasePassword" -Vault "WorkshopVault"
    $retrievedApiToken = Get-Secret -Name "APIToken" -Vault "WorkshopVault" -AsPlainText
    
    Write-Host "Retrieved DatabasePassword (SecureString): $($retrievedDbPassword.GetType().Name)"
    Write-Host "Retrieved APIToken (PlainText): $retrievedApiToken"
} catch {
    Write-Host "Error retrieving secrets: $($_.Exception.Message)"
}

# TODO: List all secrets in your vault

# SOLUTION:
$secrets = Get-SecretInfo -Vault "WorkshopVault"
Write-Host "Secrets in WorkshopVault:"
$secrets | Format-Table Name, Type, VaultName

# =============================================================================
# OEFENING 5: Advanced Secret Operations
# =============================================================================
# TODO: Update the "APIToken" secret to a new value: "token-xyz789new"

# SOLUTION:
try {
    Set-Secret -Name "APIToken" -Secret "token-xyz789new" -Vault "WorkshopVault"
    Write-Host "APIToken updated successfully"
    
    # Verify the update
    $updatedToken = Get-Secret -Name "APIToken" -Vault "WorkshopVault" -AsPlainText
    Write-Host "Updated APIToken value: $updatedToken"
} catch {
    Write-Host "Error updating APIToken: $($_.Exception.Message)"
}

# TODO: Remove the "DatabasePassword" secret from the vault

# SOLUTION:
try {
    Remove-Secret -Name "DatabasePassword" -Vault "WorkshopVault"
    Write-Host "DatabasePassword removed successfully"
} catch {
    Write-Host "Error removing DatabasePassword: $($_.Exception.Message)"
}

# TODO: Verify the secret was removed by listing all secrets again

# SOLUTION:
$remainingSecrets = Get-SecretInfo -Vault "WorkshopVault"
Write-Host "Remaining secrets in WorkshopVault:"
if ($remainingSecrets) {
    $remainingSecrets | Format-Table Name, Type, VaultName
} else {
    Write-Host "No secrets found in vault"
}

# =============================================================================
# OEFENING 6: Cleanup
# =============================================================================
# TODO: Remove all remaining secrets from your vault

# SOLUTION:
try {
    $allSecrets = Get-SecretInfo -Vault "WorkshopVault"
    foreach ($secret in $allSecrets) {
        Remove-Secret -Name $secret.Name -Vault "WorkshopVault"
        Write-Host "Removed secret: $($secret.Name)"
    }
    Write-Host "All secrets removed from WorkshopVault"
} catch {
    Write-Host "Error removing secrets: $($_.Exception.Message)"
}

# TODO: Unregister your "WorkshopVault"

# SOLUTION:
try {
    Unregister-SecretVault -Name "WorkshopVault"
    Write-Host "WorkshopVault unregistered successfully"
} catch {
    Write-Host "Error unregistering vault: $($_.Exception.Message)"
}


# =============================================================================