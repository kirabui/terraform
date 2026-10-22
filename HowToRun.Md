# Login to Azure
az login --tenant "c7607b5c-0154-41aa-b5ff-5c28fe8593ae"
az account set --subscription "7341f111-ee11-4c36-965d-18e561dfcac9"

# Run the scripts/bootstrap-state.sh
This is to create the storage account that is used to save the statefile
Update the environments/dev.backend.hcl and prod.backend.hcl to reflect the new storage account name

# Run terraform init
terraform init -backend-config environments/dev.backend.hcl