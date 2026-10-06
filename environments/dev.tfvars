project     = "webapp"
environment = "dev"
location    = "australiaeast"

vnet_address_space      = ["10.10.0.0/16"]
subnet_address_prefixes = ["10.10.1.0/24"]

# Replace with your own public IP, e.g. "203.0.113.10/32"
allowed_ssh_cidrs = ["203.0.113.10/32"]
create_public_ip  = true

vm_size = "Standard_B2s"
zone    = null

os_disk = {
  storage_account_type = "StandardSSD_LRS"
  disk_size_gb         = 64
}

auto_shutdown = {
  enabled  = true
  time     = "1900"
  timezone = "AUS Central Standard Time"
}

tags = {
  owner       = "platform-team"
  cost_center = "1234"
}
