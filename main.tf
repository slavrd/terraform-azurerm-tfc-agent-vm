resource "azurerm_resource_group" "tfca_vm" {
  name     = "${var.name_prefix}tfca-vm"
  location = var.location
  tags     = var.common_tags
}

# The pulic IP address will be available only after the Azure public IP is associated with a VM
# and so cannot be retrieved from the azurerm_public_ip resource directly. 
data "azurerm_public_ip" "tfca" {
  count               = var.tfca_count
  name                = azurerm_public_ip.tfca[count.index].name
  resource_group_name = azurerm_resource_group.tfca_vm.name
  depends_on = [
    azurerm_linux_virtual_machine.tfca
  ]
}

data "azurerm_role_definition" "tfca" {
  count = var.vm_assigned_role_name == "" ? 0 : 1
  name  = var.vm_assigned_role_name
}

data "azurerm_subscription" "current" {}