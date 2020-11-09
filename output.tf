output "vm_public_ip" {
  description = "The public IP of VM."
  value       = data.azurerm_public_ip.tfca.ip_address
}

output "ssh_private_key" {
  description = "The private key to access the VM. Populated only if the key was created via Terraform."
  value       = try(tls_private_key.tfca[0].private_key_pem, null)
}

output "rg_name" {
  description = "The Name of the resource group containing the VM."
  value = azurerm_resource_group.tfca_vm.name
}

output "vm_name" {
  description = "The Name of the VM."
  value = azurerm_linux_virtual_machine.tfca.name
}

output "vm_id" {
  description = "The Id of the VM."
  value = azurerm_linux_virtual_machine.tfca.id
}