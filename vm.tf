locals {
  ssh_key_pair_create = var.vm_ssh_public_key == ""
}

resource "tls_private_key" "tfca" {
  count     = local.ssh_key_pair_create ? 1 : 0
  algorithm = "RSA"
}

resource "azurerm_linux_virtual_machine" "tfca" {
  name                = "${var.name_prefix}tfca-vm"
  resource_group_name = azurerm_resource_group.tfca_vm.name
  location            = azurerm_resource_group.tfca_vm.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.tfca.id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = local.ssh_key_pair_create ? tls_private_key.tfca[0].public_key_openssh : var.vm_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_source_image_reference.publisher
    offer     = var.vm_source_image_reference.offer
    sku       = var.vm_source_image_reference.sku
    version   = var.vm_source_image_reference.version
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.tmpl", {
    tfca_version = var.tfca_version
    tfca_unit_file = base64gzip(templatefile("${path.module}/templates/tfc-agent.service.tmpl", {
      tfca_user     = var.vm_admin_username
      tfca_group    = var.vm_admin_username
      tfca_env_vars = var.tfca_env_vars
    }))
    tfca_service_enable = var.tfca_service_enable
  }))
}

resource "azurerm_role_assignment" "tfca" {
  count = var.vm_assigned_role_name == "" ? 0 : 1
  scope = data.azurerm_subscription.current.id

  # as per documentation needs to be the "The Scoped-ID" of the Role Definition.
  # passing only the role id from the data source will work on apply
  # but will then generate diffs on subsequent plans as the resource atrribute is actually set as "Scoped".
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.tfca[0].id}"

  principal_id = azurerm_linux_virtual_machine.tfca.identity[0].principal_id
}
