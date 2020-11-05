
variable "name_prefix" {
  type        = string
  description = "Prefix to use in the names of created resources."
  default     = "tfca-"
}

variable "location" {
  type        = string
  description = "The Azure location in which to create the resources."
  default     = ""
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to assign to all resources."
  default     = {}
}

# Network settings

variable "vnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for the Azure virtual network address spaces."
}

variable "vnet_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for subnets creation. It's meaningless to set this if vnet_address_space is not set also. It's the user's responsibility to ensure that the subnets are calculated correctly."
  default     = []
}

variable "ssh_ingress_cidrs" {
  type        = list(string)
  description = "List of CIDRs from which incoming SSH connections are allowed. If the list is empty the '0.0.0.0/0' will be used."
  default     = ["0.0.0.0/0"]
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
  description = "Soure reference to the Azure VM image to use. Should be an Ubuntu OS image.If not provided an Ubuntu 20.04 image will be used."
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202010260"
  }
}

variable "vm_assigned_role_name" {
  type        = string
  description = "The name of the role deffinition to assign to the VM. If not provided no roles will be assigned. Assignment will be socped to the curernt subscription."
  default     = ""
}

# TFC Agent settings

variable "tfca_version" {
  type        = string
  description = "TFC Agent version to install. If not provided will use the latest one."
  default     = ""
}
