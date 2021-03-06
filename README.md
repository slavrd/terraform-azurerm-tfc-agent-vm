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
| tfca_count | `number` | `1` | The number of Azure VM instances running a TFC Agent to create. Must be greater than 0. |
| tfca_version | `string` | `""` | TFC Agent version to install. If not provided will use the latest one. |
| tfca_service_enable | `bool` | `false` | Whether to enable the Terraform Cloud Agent as service on the VM. |
| tfca_pool_token | `string` | | Pool token to configure for the Terraform Cloud Agents. |
| tfca_name_prefix | `string` | `tfca-` | A name prefix to use for the Terraform Cloud Agent names. |
| tfca_env_vars | `map(string)` | `{}` | A map of environment variables to set up in the Terraform Cloud agent systemd unit file. It must not contain 'TFC_AGENT_TOKEN' or 'TFC_AGENT_NAME' variables. |

## Output

The Terraform configuration declares the following Terraform Outputs:

| Output | Type | Description |
|--------|------|-------------|
| vm_public_ip | `map(string)` | A mapping of the Azure public IPs assigned to the VMs and their values. |
| ssh_private_key | `string` | The private key to access the VM. Populated only if the key was created via Terraform. |
| rg_name | `string` | The Name of the resource group containing the VM. |
| vm_name | `list(string)` | The Name of the VM. |
| vm_id | `list(string)` | The Ids of the VMs. |

## Example use

An example of declaration of the module.

```hcl
module "tfc_agent_vm" {
  source = "git::https://github.com/slavrd/terraform-azurerm-tfc-agent-vm.git"

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
  tfca_pool_token     = "<TFC_POOL_TOKEN>"
  tfca_name_prefix    = "tfca-"
  tfca_env_vars = {
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
## Testing

Tests for the module are set up using `kitchen` and `kitchen-terraform` to run `inspec` tests.

Terraform variables which control the resources created during the test are set up in `test/fixtures/test.tfvars` file.

### Prerequisites

To run the tests you will need the following

* Have Ruby installed, version `~> 2.7.2`. It is recommended to use a ruby versions manager like `rbenv` and not your system ruby installation.
* Have the Ruby Gems specified in the `Gemfile` file installed. It is recommended to use `bundler`.

  ```bash
  gem install bundler
  bundle install
  ```
* Have Terraform installed, version `>= 0.13`.

### Running tests

* Set up the credentials for the AzureRM provider as described [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure). For example, using the Azure CLI:

  ```bash
  az login
  ```

* Set up Azure credentials for Inspec as described [here](https://docs.chef.io/inspec/platforms/#azure-platform-support-in-inspec). For example, using Service Principal and Client Secret in Environment variables:

  ```bash
  export AZURE_CLIENT_ID='xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
  export AZURE_CLIENT_SECRET='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  export AZURE_SUBSCRIPTION_ID='xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
  export AZURE_TENANT_ID='xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'
  ```
* (optional) Adjust Terraform input variables in `test/fixtures/test.tfvars`
* Use `kitchen` to execute the tests
  * Converge the testing environment.

  ```bash
  bundle exec kitchen converge
  ```

  * Execute the tests.

  ```bash
  bundle exec kitchen verify
  ```

  * Destroy the testing environment.

  ```bash
  bundle exec kitchen destroy
  ```
