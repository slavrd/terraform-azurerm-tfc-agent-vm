module "network" {
  source = "git::https://github.com/slavrd/terraform-azurerm-basic-network.git?ref=0.1.0"

  rg_name           = "${var.name_prefix}network"
  location          = var.location
  rg_create         = true
  vnet_name         = "${var.name_prefix}vnet"
  vnet_cidrs        = var.vnet_cidrs
  vnet_subnet_cidrs = var.vnet_subnet_cidrs

  common_tags = var.common_tags
}