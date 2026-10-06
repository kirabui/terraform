# Remote state in Azure Storage.
# Values are supplied per environment at init time (partial configuration):
#   terraform init -backend-config=environments/dev.backend.hcl
terraform {
  backend "azurerm" {}
}
