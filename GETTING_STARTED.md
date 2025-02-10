# Getting Started

This project template contains all the necessary files to easily get started with building a Terraform Module.

First, read through the module best practices from Hashicorp:

* [Module Structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure)
* [Publish](https://www.terraform.io/docs/cloud/registry/publish.html)

Next, you'll need to update the following files and sections with your module.

1. __`versions.tf`__:
   1. If you need to restrict usage of this module to specific provider or terraform versions, add the constraints here
   2. Remove the example code
2. __`globals.tf`__:
   1. Add references to other deployments (data blocks) and/or local variables that will be helpful in step 4
   2. Remove the example code
3. __`variables.tf`__:
   1. Create input variables that can/need to be passed into this module, you will reference these in step 4
   2. Remove the example code
4. __`main.tf`__:
   1. Create your main code here, which will manage other resources and/or module calls
      NOTE: Instead of placing in the main.tf file, similar to a Terraform Application, you can create individual .tf files for multiple resources to simplify future changes
   2. Remove the example code
5. __`outputs.tf`__:
   1. Create any output values that should be made available to the project/module calling this module
   2. Remove the example code
6. __`README.md`__:
   1. Follow the instructions in [this file](./TERRAFORM_DOCS_INSTRUCTIONS.md).
7. __`examples`__:
   1. Create a directory for each example/test against this module. It is best practice to cover all "logic" in the module (i.e. if you have a conditional statement, there should be a example for each condition)
   2. Remove the example_a directory & file
8. __`CHANGELOG.md`__:
   1. Create a new change log entry (see [Change Log](#change-log) section)
9. __`CODEOWNERS`__:
   1. Remove the example code
   2. Create entries and/or sections for the files, directories, or patterns and the groups that are required for approval during a Merge Request (MR). See [GitLab Docs](https://docs.gitlab.com/ee/user/project/code_owners.html) for more information and syntax

## Directory Structure

The following displays the directory structure of this template and the purpose for specific files/directories 

      .
      ├── .vscode                      # Settings for Visual Studio Code
      ├── examples                     # Directory containing example module usage/calls for testing and user onboarding
         └── <name>                    # Sub-directory for the example name (i.e. s3-standard, s3-lifecycle)
            └── main.tf                # Example terraform call to the module
      ├── .editorconfig                # File to help with editor differences by OS
      ├── .gitignore                   # Files/Directories to ignore for Git Version Control
      ├── CHANGELOG.md                 # Log of all changes grouped by version
      ├── CODEOWNERS                   # File containing directories/files and specific users or groups that must approve
      ├── README.md                    # Main repo README file
      ├── globals.tf                   # Contains local variables and data blocks for reference across the module
      ├── main.tf                      # Main module code goes here (i.e. resource aws_s3_bucket)
      ├── outputs.tf                   # Variables to provide as output (accessible to the calling project/module)
      ├── variables.tf                 # Input variables to provide to the module
      └── versions.tf                  # Constraints for provider/resource versions (i.e. AWS provider ~> 3.0)

## Change Log

Terraform uses semantic versioning (`<major>.<minor>.<patch>`) and relies on version control software (VCS) tags to identify a new version to publish.

A CHANGELOG file tracks all the changes by version in friendly format, with the format of:

```
   ## Unreleased
      - <Change Type>
         1. <Description>
         2. <Description>

   ## Version ##.##.## - MON DD, YYYY
      - <Change Type>
         1. <Description>
               - Module(s): <module>, <module>
         2. <Description>
               - Module(s): <module>, <module>
```

Where the following placeholders are used as:

| Type         | Description                                                                    |
|--------------|--------------------------------------------------------------------------------|
| type         | Type of change, with acceptable values of <br />* **Added**: New features <br />* **Changed**: Updates to existing features <br />* **Deprecated**: Soon-to-be removed features <br />* **Removed**: Now removed features <br />* **Fixed**: Bug fixes <br />* **Security**: Vulnerability fixes                                           |
| module       | List of file(s) the change applies to                                          |
| description  | Description of the change made                                                 |

Changes are displayed in descending order (most recent first), with an UNRELEASED section at the very top for changes that are pending.