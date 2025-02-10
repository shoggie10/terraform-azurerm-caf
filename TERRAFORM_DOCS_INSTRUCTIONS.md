# Using Terraform Docs
[__`terraform-docs`__](https://terraform-docs.io/) is a Homebrew package used to automatically generate README files for terraform modules.

## Install terraform-docs
1. From a terminal, run `brew install terraform-docs`.

## Create configuration file
1. In the content section of [this YAML file](./.terraform-docs.yml), add the module's name, a short description, and the relative path to the example file.
2. Remove TODO statements from YAML file.

## Run terraform-docs
1. From the root directory of the terraform module, run `terraform-docs -c .terraform-docs.yml .`. This will generate a README file for the terraform module containing all relevant information.