# Deploy Persistent Storage for an HPCC Systems cluster on Azure

This is a slightly-opinionated Terraform module for deploying persistent storage for an HPCC Systems cluster on Azure.  Data saved within the storage account will outlive the Kubernetes cluster hosting an HPCC Systems cluster, which is usually a very desirable feature.

Once you create a storage account you can create the associated HPCC Systems cluster by deploying the Terraform module located at [https://github.com/dcamper/terraform-azurerm-hpcc-aks](https://github.com/dcamper/terraform-azurerm-hpcc-aks).

This repo is a fork of the excellent work performed by Godson Fortil.  The original can be found at [https://github.com/hpcc-systems/terraform-azurerm-hpcc-aks](https://github.com/hpcc-systems/terraform-azurerm-hpcc-aks).

## Requirements

* This is a Terraform module, so you need to have Terraform installed on your system.  Instructions for downloading and installing Terraform can be found at [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).

* The Kubernetes client (kubectl) is also required so you can inspect and manage the Azure Kubernetes cluster.  Instructions for download and installing that can be found at [https://kubernetes.io/releases/download/](https://kubernetes.io/releases/download/).  Make sure you have version 1.22.0 or later.

* To work with Azure, you will need to install the Azure Command Line tools.  Instructions can be found at [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

* This module will create a storage account in your current default Azure subscription.  You can view your current subscriptions, and determine which is the default, using the `az account list --output table` command.  To set a default subscription, use `az account set --subscription "My Subscription"`.

* To successfully create everything you will need to have Azure's `Contributor` role plus access to `Microsoft.Authorization/*/Write` and `Microsoft.Authorization/*/Delete` permissions on your subscription.  You may have to create a custom role for this.  Of course, Azure's `Owner` role includes everything so if you're the subscription's owner then you're good to go.

## Installing/Using This Module

1. If necessary, login to Azure.
	* From the command line, this is usually accomplished with the `az login` command.
1. Clone this repo to your local system and change current directory.
	* `git clone https://github.com/dcamper/terraform-azurerm-hpcc-storage.git`
	* `cd terraform-azurerm-hpcc-storage`
1. Issue `terraform init` to initialize the Terraform modules.
1. Decide how you want to supply option values to the module during invocation.  There are three possibilities:
	1. Invoke the `terraform apply` command and enter values for each option as Terraform prompts for it, then enter `yes` at the final prompt to begin building the storage account.
	1. **Recommended:**  Create a `terraform.tfvars` file containing the values for each option, invoke `terraform apply`, then enter `yes` at the final prompt to begin building the storage account.  The easiest way to do that is to copy the sample file and then edit the copy:
		* `cp examples/sample.tfvars terraform.tfvars`
	1. Use -var arguments on the command line when executing the terraform tool to set each of the values found in the .tfvars file.  This method is useful if you are driving the creation of the cluster from a script.
1. If you are attaching this Terraform module to an existing storage account, you should run `terraform apply --refresh-only` in order for Terraform to populate the local state file with information about your existing configration.  Afterwards, you should use `terraform plan` to ensure that it makes only the appropriate updates and does not destroy any resources unnecessarily.

Several items are shown at the end of a successful deployment:
* The Azure subscription ID under which these resources were created.
* The Azure region in which these resources were created.
* The storage account resource group name.
* The storage account name (created within the resource group).

## Available Options

Options have data types.  The ones used in this module are:
* string
	* Typical string enclosed by quotes
	* Example
		* `"value"`
* number
	* Integer number; do not quote
	* Example
		* `1234`
* boolean
	* true or false (not quoted)
* map of string
	* List of key/value pairs, delimited by commas
	* Both key and value should be a quote string
	* Entire map is enclosed by braces
	* Example with two key/value pairs
		* `{"key1" = "value1", "key2" = "value2"}`
	* Empty value is `{}`

The following options should be set in your `terraform.tfvars` file (or entered interactively, if you choose to not create a file):

|Option|Type|Description|
|:-----|:---|:----------|
| `admin_email` | string  | Email address of the administrator of this storage account. |
| `admin_name` | string  | Name of the administrator of this storage account. |
| `admin_username` | string  | Username of the administrator of this storage account. |
| `azure_region` | string  | The Azure region abbreviation in which to create these resources. Must be one of ["east", "eastus2", "centralus"]. |
| `enable_premium_storage` | boolean  | If true, premium ($$$) storage will be created for the following storage shares: Dali. ***OPTIONAL, defaults to false.*** |
| `extra_tags` | map of string  | Map of name => value tags that can will be associated with the storage account. To add no additional tags, use `{}`. ***OPTIONAL, defaults to an empty string map.*** |
| `product_name` | string | Abbreviated product name, suitable for use in Azure naming. Must be 2-23 characters in length, all lowercase letters or numbers, no spaces Because this name will appear in the Azure portal, you may want to consider including the word 'data' or 'storage' somewhere in the name. |
| `storage_dali_gb` | number  | The amount of storage reserved for Dali in gigabytes. Must be 10 or more. ***OPTIONAL, defaults to 250.*** |
| `storage_data_gb` | number  | The amount of storage reserved for data in gigabytes. Must be 10 or more. ***OPTIONAL, defaults to 500.*** |
| `storage_lz_gb` | number  | The amount of storage reserved for the landing zone in gigabytes. Must be 1 or more. ***OPTIONAL, defaults to 10.*** |

## Recommendations

* Do create a `terraform.tfvars` file.  Terraform automatically uses it for `terraform apply` and `terraform plan` commands.  If you don't name it exactly that name, you can supply the filename with a `-var-file` option but you will have to remember to always cite that file for the future (if you want to update the storage account, or destroy it).  It is easier to just let Terraform find the file.
	* If you don't create a .tfvars file at all and just let Terraform prompt you for the options, then updating or destroying an existing storage account will be *much* more difficult (you will have to reenter everything and it all **must** match your previous entries if you don't want to introduce chaos).
* Do not use the same repo clone for different concurrent deployments.
	* Terraform creates state files (*.tfstate) that represent what thinks reality is.  If you try to manage multiple storage accounts, Terraform will get confused.
	* For each deployed storage account, re-clone the repo to a different directory on your local system.
* The option `enable_premium_storage`, if true, creates a second Azure Storage Account in the same resource group.  This second storage account uses a different type of storage that is significantly faster but also more expensive, then creates a file share for Dali within it.  The result is a *much* snappier HPCC Systems cluster.  If you can afford it, we recommend using this option.
   * Note that you will need to enable the `enable_premium_storage` option within the HPCC Systems Terraform module as well, in order to tell that module to look for this high-speed storage account.

## Useful Things

* If a deployment fails and you want to start over, you have two options:
	* Immediately issue a `terraform destroy` command and let Terraform clean up.
	* Clean up the resources by hand:
		* Delete the Azure resource group manually, such as through the Azure Portal.
		* Delete all Terraform state files using `rm *.tfstate*`
	* Then, of course, fix whatever caused the deployment to fail.
* If want to completely reset Terraform, issue `rm -rf .terraform* *.tfstate*` and then `terraform init`.
