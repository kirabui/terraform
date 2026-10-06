# Authentication and subscription come from the environment, never from code:
#   az login            (local use)
#   export ARM_SUBSCRIPTION_ID=<subscription-guid>
# In CI/CD, use OIDC / workload identity federation (ARM_USE_OIDC=true, ARM_CLIENT_ID, ARM_TENANT_ID).
provider "azurerm" {
  features {
    resource_group {
      # Refuse to delete a resource group that still contains resources Terraform doesn't manage.
      prevent_deletion_if_contains_resources = true
    }

    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}
