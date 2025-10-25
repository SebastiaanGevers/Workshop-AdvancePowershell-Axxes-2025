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

# TODO: Remove the "APIToken" secret from the vault (keep DatabasePassword for later use)

# SOLUTION:
try {
    Remove-Secret -Name "APIToken" -Vault "WorkshopVault"
    Write-Host "APIToken removed successfully"
} catch {
    Write-Host "Error removing APIToken: $($_.Exception.Message)"
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
# OEFENING 6: Azure Key Vault Setup and Authentication
# =============================================================================
# TODO: Install the Az PowerShell modules if not already installed
# Uncomment the lines below if modules are not installed:
# Install-Module Az.Accounts -Force
# Install-Module Az.KeyVault -Force

# SOLUTION:
$azAccountsModule = Get-Module -ListAvailable -Name Az.Accounts
$azKeyVaultModule = Get-Module -ListAvailable -Name Az.KeyVault

if ($azAccountsModule) {
    Write-Host "Az.Accounts module is installed - Version: $($azAccountsModule.Version)"
} else {
    Write-Host "Az.Accounts module is NOT installed"
    # Install-Module Az.Accounts -Force
}

if ($azKeyVaultModule) {
    Write-Host "Az.KeyVault module is installed - Version: $($azKeyVaultModule.Version)"
} else {
    Write-Host "Az.KeyVault module is NOT installed"
    # Install-Module Az.KeyVault -Force
}

# TODO: Connect to Azure using your personal account (interactive login)
# This will open a browser window for authentication

# SOLUTION:
try {
    Connect-AzAccount
    Write-Host "Successfully connected to Azure"
} catch {
    Write-Host "Error connecting to Azure: $($_.Exception.Message)"
}

# TODO: Display your current Azure context to verify login

# SOLUTION:
$context = Get-AzContext
if ($context) {
    Write-Host "Current Azure Context:"
    Write-Host "Account: $($context.Account.Id)"
    Write-Host "Subscription: $($context.Subscription.Name)"
    Write-Host "Tenant: $($context.Tenant.Id)"
} else {
    Write-Host "No Azure context found - not logged in"
}

# TODO: List available subscriptions and select the appropriate one
# (You may need to change subscription if you have multiple)

# SOLUTION:
$subscriptions = Get-AzSubscription
Write-Host "Available subscriptions:"
$subscriptions | Format-Table Name, Id, State

# If you need to switch subscription (uncomment and modify):
# Set-AzContext -SubscriptionId "your-subscription-id"

# =============================================================================
# OEFENING 7: Azure Key Vault Operations
# =============================================================================
# TODO: Create variables for your Azure Key Vault
# Note: Key Vault names must be globally unique, use format: "kv-workshop-[yourname]"
$keyVaultName = "kv-workshop-student01"  # Change this to make it unique
$resourceGroupName = "rg-workshop"       # Use existing or create new resource group

# TODO: Check if the Key Vault exists, if not create it
# Hint: Use Get-AzKeyVault and New-AzKeyVault commands

# SOLUTION:
try {
    $existingKeyVault = Get-AzKeyVault -VaultName $keyVaultName -ErrorAction SilentlyContinue
    
    if ($existingKeyVault) {
        Write-Host "Key Vault '$keyVaultName' already exists"
    } else {
        Write-Host "Creating Key Vault '$keyVaultName'..."
        
        # Check if resource group exists, create if it doesn't
        $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
        if (-not $resourceGroup) {
            New-AzResourceGroup -Name $resourceGroupName -Location "West Europe"
            Write-Host "Created resource group '$resourceGroupName'"
        }
        
        # Create the Key Vault
        $newKeyVault = New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location "West Europe"
        Write-Host "Created Key Vault '$keyVaultName' successfully"
    }
} catch {
    Write-Host "Error with Key Vault operations: $($_.Exception.Message)"
}

# TODO: Set Key Vault access policy to allow your user to manage secrets
# Hint: Use Set-AzKeyVaultAccessPolicy

# SOLUTION:
try {
    $context = Get-AzContext
    $userObjectId = (Get-AzADUser -UserPrincipalName $context.Account.Id).Id
    
    Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $userObjectId -PermissionsToSecrets Get,Set,Delete,List
    Write-Host "Access policy set for user: $($context.Account.Id)"
} catch {
    Write-Host "Error setting access policy: $($_.Exception.Message)"
}

# =============================================================================
# OEFENING 8: Store Database Credentials in Azure Key Vault
# =============================================================================
# TODO: Store the following database-related secrets in Azure Key Vault:
# - Secret Name: "DB-Username", Value: "sa"
# - Secret Name: "DB-Password", Value: "Workshop2024!"
# - Secret Name: "DB-Server", Value: "localhost"

# SOLUTION:
try {
    # Store database username
    $dbUsernameSecret = ConvertTo-SecureString "sa" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Username" -SecretValue $dbUsernameSecret
    Write-Host "Stored DB-Username in Azure Key Vault"
    
    # Store database password
    $dbPasswordSecret = ConvertTo-SecureString "Workshop2024!" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Password" -SecretValue $dbPasswordSecret
    Write-Host "Stored DB-Password in Azure Key Vault"
    
    # Store database server
    $dbServerSecret = ConvertTo-SecureString "localhost" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Server" -SecretValue $dbServerSecret
    Write-Host "Stored DB-Server in Azure Key Vault"
} catch {
    Write-Host "Error storing secrets in Azure Key Vault: $($_.Exception.Message)"
}

# TODO: Retrieve and display all stored secrets (use -AsPlainText to verify)

# SOLUTION:
try {
    # List all secrets
    $secrets = Get-AzKeyVaultSecret -VaultName $keyVaultName
    Write-Host "Secrets in Azure Key Vault:"
    $secrets | Format-Table Name, Created, Updated
    
    # Retrieve specific secrets
    $dbUsername = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Username" -AsPlainText)
    $dbPassword = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Password" -AsPlainText)
    $dbServer = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Server" -AsPlainText)
    
    Write-Host "Retrieved values:"
    Write-Host "DB Username: $dbUsername"
    Write-Host "DB Password: $dbPassword"
    Write-Host "DB Server: $dbServer"
} catch {
    Write-Host "Error retrieving secrets: $($_.Exception.Message)"
}

# TODO: Create a PSCredential object using the retrieved username and password

# SOLUTION:
try {
    $dbUsername = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Username" -AsPlainText)
    $dbPasswordPlain = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Password" -AsPlainText)
    $dbPasswordSecure = ConvertTo-SecureString $dbPasswordPlain -AsPlainText -Force
    
    $dbCredential = [PSCredential]::new($dbUsername, $dbPasswordSecure)
    Write-Host "Created PSCredential object for database connection"
    Write-Host "Username: $($dbCredential.UserName)"
} catch {
    Write-Host "Error creating PSCredential: $($_.Exception.Message)"
}

# =============================================================================
# OEFENING 9: Integration with Database Connection
# =============================================================================
# TODO: Create a function that retrieves database credentials from Azure Key Vault
# and returns a hashtable with connection parameters for dbatools

function Get-DatabaseConnectionFromAzure {
    param(
        [string]$KeyVaultName
    )
    
    # SOLUTION:
    try {
        # 1. Retrieve DB-Username, DB-Password, and DB-Server from Key Vault
        $dbUsername = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "DB-Username" -AsPlainText)
        $dbPasswordPlain = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "DB-Password" -AsPlainText)
        $dbServer = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "DB-Server" -AsPlainText)
        
        # 2. Create PSCredential object
        $dbPasswordSecure = ConvertTo-SecureString $dbPasswordPlain -AsPlainText -Force
        $dbCredential = [PSCredential]::new($dbUsername, $dbPasswordSecure)
        
        # 3. Return hashtable with SqlInstance and SqlCredential
        return @{
            SqlInstance = $dbServer
            SqlCredential = $dbCredential
        }
    } catch {
        Write-Error "Failed to retrieve database connection from Azure Key Vault: $($_.Exception.Message)"
        return $null
    }
}

