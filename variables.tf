############################
# General
############################

variable "project" {
  description = "Short project/workload name, used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,12}$", var.project))
    error_message = "project must be 2-12 lowercase letters or digits."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region, e.g. australiaeast."
  type        = string
}

variable "tags" {
  description = "Additional tags merged onto every resource."
  type        = map(string)
  default     = {}
}

############################
# Networking
############################

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = alltrue([for c in var.vnet_address_space : can(cidrhost(c, 0))])
    error_message = "All vnet_address_space entries must be valid CIDR blocks."
  }
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the VM subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]

  validation {
    condition     = alltrue([for c in var.subnet_address_prefixes : can(cidrhost(c, 0))])
    error_message = "All subnet_address_prefixes entries must be valid CIDR blocks."
  }
}

variable "allowed_ssh_cidrs" {
  description = "Source CIDRs allowed to SSH to the VM. Leave empty to block SSH from outside the VNet (e.g. when using Azure Bastion)."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for c in var.allowed_ssh_cidrs : can(cidrhost(c, 0))])
    error_message = "All allowed_ssh_cidrs entries must be valid CIDR blocks."
  }

  validation {
    condition     = !contains(var.allowed_ssh_cidrs, "0.0.0.0/0")
    error_message = "Opening SSH to the whole internet (0.0.0.0/0) is not allowed."
  }
}

variable "create_public_ip" {
  description = "Whether to attach a public IP to the VM. Prefer false and use Bastion/VPN."
  type        = bool
  default     = false
}

############################
# Virtual machine
############################

variable "vm_size" {
  description = "VM SKU."
  type        = string
  default     = "Standard_B2s"
}

variable "zone" {
  description = "Availability zone (\"1\", \"2\", \"3\") or null for no zone."
  type        = string
  default     = null

  validation {
    condition     = var.zone == null || contains(["1", "2", "3"], coalesce(var.zone, "x"))
    error_message = "zone must be \"1\", \"2\", \"3\" or null."
  }
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"

  validation {
    condition     = !contains(["admin", "administrator", "root", "user", "guest", "test"], lower(var.admin_username))
    error_message = "admin_username uses a name Azure reserves or blocks."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for VM login."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "os_disk" {
  description = "OS disk settings."
  type = object({
    storage_account_type = optional(string, "StandardSSD_LRS")
    disk_size_gb         = optional(number, 64)
  })
  default = {}

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk.storage_account_type)
    error_message = "Unsupported os_disk.storage_account_type."
  }
}

variable "image" {
  description = "Marketplace image to deploy. Default is Ubuntu 24.04 LTS (Gen2)."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

variable "custom_data_path" {
  description = "Optional path to a cloud-init file. null to skip."
  type        = string
  default     = null
}

############################
# Cost control
############################

variable "auto_shutdown" {
  description = "Daily auto-shutdown schedule (useful for non-prod)."
  type = object({
    enabled  = bool
    time     = optional(string, "1900") # HHmm, 24h
    timezone = optional(string, "UTC")  # Windows time zone ID, e.g. "AUS Eastern Standard Time"
  })
  default = {
    enabled = false
  }
}
