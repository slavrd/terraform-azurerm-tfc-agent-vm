
variable "name_prefix" {
  type        = string
  description = "Prefix to use in the names of created resources."
  default     = "tfca-"
}

variable "location" {
  type        = string
  description = "The Azure location in which to create the resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to assign to all resources."
  default     = {}
}

# Network settings

variable "ssh_ingress_cidrs" {
  type        = list(string)
  description = "List of CIDRs from which incoming SSH connections are allowed. If the list is empty the '0.0.0.0/0' will be used."
  default     = ["0.0.0.0/0"]
}

variable "subnet_id" {
  type        = string
  description = "The Id of the subnet in which to place the VM."
}

# VM settings

variable "vm_size" {
  type        = string
  description = "The size of the virtual machine."
  default     = "Standard_D2s_v4"
}

variable "vm_admin_username" {
  type        = string
  description = "The admin user created on the VM."
  default     = "ubuntu"
}

variable "vm_ssh_public_key" {
  type        = string
  description = "An SSH public key to install on the VM. If not provided a new SSH key pair will be generated and used."
  default     = ""
}

variable "vm_source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Source reference to the Azure VM image to use. Should be an Ubuntu OS image.If not provided an Ubuntu 20.04 image will be used."
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202010260"
  }
}

variable "vm_assigned_role_name" {
  type        = string
  description = "The name of the role definition to assign to the VM. If not provided no roles will be assigned. Assignment will be scoped to the current subscription."
  default     = ""
}

# TFC Agent settings

variable "tfca_count" {
  type        = number
  description = "The number of Azure VM instances running a TFC Agent to create. Must be greater than 0."
  default     = 1
  validation {
    condition     = var.tfca_count > 0
    error_message = "The value for 'tfca_count' must be graeter than 0."
  }
}

variable "tfca_version" {
  type        = string
  description = "TFC Agent version to install. If not provided will use the latest one."
  default     = ""
}

variable "tfca_service_enable" {
  type        = bool
  description = "Whether to enable the Terraform Cloud Agent as service on the VM."
  default     = false
}

variable "tfca_pool_token" {
  type        = string
  description = "Pool token to configure for the Terraform Cloud Agents."
}

variable "tfca_name_prefix" {
  type        = string
  description = "A name prefix to use for the Terraform Cloud Agent names."
  default     = "tfca-"
}

variable "tfca_env_vars" {
  type        = map(string)
  description = "A map of environment variables to set up in the Terraform Cloud agent systemd unit file. It must not contain 'TFC_AGENT_TOKEN' or 'TFC_AGENT_NAME' variables."
  default     = {}
  validation {
    condition     = ! (contains(keys(var.tfca_env_vars), "TFC_AGENT_TOKEN") || contains(keys(var.tfca_env_vars), "TFC_AGENT_NAME"))
    error_message = "The map for tfca_env_vars must not contain keys 'TFC_AGENT_TOKEN' or 'TFC_AGENT_NAME'."
  }
}
