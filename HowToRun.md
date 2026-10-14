# Login to Azure
az login --tenant "c7607b5c-0154-41aa-b5ff-5c28fe8593ae"
az account set --subscription "7341f111-ee11-4c36-965d-18e561dfcac9"

# Run the scripts/bootstrap-state.sh
This is to create the storage account that is used to save the statefile
Update the environments/dev.backend.hcl and prod.backend.hcl to reflect the new storage account name

# Run terraform init
terraform init -backend-config environments/dev.backend.hcl

# Changing variables in Dev
SKU size: dev.tfvars line 12
Local VM IP: dev.tfvars line 9 to 59.102.47.10/32

# Workflow
terraform plan -var-file=environments/dev.tfvars -out=dev.tfplan

terraform apply dev.tfplan

###### Switch to PROD env ######

# 1. Switch the backend to prod (-reconfigure is required when switching)
terraform init -reconfigure -backend-config=environments/prod.backend.hcl

# 2. Confirm you're really on prod
grep '"key"' .terraform/terraform.tfstate        # → "webapp/prod/vm.tfstate"

# 3. Plan with the PROD tfvars
terraform plan -var-file=environments/prod.tfvars -out=prod.tfplan

# 4. Review the plan, then apply
terraform apply prod.tfplan

### DESTROY ENV ###
# Switch to that env first, e.g destroy DEV
terraform destroy deletes everything recorded in the state file you’re connected to. Your last init was for prod. If you run destroy now, Terraform will delete prod, even if you pass -var-file=environments/dev.tfvars. The tfvars file doesn’t choose which environment gets destroyed. The backend does.
# 1. Switch the backend to dev
terraform init -reconfigure -backend-config=environments/dev.backend.hcl

# 2. Confirm you're on dev before going further
grep '"key"' .terraform/terraform.tfstate     # must show "webapp/dev/vm.tfstate"
terraform output resource_group_name           # must show rg-webapp-dev-aue

# 3. Preview what will be deleted (doesn't change anything)
terraform plan -destroy -var-file=environments/dev.tfvars -out=dev-destroy.tfplan

# 4. Review it, then destroy
terraform apply dev-destroy.tfplan