# TODO: Test your function

# SOLUTION:
try {
    $connectionParams = Get-DatabaseConnectionFromAzure -KeyVaultName $keyVaultName
    if ($connectionParams) {
        Write-Host "Function test successful!"
        Write-Host "SQL Instance: $($connectionParams.SqlInstance)"
        Write-Host "SQL Credential Username: $($connectionParams.SqlCredential.UserName)"
        
        # Example usage with dbatools (if module is available)
        if (Get-Module -ListAvailable -Name dbatools) {
            # Test-DbaConnection @connectionParams
            Write-Host "Ready to use with dbatools: Test-DbaConnection @connectionParams"
        }
    }
} catch {
    Write-Host "Function test failed: $($_.Exception.Message)"
}

# =============================================================================
# OEFENING 10: Cleanup and Security Best Practices
# =============================================================================
# TODO: List all secrets in your Azure Key Vault

# SOLUTION:
try {
    $allSecrets = Get-AzKeyVaultSecret -VaultName $keyVaultName
    Write-Host "All secrets in Azure Key Vault '$keyVaultName':"
    $allSecrets | Format-Table Name, Enabled, Created, Updated
} catch {
    Write-Host "Error listing secrets: $($_.Exception.Message)"
}

# TODO: Create a backup/export of your secrets (for learning purposes only)
# Note: In production, be very careful with secret exports

