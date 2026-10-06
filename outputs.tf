output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "vm_id" {
  description = "Resource ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the virtual machine."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Private IP address of the VM."
  value       = azurerm_network_interface.vm.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the VM (null if not created)."
  value       = var.create_public_ip ? azurerm_public_ip.vm[0].ip_address : null
}

output "vm_principal_id" {
  description = "Object ID of the VM's system-assigned managed identity (for role assignments)."
  value       = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

output "ssh_command" {
  description = "Convenience SSH command."
  value = format(
    "ssh %s@%s",
    var.admin_username,
    var.create_public_ip ? azurerm_public_ip.vm[0].ip_address : azurerm_network_interface.vm.private_ip_address,
  )
}
