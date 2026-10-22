resource_group_name  = "rg-tfstate-aue"
storage_account_name = "sttfstateaue001krb" # must be globally unique
container_name       = "tfstate"
key                  = "webapp/dev/vm.tfstate"
use_azuread_auth     = true # Entra ID auth instead of storage account keys
