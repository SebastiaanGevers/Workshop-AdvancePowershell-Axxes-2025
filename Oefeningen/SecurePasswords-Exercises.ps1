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
# OEFENING 4: Storing and Retrieving Secrets
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


# TODO: Remove the "DatabasePassword" secret from the vault

# Your code here:


# TODO: Verify the secret was removed by listing all secrets again

# Your code here:


# =============================================================================
# OEFENING 6: Cleanup
# =============================================================================
# TODO: Remove all remaining secrets from your vault

# Your code here:


# TODO: Unregister your "WorkshopVault"

# Your code here:



