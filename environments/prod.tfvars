project     = "webapp"
environment = "prod"
location    = "australiaeast"

vnet_address_space      = ["10.20.0.0/16"]
subnet_address_prefixes = ["10.20.1.0/24"]

# Prod: no public IP, no SSH from outside the VNet — reach the VM via Azure Bastion or VPN.
allowed_ssh_cidrs = []
create_public_ip  = false

vm_size = "Standard_D2als_v6"
zone    = "1"

os_disk = {
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128
}

auto_shutdown = {
  enabled = false
}

tags = {
  owner       = "platform-team"
  cost_center = "1234"
  criticality = "high"
}
