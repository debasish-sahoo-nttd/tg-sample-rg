# tg-sample-resource_group

This repository containse the terragrunt configuration files to provision Resource Groups in Azure. This terragrunt repository is built around the terraform repository [TF Resource Group](https://github.com/launchbynttdata/tf-azurerm-module_primitive-resource_group.git)

Terragrunt currently doesn't support automatic creation of the storage account and container for storing the terraform state. The user has to manually create the storage account and container and update the `backend.yaml` file in each environment directory.

## Directory structure

- [accounts.yaml](accounts.yaml) - Contains the list of accounts and their subscription ids currently. Later we may use the Service Connection instead of Subscription IDs as the later can be set in the pipeline using environment variables. But for organizations having multiple subscriptions for different environment, it's useful to have service connection names stored in this file. The pipeline can then read the file to use the respective service connection.

- [service.hcl](service.hcl) - Contains the details of the terraform module that this terragrunt repository is wrapping around. This file is used to pass the module details to the terragrunt configuration files.

- [terragrunt.hcl](terragrunt.hcl) at the root level - Contains the terragrunt configuration for the root module. This file is used to pass the backend configuration to the terragrunt configuration files.

```shell
.
├── env
│   ├── prod
│   │   ├── eastus
│   │   │   ├── 000
│   │   │   │   ├── backend.yaml
│   │   │   │   ├── git_tag.yaml
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── terragrunt.hcl
│   │   │   └── region.hcl
│   │   └── account.hcl
│   ├── qa
│   │   ├── eastus
│   │   │   ├── 000
│   │   │   │   ├── backend.yaml
│   │   │   │   ├── git_tag.yaml
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── terragrunt.hcl
│   │   │   └── region.hcl
│   │   └── account.hcl
│   ├── sandbox
│   │   ├── eastus
│   │   │   ├── 000
│   │   │   │   ├── backend.yaml
│   │   │   │   ├── git_tag.yaml
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── 001
│   │   │   │   ├── backend.yaml
│   │   │   │   ├── git_tag.yaml
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── terragrunt.hcl
│   │   │   └── region.hcl
│   │   └── account.hcl
│   └── uat
│       ├── eastus
│       │   ├── 000
│       │   │   ├── backend.yaml
│       │   │   ├── git_tag.yaml
│       │   │   ├── terraform.tfvars
│       │   │   └── terragrunt.hcl
│       │   └── region.hcl
│       └── account.hcl
├── pipelines
│   ├── templates
│   │   ├── jobs
│   │   ├── stages
│   │   │   └── terragrunt.yaml
│   │   └── steps
│   └── azure-pipelines.yaml
├── README.md
├── accounts.yaml
├── service.hcl
└── terragrunt.hcl

```

# Pre-requisites

- Ensure that the storage account and container for storing the terraform state already exists. The information is added  to `backend.yaml` file in each environment directory. For example `env/dev/eastus/000/backend.yaml`
- Ensure the correct terraform module tag is updated in `git_tag.yaml`
- Ensure the `terraform.tfvars` file is updated with the correct values that the wrapped terraform module expects.
- When deploying from local laptop, ensure you are logged in to azure cli using `az login` command
- Ensure terraform and terragrunt binaries are already installed on your local. See [.tool-versions](.tool-versions) for the list of dependencies in case you are using `asdf` to manage dependencies

# Deploy Infrastructure

Once the pre-requisites are satisfied, user needs to navigate to the desired directory which they want to provision (directory that contains `terragrunt.hcl`). For example `env/dev/eastus/000`

Run the below commands

```bash
# Export the environment specific env vars
# (optional) only required if deploying in US Gov cloud
export ARM_ENVIRONMENT=usgovernment

export ARM_SUBSCRIPTION_ID=<subscription_id>
# Navigate to the directory you want to provision infrastructure for.
cd env/dev/eastus/000
# This will download all the dependent modules and initialize the backend
terragrunt init
# This will output a plan of what infrastructures are going to be provisioned
terragrunt plan
# This will deploy the infrastructure as were shown in the plan above. The `-auto-approve` flag doesn't require an user approval to proceed
terragrunt apply -auto-approve

```


# ADO pipeline

The ADO pipeline is located at `pipelines/azure-pipelines.yaml`. Currently the trigger is disabled, so the user has to manually run the pipeline after every PR is merged to `main`. When the trigger is enabled, the pipeline will run automatically after every PR is merged to `main`. 

Trigger can be enabled by adding the below line

```
trigger: main
```

Every time a new environent is added say `001`, or an env to a new region say `eastus2/000`, it's the responsibility of the  user to update the pipeline to reflect the new env. The pipeline itself is completely templated, meaning the user just has to pass in the new env details as inputs to a template and has to place it at the correct
location.

# References

1. [ASDF](https://asdf-vm.com/guide/getting-started.html)
2. [Terragrunt](https://terragrunt.gruntwork.io/docs/)
3. [Terraform Azure provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
4. [Terraform AKS Module](https://github.com/launchbynttdata/tf-azurerm-module_reference-kubernetes_cluster)