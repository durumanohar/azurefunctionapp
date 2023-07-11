# Import required Azure modules
using module Az.Accounts
using module Az.Compute
using module Az.ImageBuilder

# Azure Function entry point
param($Request, $TriggerMetadata)

# Function to create Azure VM image builder
function Create-AzureVmImageBuilder {
    # Authenticate to Azure using service principal
    $tenantId = "<Tenant ID>"
    $clientId = "<Client ID>"
    $clientSecret = "<Client Secret>"
    $subscriptionId = "<Subscription ID>"

    Connect-AzAccount -TenantId $tenantId -ApplicationId $clientId -Credential (New-Object PSCredential -ArgumentList $clientId, (ConvertTo-SecureString -String $clientSecret -AsPlainText -Force)) -ServicePrincipal -SubscriptionId $subscriptionId

    # Define variables for VM image builder configuration
    $resourceGroupName = "<Resource Group Name>"
    $imageTemplateName = "<Image Template Name>"
    $region = "<Azure Region>"
    $vmTemplateName = "<VM Template Name>"
    $vmSize = "<VM Size>"
    $osDiskSizeGB = "<OS Disk Size in GB>"

    # Set build artifacts
    $managedImage = @{
        ManagedImageName = "<Managed Image Name>"
        ManagedImageLocation = "<Managed Image Location>"
    }

    $buildArtifacts = @(
        @{
            ArtifactType = "VmTemplate"
            ArtifactId = $vmTemplateName
            ArtifactTitle = "Base VM Template"
        }
        @{
            ArtifactType = "ManagedImage"
            ArtifactId = $managedImage.ManagedImageName
            ArtifactTitle = "Managed Image"
        }
    )

    # Create image builder
    $imageBuilderConfig = @{
        Location = $region
        IdentityType = "SystemAssigned"
        ImageTemplateName = $imageTemplateName
        DistributeType = "ManagedImage"
        BuildTimeoutInMinutes = 60
        ProvisioningTimeoutInMinutes = 30
        VMProfile = @{
            VMSize = $vmSize
            OsDiskSizeGB = $osDiskSizeGB
        }
        Distribute = @{
            ManagedImage = $managedImage
        }
        BuildArtifacts = $buildArtifacts
    }

    New-AzImageBuilderTemplate -ResourceGroupName $resourceGroupName -Name $imageTemplateName -ImageBuilderTemplate $imageBuilderConfig
}

# Invoke the function
Create-AzureVmImageBuilder
