############################
# Resource group
############################

resource "azurerm_resource_group" "this" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.common_tags
}

############################
# Networking
############################

resource "azurerm_virtual_network" "this" {
  name                = local.names.vnet
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "vm" {
  name                 = local.names.subnet
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "vm" {
  name                = local.names.nsg
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

# SSH is only opened when explicit source CIDRs are supplied.
resource "azurerm_network_security_rule" "allow_ssh" {
  count = length(var.allowed_ssh_cidrs) > 0 ? 1 : 0

  name                        = "Allow-SSH-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_ssh_cidrs
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_public_ip" "vm" {
  count = var.create_public_ip ? 1 : 0

  name                = local.names.public_ip
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zone == null ? null : [var.zone]
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm" {
  name                = local.names.nic
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.vm[0].id : null
  }
}

############################
# Virtual machine
############################

resource "azurerm_linux_virtual_machine" "this" {
  name                  = local.names.vm
  computer_name         = local.names.vm
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.vm_size
  zone                  = var.zone
  network_interface_ids = [azurerm_network_interface.vm.id]

  # Key-based auth only
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    name                 = local.names.os_disk
    caching              = "ReadWrite"
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  custom_data = var.custom_data_path == null ? null : filebase64(var.custom_data_path)

  # Trusted Launch (requires a Gen2 image and supported VM size)
  secure_boot_enabled = true
  vtpm_enabled        = true

  # Azure-managed OS patching
  patch_mode            = "AutomaticByPlatform"
  patch_assessment_mode = "AutomaticByPlatform"

  # Managed identity instead of stored credentials for accessing Azure services
  identity {
    type = "SystemAssigned"
  }

  # Empty block = managed storage account for boot diagnostics
  boot_diagnostics {}

  tags = local.common_tags

  depends_on = [azurerm_subnet_network_security_group_association.vm]
}

############################
# Cost control
############################

resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  count = var.auto_shutdown.enabled ? 1 : 0

  virtual_machine_id    = azurerm_linux_virtual_machine.this.id
  location              = azurerm_resource_group.this.location
  enabled               = true
  daily_recurrence_time = var.auto_shutdown.time
  timezone              = var.auto_shutdown.timezone
  tags                  = local.common_tags

  notification_settings {
    enabled = false
  }
}
