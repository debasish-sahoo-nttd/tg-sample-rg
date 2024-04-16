# tg-sample-rg

## Directory structure

```shell
.
├── env
│   ├── prod
│   │   └── eastus
│   │       └── 000
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
│   │   │   └── region.hcl
│   │   └── account.hcl
│   └── uat
│       └── eastus
│           └── 000
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

## Proposed changes

- currently creating the tg repo manually than using `launch service create/update` as the later still has many issues
- changed the `accounts.json` to `accounts.yaml` for consistency across the platform to use `yaml` files
- State bucket creation: Added a file `backend.yaml` at the same level as each env's `terragrunt.hcl` where we ask users to 
  enter the storage account details manually than auto generating it. It is inline with what terragrunt does for aws and gcp
  where it auto-generates the buckets. Users to ensure the storage account is created before running `terragrunt init`
- No need for a separate properties repo as all files except the properties are static and would never change. Each env is pinned to 
  a specific tag of the corresponding to terraform module with git tag specified in `git_tag.yaml`. Each env will have its 
  own `terraform.tfvars` file
- Current CD pipeline will deploy env in sequence. `sandobox -> QA -> UAT -> Prod`, with ability to have a manual approval step 
  in each environment between the `plan` and `apply` stages. This is achieved by leveraging ADO Environment feature.


## ADO pipeline

The ADO pipeline is located at `pipelines/azure-pipelines.yaml`. Every time a new environent is added say `001`, or an env to a new region
say `eastus2/000`, it's the responsibility of the  user to update the pipeline to reflect the new env. The pipeline itself is 
completely templated, meaning the user just has to pass in the new env details as inputs to a template and has to place it at the correct
location.

## Questions

- What checks should be run in the CI pipeline. (when a PR is create/update/modified)
  - `terragrunt validate` to check the syntax of the terragrunt files
  - `terragrunt fmt`
- Do we need to run them on all the envs we have in this repo? Or somehow find out the affected envs as part of this PR
    and run only on them. I havent explored the option of how to do the later
- 