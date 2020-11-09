output "vm_public_ip" {
  description = "The public IP of VM."
  value       = data.azurerm_public_ip.tfca.ip_address
}

output "ssh_private_key" {
  description = "The private key to access the VM. Populated only if the key was created via Terraform."
  value       = try(tls_private_key.tfca[0].private_key_pem, "")
}