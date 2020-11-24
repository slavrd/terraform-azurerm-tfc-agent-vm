module "tfc_agent_vm" {
  source = "../../"

  name_prefix = var.name_prefix
  location    = var.location
  common_tags = var.common_tags

  subnet_id                 = values(module.network.subnets)[0].id
  ssh_ingress_cidrs         = var.ssh_ingress_cidrs
  vm_size                   = var.vm_size
  vm_admin_username         = var.vm_admin_username
  vm_ssh_public_key         = var.vm_ssh_public_key
  vm_assigned_role_name     = var.vm_assigned_role_name
  vm_source_image_reference = var.vm_source_image_reference

  tfca_version        = var.tfca_version
  tfca_service_enable = var.tfca_service_enable
  tfca_env_vars       = var.tfca_env_vars
}

module "network" {
  source = "git::https://github.com/slavrd/terraform-azurerm-basic-network.git?ref=0.1.0"

  rg_name           = "${var.name_prefix}network"
  location          = var.location
  vnet_name         = "${var.name_prefix}vnet"
  vnet_cidrs        = [var.vnet_cidr]
  vnet_subnet_cidrs = [var.subnet_cidr]

  common_tags = var.common_tags
}

resource "local_file" "foo" {
  content         = module.tfc_agent_vm.ssh_private_key
  filename        = "${path.module}/ssh.key"
  file_permission = "0600"
}

provider "azurerm" {
  features {}
}
