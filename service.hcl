
# This file has been generated using the launch-cli
terraform {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-resource_group.git//.?ref=${local.git_tag}"
}

locals {
  inputs = yamldecode(file("${get_terragrunt_dir()}/./git_tag.yaml"))
  git_tag = local.inputs.git_tag
}