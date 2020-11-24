output "vm_public_ip" {
  description = "The public IP of VM."
  value       = module.tfc_agent_vm.vm_public_ip
}

output "rg_name" {
  description = "The Name of the resource group containing the VM."
  value       = module.tfc_agent_vm.rg_name
}

output "vm_name" {
  description = "The Name of the VM."
  value       = module.tfc_agent_vm.vm_name
}

output "vm_id" {
  description = "The Id of the VM."
  value       = module.tfc_agent_vm.vm_id
}

# Seems the simplest way to parse a complex value for an input variable.
output "var_tfca_env_vars" {
  description = "The value of input variable tfca_env_vars"
  value       = var.tfca_env_vars
}