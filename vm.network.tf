resource "azurerm_public_ip" "tfca" {
  count = var.tfca_count

  # cannot use the name prefix because of specific restrictions
  name = "tfcaVMPublicIP${count.index}"

  resource_group_name = azurerm_resource_group.tfca_vm.name
  location            = azurerm_resource_group.tfca_vm.location
  allocation_method   = "Dynamic"

  tags = var.common_tags
}

resource "azurerm_network_interface" "tfca" {
  count               = var.tfca_count
  name                = "${var.name_prefix}vm-interface-${count.index}"
  resource_group_name = azurerm_resource_group.tfca_vm.name
  location            = azurerm_resource_group.tfca_vm.location

  ip_configuration {
    name                          = "${var.name_prefix}vm-ip-config-${count.index}"
    primary                       = true
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfca[count.index].id
  }

  tags = var.common_tags
}

resource "azurerm_network_security_group" "tfca" {

  # cannot use the name prefix because of specific restrictions
  name = "tfcaVMInterfaceSG"

  resource_group_name = azurerm_resource_group.tfca_vm.name
  location            = azurerm_resource_group.tfca_vm.location

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.ssh_ingress_cidrs
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "tfca" {
  count                     = var.tfca_count
  network_interface_id      = azurerm_network_interface.tfca[count.index].id
  network_security_group_id = azurerm_network_security_group.tfca.id
}