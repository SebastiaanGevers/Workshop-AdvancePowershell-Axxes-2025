# PowerShell Secure Password Management - Exercises
# Workshop 2025 - Axxes

# =============================================================================
# OEFENING 1: PSCredential Creation
# =============================================================================
# TODO: Create a PSCredential object using:
# Username: "Workshop\Student"
# Password: Use a SecureString with password "Exercise2024!"

# Your code here:


# TODO: Display the username and test if the credential object was created correctly

# Your code here:


# =============================================================================
# OEFENING 2: SecretManagement Module - Basic Operations
# =============================================================================
# TODO: Check if the Microsoft.PowerShell.SecretManagement module is installed
# If not installed, uncomment and run the install command below
# Install-Module Microsoft.PowerShell.SecretManagement -Force

# Your code here to check if module is available:


# TODO: Check if the Microsoft.PowerShell.SecretStore module is installed
# If not installed, uncomment and run the install command below
# Install-Module Microsoft.PowerShell.SecretStore -Force

# Your code here to check if module is available:


# =============================================================================
# OEFENING 3: Secret Vault Management
# =============================================================================
# TODO: Register a new secret vault called "WorkshopVault"

# Your code here:


# TODO: List all registered vaults to verify your vault was created

# Your code here:


# =============================================================================
# OEFENING 4: Storing and Retrieving Local Secrets
# =============================================================================
# TODO: Store the following secrets in your "WorkshopVault":
# - Name: "DatabasePassword", Value: "DbSecret2024!"
# - Name: "APIToken", Value: "token-abc123def456"

# Your code here:


# TODO: Retrieve both secrets and display them (use -AsPlainText for the API token)

# Your code here:


# TODO: List all secrets in your vault

# Your code here:


# =============================================================================
# OEFENING 5: Advanced Secret Operations
# =============================================================================
# TODO: Update the "APIToken" secret to a new value: "token-xyz789new"

# Your code here:


# TODO: Remove the "APIToken" secret from the vault (keep DatabasePassword for later use)

# Your code here:


# TODO: Verify the secret was removed by listing all secrets again

# Your code here:


# =============================================================================
# OEFENING 6: Azure Key Vault Setup and Authentication
# =============================================================================
# TODO: Install the Az PowerShell modules if not already installed
# Uncomment the lines below if modules are not installed:
# Install-Module Az.Accounts -Force
# Install-Module Az.KeyVault -Force

# Your code here to check if modules are available:


# TODO: Connect to Azure using your personal account (interactive login)
# This will open a browser window for authentication

# Your code here:


# TODO: Display your current Azure context to verify login

# Your code here:


# TODO: List available subscriptions and select the appropriate one
# (You may need to change subscription if you have multiple)

# Your code here:


# =============================================================================
# OEFENING 7: Azure Key Vault Operations
# =============================================================================
# TODO: Create variables for your Azure Key Vault
# Note: Key Vault names must be globally unique, use format: "kv-workshop-[yourname]"
$keyVaultName = "kv-workshop-student01"  # Change this to make it unique
$resourceGroupName = "rg-workshop"       # Use existing or create new resource group

# TODO: Check if the Key Vault exists, if not create it
# Hint: Use Get-AzKeyVault and New-AzKeyVault commands

# Your code here:


# TODO: Set Key Vault access policy to allow your user to manage secrets
# Hint: Use Set-AzKeyVaultAccessPolicy

# Your code here:


# =============================================================================
# OEFENING 8: Store Database Credentials in Azure Key Vault
# =============================================================================
# TODO: Store the following database-related secrets in Azure Key Vault:
# - Secret Name: "DB-Username", Value: "sa"
# - Secret Name: "DB-Password", Value: "Workshop2024!"
# - Secret Name: "DB-Server", Value: "localhost"

# Your code here:


# TODO: Retrieve and display all stored secrets (use -AsPlainText to verify)

# Your code here:


# TODO: Create a PSCredential object using the retrieved username and password

# Your code here:


# =============================================================================
# OEFENING 9: Integration with Database Connection
# =============================================================================
# TODO: Create a function that retrieves database credentials from Azure Key Vault
# and returns a hashtable with connection parameters for dbatools

function Get-DatabaseConnectionFromAzure {
    param(
        [string]$KeyVaultName
    )
    
    # Your code here:
    # 1. Retrieve DB-Username, DB-Password, and DB-Server from Key Vault
    # 2. Create PSCredential object
    # 3. Return hashtable with SqlInstance and SqlCredential
    
}

# TODO: Test your function

# Your code here:


# =============================================================================
# OEFENING 10: Cleanup and Security Best Practices
# =============================================================================
# TODO: List all secrets in your Azure Key Vault

# Your code here:


# TODO: Create a backup/export of your secrets (for learning purposes only)
# Note: In production, be very careful with secret exports

# Your code here:


# TODO: Optional: Clean up secrets if desired (remove individual secrets)
# Uncomment and modify as needed:
# Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Username" -Force
# Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Password" -Force
# Remove-AzKeyVaultSecret -VaultName $keyVaultName -Name "DB-Server" -Force

# Your code here:


# TODO: Remove local vault and secrets

# Your code here:


# TODO: Disconnect from Azure (optional, but good practice)

# Your code here:


# =============================================================================
# REFLECTION QUESTIONS
# =============================================================================
# 1. What are the advantages of using Azure Key Vault over local SecretStore?
# 2. How does Azure authentication work with PowerShell?
# 3. What security considerations should you keep in mind when using Key Vault?
# 4. How would you implement this in a production environment?
# 5. What are the cost implications of using Azure Key Vault?




