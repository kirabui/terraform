locals {
  # Short region codes keep names compact. Unknown regions fall back to the full name.
  location_short_map = {
    australiaeast      = "aue"
    australiasoutheast = "ause"
    australiacentral   = "auc"
    eastus             = "eus"
    eastus2            = "eus2"
    westus2            = "wus2"
    westeurope         = "weu"
    northeurope        = "neu"
    uksouth            = "uks"
    southeastasia      = "sea"
  }
  location_short = lookup(local.location_short_map, var.location, var.location)

  # Cloud Adoption Framework style naming: <type>-<project>-<env>-<region>
  name_suffix = "${var.project}-${var.environment}-${local.location_short}"

  names = {
    resource_group = "rg-${local.name_suffix}"
    vnet           = "vnet-${local.name_suffix}"
    subnet         = "snet-vm-${local.name_suffix}"
    nsg            = "nsg-vm-${local.name_suffix}"
    public_ip      = "pip-vm-${local.name_suffix}"
    nic            = "nic-vm-${local.name_suffix}"
    vm             = "vm-${local.name_suffix}"
    os_disk        = "osdisk-vm-${local.name_suffix}"
  }

  common_tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags,
  )
}