# SOLUTION:
try {
    Write-Host "Creating backup of secrets (for learning purposes only):"
    $secretBackup = @{}
    
    $allSecrets = Get-AzKeyVaultSecret -VaultName $keyVaultName
    foreach ($secret in $allSecrets) {
        $secretValue = (Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secret.Name -AsPlainText)
        $secretBackup[$secret.Name] = $secretValue
        Write-Host "Backed up secret: $($secret.Name)"
    }
    
    # Export to file (be very careful with this in production!)
    $secretBackup | ConvertTo-Json | Out-File -FilePath ".\secret-backup.json"
    Write-Host "Backup saved to secret-backup.json (DELETE THIS FILE AFTER WORKSHOP!)"
} catch {
    Write-Host "Error creating backup: $($_.Exception.Message)"
}

# TODO: Optional: Clean up secrets if desired (remove individual secrets)
# Uncomment and modify as needed:
# Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Username" -Force
# Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Password" -Force
# Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Server" -Force

# SOLUTION: (commented out for safety)
# try {
#     Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Username" -Force
#     Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Password" -Force
#     Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Server" -Force
#     Write-Host "Removed all database secrets from Azure Key Vault"
# } catch {
#     Write-Host "Error removing secrets: $($_.Exception.Message)"
# }

# TODO: Remove local vault and secrets

# SOLUTION:
try {
    # Remove any remaining local secrets
    $localSecrets = Get-SecretInfo -Vault "WorkshopVault" -ErrorAction SilentlyContinue
    if ($localSecrets) {
        foreach ($secret in $localSecrets) {
            Remove-Secret -Name $secret.Name -Vault "WorkshopVault"
            Write-Host "Removed local secret: $($secret.Name)"
        }
    }
    
    # Unregister local vault
    Unregister-SecretVault -Name "WorkshopVault" -ErrorAction SilentlyContinue
    Write-Host "Local WorkshopVault removed"
} catch {
    Write-Host "Error removing local vault: $($_.Exception.Message)"
}

# TODO: Disconnect from Azure (optional, but good practice)

# SOLUTION:
try {
    Disconnect-AzAccount
    Write-Host "Disconnected from Azure"
} catch {
    Write-Host "Error disconnecting from Azure: $($_.Exception.Message)"
}

# =============================================================================
# REFLECTION QUESTIONS - SOLUTIONS AND DISCUSSION POINTS
# =============================================================================
# 1. What are the advantages of using Azure Key Vault over local SecretStore?
#    - Centralized secret management across multiple systems
#    - Built-in access logging and auditing
#    - Integration with Azure Active Directory
#    - Hardware Security Module (HSM) backed storage
#    - Compliance with various security standards
#    - Automatic backup and disaster recovery
#    - Fine-grained access control policies

# 2. How does Azure authentication work with PowerShell?
#    - Uses OAuth 2.0 / OpenID Connect
#    - Interactive login opens browser for MFA support
#    - Service principals for automated scenarios
#    - Managed identities for Azure resources
#    - Token-based authentication with refresh capabilities

# 3. What security considerations should you keep in mind when using Key Vault?
#    - Principle of least privilege for access policies
#    - Regular access review and audit logs monitoring
#    - Network access restrictions (firewall rules)
#    - Secret rotation policies
#    - Secure backup and recovery procedures
#    - Monitoring for unusual access patterns

# 4. How would you implement this in a production environment?
#    - Use service principals or managed identities instead of user accounts
#    - Implement secret rotation policies
#    - Set up monitoring and alerting
#    - Use separate Key Vaults for different environments
#    - Implement Infrastructure as Code (ARM templates, Terraform)
#    - Regular security assessments and compliance checks

# 5. What are the cost implications of using Azure Key Vault?
#    - Pay-per-operation pricing model
#    - Different tiers (Standard vs Premium with HSM)
#    - Consider operation frequency and volume
#    - Factor in networking costs if using private endpoints
#    - Evaluate against operational costs of managing secrets manually