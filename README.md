# Azure Linux VM — Terraform

Deploys a hardened Ubuntu 24.04 VM with its own VNet, subnet and NSG, using one codebase and per-environment variable files.

## Layout

```
.
├── versions.tf          # Terraform + provider version pins
├── backend.tf           # Remote state (azurerm), partial config
├── providers.tf         # azurerm provider; auth comes from env / az login
├── variables.tf         # Typed, validated inputs
├── locals.tf            # Naming convention + common tags
├── main.tf              # RG, VNet, subnet, NSG, NIC, (PIP), VM, auto-shutdown
├── outputs.tf
├── environments/
│   ├── dev.tfvars        dev.backend.hcl
│   └── prod.tfvars       prod.backend.hcl
├── cloud-init/base.yaml # Optional first-boot config
└── scripts/bootstrap-state.sh
```

## Best practices used

- **Separate variable files per environment** (`environments/*.tfvars`) — same code, different inputs.
- **Remote state in Azure Storage** with partial backend config, Entra ID auth, versioning and soft delete; state locking is automatic (blob leases).
- **Pinned versions** for Terraform and the azurerm provider; commit `.terraform.lock.hcl`.
- **No secrets in code**: auth via `az login` locally or OIDC in CI; SSH keys only, password login disabled.
- **Typed variables with validation** (CIDRs, environment names, zones, disk types, blocks `0.0.0.0/0` for SSH).
- **Consistent naming and tagging** via `locals` (CAF style `<type>-<project>-<env>-<region>`).
- **Secure defaults**: no public IP, SSH closed unless CIDRs given, Trusted Launch, platform patching, system-assigned managed identity, boot diagnostics.
- **Cost control**: optional auto-shutdown for non-prod.

## Usage

```bash
# 0. Sign in and select the subscription
az login
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# 1. One-time: create the state storage account (edit names first)
./scripts/bootstrap-state.sh

# 2. Init against the environment's state file
terraform init -backend-config=environments/dev.backend.hcl

# 3. Plan and apply with the environment's variables
terraform plan  -var-file=environments/dev.tfvars -out=dev.tfplan
terraform apply dev.tfplan
```

Switching environment: `terraform init -reconfigure -backend-config=environments/prod.backend.hcl`, then plan with `prod.tfvars`.

Before applying dev, set `allowed_ssh_cidrs` in `dev.tfvars` to your own public IP (`curl -s ifconfig.me`), and make sure `~/.ssh/id_ed25519.pub` exists (`ssh-keygen -t ed25519`) or set `ssh_public_key_path`.

## Notes

- Trusted Launch needs a Gen2 image and a VM size that supports it (B-, D-, E-series v5 all do).
- `auto_shutdown.timezone` takes a Windows time zone ID, e.g. `AUS Central Standard Time` for Adelaide.
- Add CI checks: `terraform fmt -check`, `terraform validate`, `tflint`, and a security scanner such as `checkov` or `trivy config`.
