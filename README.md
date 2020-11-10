# Terraform Cloud Agents - Azure VM

A Terraform configuration to bring up a playground for the [TFC Agents](https://www.terraform.io/docs/cloud/workspaces/agent.html) running on an Azure VM.

The configuration will create

* Basic Azure network - a vnet and subnets.
* An Azure Public IP.
* A Security Group  to limit SSH access to specific CIDRs.
* A VM with the Terraform Cloud Agent binaries downloaded and set up as a systemd service.

It is possible to assign a role to the VM so that the Terraform Cloud Agents can perform runs using the [Managed Identity authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity) for the Terraform AzureRM provider.

## Prerequisites

* Terraform, version `>= 0.13`
* `hashicorp/azurerm` provider, version `~> 2.30`
* `hashicorp/tls` provider, version  `~> 3.0`

## Input

The Terraform configuration accepts the following Terraform Input variables:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| name_prefix | `string` | `"tfca-"` | Prefix to use in the names of created resources. |
| location | `string` | | The Azure location in which to create the resources. |
| common_tags | `map(string)` | `{}` |Common tags to assign to all resources. |
| subnet_id | `string` | | The Id of the subnet in which to place the VM. |
| ssh_ingress_cidrs | `list(string)` | `["0.0.0.0/0"]` | List of CIDRs from which incoming SSH connections are allowed. If the list is empty the '0.0.0.0/0' will be used. |
| vm_size | `string` | `"Standard_D2s_v4"` | The size of the virtual machine. |
| vm_admin_username | `string` | `"ubuntu"` | The admin user created on the VM. |
| vm_ssh_public_key | `string` | `""` |An SSH public key to install on the VM. If not provided a new SSH key pair will be generated and used. |
| vm_source_image_reference | `object({ publisher=string, offer=string, sku=string, version=string })` | `{publisher="Canonical", offer="0001-com-ubuntu-server-focal", sku="20_04-lts", version="20.04.202010260" }` | Source reference to the Azure VM image to use. Should be an Ubuntu OS image.If not provided an Ubuntu 20.04 image will be used. |
| vm_assigned_role_name | `string` | `""` | The name of the role definition to assign to the VM. If not provided no roles will be assigned. Assignment will be scoped to the current subscription. |
| tfca_version | `string` | `""` | TFC Agent version to install. If not provided will use the latest one. |
| tfca_service_enable | `bool` | `false` | Whether to enable the Terraform Cloud Agent as service on the VM. |
| tfca_env_vars | `map(string)` | `{}` | A map of environment variables to set up in the Terraform Cloud agent systemd unit file. |

## Output

The Terraform configuration declares the following Terraform Outputs:

| Output | Type | Description |
|--------|------|-------------|
| vm_public_ip | `string` | The public IP of VM. |
| ssh_private_key | `string` | The private key to access the VM. Populated only if the key was created via Terraform. |
| rg_name | `string` | The Name of the resource group containing the VM. |
| vm_name | `string` | The Name of the VM. |
| vm_id | `string` | The Id of the VM. |

## Example use

An example of declaration of the module.

```hcl
module "tfc_agent_vm" {
  source = "git::https://github.com/slavrd/terraform-azurerm-basic-network.git"

  name_prefix = "tfca-vm-example-"
  location    = "westeurope"
  common_tags = {
    peorject = "tfca-vm-example"
  }

  subnet_id             = "/subscriptions/xxxxxxxxxx/resourceGroups/xxxxxxx/providers/Microsoft.Network/virtualNetworks/xxxxxxx/subnets/xxxxxx"
  ssh_ingress_cidrs     = ["0.0.0.0/0"]
  vm_size               = "Standard_D2s_v4"
  vm_admin_username     = "ubuntu"
  vm_ssh_public_key     = ""
  vm_assigned_role_name = "Contributor"
  vm_source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202010260"
  }

  tfca_version        = ""
  tfca_service_enable = true
  tfca_env_vars = {
    TFC_AGENT_TOKEN          = "<TFC_POOL_TOKEN>"
    TFC_AGENT_LOG_LEVEL      = "TRACE"
    TFC_AGENT_DISABLE_UPDATE = "TRUE"
  }
}
```

## Notes

When destroying the infrastructure the Azure VM will not be shut down gracefully. This leads to the Terraform Cloud Agent, running on the VM, going in `unknown` status in the Terraform Cloud Agent pool as it does not shut down gracefully as well. If you want to avoid that need to connect to the VM and shut down the Terraform Cloud Agent service. 

For example if the TLS key pair was created via Terraform and the default VM admin username (`ubuntu`) was used

```bash
terraform output ssh_private_key > ssh.key
chmod 600 ssh.key
ssh -i ssh.key ubuntu@`terraform output vm_public_ip` 'sudo systemctl stop tfc-agent.service'
```

Alternatively can use the Azure CLI to stop the VM

```bash
az vm stop --ids `terraform output vm_id`
```
