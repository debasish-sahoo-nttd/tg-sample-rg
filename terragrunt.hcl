
# This file has been generated using the launch-cli
locals {
  # Inputs that can be shared across all the child modules
  #naming_prefix = "dsok8s"
  accounts = yamldecode(file("accounts.yaml"))
  # Loads the account related details like account name, id etc.
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  backend_vars = yamldecode(file("${get_terragrunt_dir()}/./backend.yaml"))

  # Loads the aws region information
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  account_name = local.account_vars.locals.account_name
  region       = local.region_vars.locals.region
  # Subscription id for the account
  #subscriptions = {"sandbox": "4554e249-e00f-4668-9be3-da31ed200163"}
  subscription_id = local.accounts[local.account_name]

  # uuid = read_terragrunt_config("${get_terragrunt_dir()}/uuid.hcl").locals.uuid
  relative_path      = path_relative_to_include()
  environment_instance = basename(local.relative_path)
  backend_rg_name              = local.backend_vars.resource_group_name
  backend_storage_account_name = local.backend_vars.storage_account_name # 24 chars limit
  backend_container_name       = local.backend_vars.container_name
}

# Generate Azure providers
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_version = "<= 1.5.5"
      required_providers {
        azurerm = {
          source = "hashicorp/azurerm"
          version = ">=3.77.0"
        }
      }
    }

    provider "azurerm" {
      features {
        resource_group {
          prevent_deletion_if_contains_resources = false
        }
      }
      subscription_id = "${local.subscription_id}"
    }
EOF
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    key                  = "terraform.tfstate"
    resource_group_name  = local.backend_rg_name
    storage_account_name = local.backend_storage_account_name
    container_name       = local.backend_container_name
  }
}