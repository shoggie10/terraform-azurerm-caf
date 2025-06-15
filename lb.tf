module "lb" {
  source   = "./modules/networking/lb"
  for_each = local.networking.lb

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group      = local.combined_objects_resource_groups
    virtual_network     = local.combined_objects_networking
    public_ip_addresses = local.combined_objects_public_ip_addresses
  }
}
output "lb" {
  value = module.lb
}
====================||===========
When creating a new agent in **Microsoft Copilot Studio**, it's important to define the **name**, **description**, and **tone** to ensure the chatbot aligns with the **brand**, **purpose**, and **audience** it will serve. Here’s how you can approach these settings, referencing typical **Microsoft Copilot Studio** styles.

---

### **1. Agent Name**:

The **agent name** should be clear, concise, and represent the bot's function. Since the bot will be focused on retrieving documents, links, content, and context from your organization and cloud engineering department, the name should reflect that purpose.

**Examples**:

* **EngageBot** (reflecting a conversational agent that engages with users to provide information)
* **CloudAssist** (focused on helping with cloud-related information and tasks)
* **CloudDocsBot** (focused on retrieving documents and relevant content)
* **EngineeringHelpBot** (focused on serving the cloud engineering department)

**Recommendation**: Go with something like **CloudAssist** or **EngineeringHelpBot**, based on the primary function of the bot.

---

### **2. Agent Description**:

The **description** should explain what the bot does and its value to the user. It should clearly communicate the bot’s role and the services it provides.

**Example**:
"**CloudAssist** is a chatbot designed to assist users in retrieving relevant documents, content, links, and context from internal resources such as **SharePoint**, **Teams**, and cloud engineering databases. It helps with quick document access, answering questions, and providing the right resources to enhance productivity."

**Recommendation**: Describe the bot’s capabilities in terms of accessing cloud engineering resources, retrieving documents, and aiding with general queries across **SharePoint**, **Teams**, and **cloud services**.

---

### **3. Agent Tone**:

The **tone** should reflect the way your bot interacts with users. Since this is a **cloud engineering department** bot, you should opt for a tone that’s **professional**, **helpful**, and **efficient**, while still being conversational.

**Example**:

* **Tone**: Professional, Concise, and Supportive
* **Tone description**: “The bot should respond in a clear, concise manner, using professional language suitable for engineers and technical users. It should be helpful but to the point, ensuring that users can quickly access the information they need without unnecessary jargon.”

**Recommendation**: Choose **Professional**, **Concise**, and **Supportive** as the tone.

---

### **4. Other Parameters to Consider in Copilot Studio**:

Microsoft Copilot Studio typically requires you to specify a few other things about your agent:

#### **4.1. Agent Purpose**:

* **Purpose**: To help users access cloud engineering resources, documents, and internal data stored in systems like **SharePoint** and **Teams**. It should streamline access to information and make knowledge retrieval as efficient as possible.

#### **4.2. Keywords**:

* **Keywords** help the agent understand the common phrases or topics it might be asked about. For your use case, some keywords could include:

  * **Cloud engineering**
  * **Document retrieval**
  * **Teams files**
  * **SharePoint access**
  * **Knowledge base**
  * **Cloud resources**

---

### **Example Configuration for Copilot Studio**:

* **Agent Name**: **CloudAssist**
* **Description**: “**CloudAssist** is a chatbot designed to assist users in retrieving relevant documents, content, links, and context from internal resources such as **SharePoint**, **Teams**, and cloud engineering databases. It helps with quick document access, answering questions, and providing the right resources to enhance productivity.”
* **Tone**: Professional, Concise, Supportive
* **Purpose**: Assist users in cloud engineering departments with retrieving relevant documents, content, and other resources.
* **Keywords**: cloud engineering, document retrieval, SharePoint, Teams, cloud resources, knowledge base, cloud assist

---

### **5. Customization for Your Department**:

Since the bot will serve your **cloud engineering department**, you might want to tailor it to fit the specific jargon or needs of the department. For example, you could:

* Include terms or acronyms specific to your department (e.g., **CI/CD**, **Terraform**, **Azure**).
* Focus more on **engineering documentation** like **design documents**, **deployment guides**, **service manuals**, etc.

---

### **Final Thoughts**:

* **Agent Name**: Choose a name that reflects its role in **cloud engineering** (e.g., **CloudAssist**, **EngineeringHelpBot**).
* **Description**: Describe the bot’s role in helping retrieve documents and resources from **SharePoint**, **Teams**, and internal systems.
* **Tone**: Use a **professional**, **concise**, and **supportive** tone to align with your department’s culture and needs.

Would you like to move forward with setting up this agent in **Copilot Studio** now, or do you need more detailed guidance on the setup process?

=================||
You need to configure at least one channel (for example, Teams) due to recent DLP policy changes. Contact your admin with questions (svc_powerplatcoe@xxxx.onmicrosoft.com).

=====||===







=========





======||===

-----\\---





-----------------------------------------------------

## examples
terraform {
  required_version = ">=1.3.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "<3.0.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "<1.5.0"
    }
    random = {}
  }
}

provider "azuread" {}
provider "azuredevops" {}

resource "random_integer" "orgfeed" {
  min = 1111
  max = 9999
}

resource "random_integer" "projectfeed" {
  min = 1111
  max = 9999
}

data "azuredevops_team" "reviewer" {
  name       = "TerraformModuleTest5 Team"
  project_id = module.project4.id
}

data "azuredevops_group" "reviewer" {
  name       = "Limited Project Administrators"
  project_id = module.project4.id
}

module "sec9ka" {
  #source  = "../../terraform-ado-user"

  source  = "app.terraform.io/xxxx/user/ado"
  version = "< 0.2.0"

  email = "salonge@xxxx.com"
}

module "project4" {
  #source = "../"

  source  = "app.terraform.io/xxxx/project/ado"
  version = "< 3.0.0"

  project_name                   = "TerraformModuleTest5"
  project_description            = "This is a project to test the Terraform module"
  default_num_approvals_required = 2

  additional_aad_groups = [
    "xxxx-gbl-aadg-ADO-OrgAdmins"
  ]

  project_repo_reviewer_policies = {
    "default_optional" = {
      match_type    = "DefaultBranch"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = false
      reviewer_ids = [
        module.sec9ka.id
      ]
    }
    "default_required" = {
      match_type    = "DefaultBranch"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = true
      reviewer_ids = [
        data.azuredevops_group.reviewer.origin_id,
        data.azuredevops_team.reviewer.id
      ]
    }
    "main" = {
      match_type    = "Exact"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = false
      reviewer_ids = [
        module.sec9ka.id
      ]
      repository_ref = "refs/heads/master"
    }
    "dev" = {
      match_type    = "Exact"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = false
      reviewer_ids = [
        module.sec9ka.id,
        data.azuredevops_group.reviewer.origin_id,
        data.azuredevops_team.reviewer.id
      ]
      repository_ref = "refs/heads/dev"
    }
    "release" = {
      match_type    = "Prefix"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = true
      reviewer_ids = [
        data.azuredevops_group.reviewer.origin_id
      ]
      repository_ref = "refs/heads/releases"
    }
  }

  override_group_prefix = "TerraformModuleTest"

  readers_enabled                = true
  project_admins_enabled         = true
  limited_project_admins_enabled = true
  build_admins_enabled           = true

  project_artifacts_enabled = true

  project_teams = ["Team1", "Team2"]

  repos = ["TF.Module.Test", "New Repo", "Third Repo"]

  pipelines = {
    "pipeline1" = {
      associated_repository = "TF.Module.Test"
    }
    "pipeline2" = {
      associated_repository = "New Repo"
      yaml_file_path        = "release/azure-pipelines.yml"
    }
    "Third Repo" = {}
  }

  deployment_environments = {
    pipeline1 = {
      authorized_pipeline_names = ["pipeline1"]
    }
    shared-environment = {
      authorized_pipeline_names = ["pipeline2"]
    }
  }

  # artifact_feeds = {
  #   "OrgFeed${random_integer.orgfeed.result}" = {}
  #   "ProjectFeed${random_integer.projectfeed.result}" = {
  #     org_scoped_feed = false
  #   }
  # }

  wiki_name = "wiki22"


  service_connections = {
    azure-sc-1 = {
      name                  = "MyServiceConnectionName"
      type                  = "azurerm"
      authentication_scheme = "ServicePrincipal"
      authentication_data = {
        username         = "00000003-0000-0000-c000-000000000016"
        subscriptionId   = "00000003-0000-0000-c000-000000000017"
        subscriptionName = "TheBatcave"
      }
      authorized_pipeline_names = ["pipeline1"]
    }
    nuget-sc-1 = {
      name                  = "MyServiceConnectionName3"
      type                  = "nuget"
      authentication_scheme = "apikey"
      data = {
        url = "https://myfeed.thingsman/feed-name"
      }
      authorized_pipeline_names = ["pipeline1"]
    }
  }
}








================================||
# branch-pol
# # On PRs to the default branch of any repository, enforce two approvers, block author approval, and reset approvals on new pushes
# resource "azuredevops_branch_policy_min_reviewers" "default" {
#   project_id = azuredevops_project.this.id

#   enabled  = true
#   blocking = true

#   settings {
#     reviewer_count                         = var.default_num_approvals_required
#     submitter_can_vote                     = false
#     last_pusher_cannot_approve             = true
#     allow_completion_with_rejects_or_waits = false
#     on_push_reset_all_votes                = true
#     on_push_reset_approved_votes           = true

#     scope {
#       match_type = "DefaultBranch"
#     }
#   }
# }

# # On PRs to the default branch of any repository, ensure all comments have been resolved
# resource "azuredevops_branch_policy_comment_resolution" "default" {
#   project_id = azuredevops_project.this.id

#   enabled  = true
#   blocking = true

#   settings {
#     scope {
#       match_type = "DefaultBranch"
#     }
#   }
# }

resource "azuredevops_branch_policy_auto_reviewers" "project" {
  for_each = var.project_repo_reviewer_policies

  project_id = azuredevops_project.this.id

  blocking = each.value.require_votes
  enabled  = true
  settings {
    auto_reviewer_ids = each.value.reviewer_ids
    scope {
      repository_ref = each.value.repository_ref
      match_type     = each.value.match_type
    }
    path_filters       = each.value.path_filters
    message            = each.value.message
    submitter_can_vote = false
  }
}





#################
# envs
resource "azuredevops_environment" "this" {
  for_each = var.deployment_environments

  project_id = azuredevops_project.this.id
  name       = each.key
  #description = "Managed via Terraform"

  lifecycle {
    ignore_changes = [
      description
    ]
  }
}





=======================================
======================================
## .git-repos
# For all repositories in the xxxx organization, the default branch is named "main". This has been set in the console as, at the time of writing, this is not manageable with Terraform
resource "azuredevops_git_repository" "this" {
  # By default, when a project is created, a repository with the same name is also created. So, don't create a repository with that name
  for_each = setsubtract(var.repos, [var.project_name])

  project_id = azuredevops_project.this.id
  name       = each.value
  initialization {
    init_type = "Uninitialized"
  }
  lifecycle {
    # Ignore changes to `initialization` block so existing repos can be imported
    ignore_changes = [
      initialization,
    ]
  }
  lifecycle {
    # Prevent deletion of the repository if it is not managed by Terraform
    prevent_destroy = true
  }
}



=======================================
======================================
# global
locals {
  project_name = endswith(lower(var.project_name), "-sandbox") ? regex("(.*)-.*$", var.project_name)[0] : var.project_name

  default_groups = toset([
    "Build Administrators",
    "Limited Project Administrators",
    "Contributors",
    "Project Administrators",
    "Readers"
  ])

  azurerm_serviceconnections = {
    for service_connection in var.service_connections : service_connection.name => service_connection
    if service_connection.type == "azurerm"
  }

  nuget_serviceconnections = {
    for service_connection in var.service_connections : service_connection.name => service_connection
    if service_connection.type == "nuget"
  }

  ad_group_prefix = (var.override_group_prefix == "") ? join("-", ["xxxx-gbl-aadg-ADO", local.project_name]) : join("-", ["xxxx-gbl-aadg-ADO", var.override_group_prefix])

  default_group_access = {
    "Contributors" = join("-", [local.ad_group_prefix, "Contributors"])
  }

  group_access = merge(local.default_group_access,
    var.project_admins_enabled ? {
      "Project Administrators" = join("-", [local.ad_group_prefix, "Admins"])
    } : {},
    var.limited_project_admins_enabled ? {
      "Limited Project Administrators" = join("-", [local.ad_group_prefix, "LimitedAdmins"])
    } : {},
    var.readers_enabled ? {
      "Readers" = join("-", [local.ad_group_prefix, "Readers"])
    } : {},
    var.build_admins_enabled ? {
      "Build Administrators" = join("-", [local.ad_group_prefix, "BuildAdmins"])
    } : {},
    var.release_admins_enabled ? {
      "Release Administrators" = join("-", [local.ad_group_prefix, "ReleaseAdmins"])
    } : {}
  )
### TO BE ELETED
  # unique_pipeline_folders = toset(distinct([for key, pipeline in var.pipelines : pipeline.folder_path if pipeline.folder_path != "\\"]))

  # environment_pipeline_map = flatten([
  #   for env_name, env in var.deployment_environments : [
  #     for pipeline_name in env.authorized_pipeline_names : {
  #       env_name      = env_name
  #       pipeline_name = pipeline_name
  #       all_pipelines = env.all_pipelines
  #     }
  #   ]
  # ])

  service_connection_pipeline_map = flatten([
    for sc_name, sc in var.service_connections : [
      for pipeline_name in sc.authorized_pipeline_names : {
        service_connection_name = sc.name
        pipeline_name           = pipeline_name
        type                    = sc.type
      }
    ]
  ])
### TO BE ELETED
  # processed_pipelines = { for k, v in var.pipelines : k => {
  #   associated_repository = coalesce(v.associated_repository, k)
  #   yaml_file_path        = coalesce(v.yaml_file_path, "azure-pipelines.yml")
  #   folder_path           = coalesce(v.folder_path, "\\")
  #   report_build_status   = coalesce(v.report_build_status, true)
  #   branch_name           = coalesce(v.default_branch, "main")
  #   yaml_ci_trigger       = coalesce(v.yaml_ci_trigger, true)
  # } }

  repo_id_map = { for repo in azuredevops_git_repository.this : repo.name => repo.id }
}

data "azuredevops_group" "this" {
  for_each   = local.default_groups
  depends_on = [azuredevops_group.aad, azuredevops_group.limited_project_admin]

  project_id = azuredevops_project.this.id
  name       = each.value
}

data "azuredevops_git_repository" "this" {
  # By default, when a project is created, a repository with the same name is also created.
  # So, read this repository instead of creating it via `azuredevops_git_repository.this`
  for_each = contains(var.repos, var.project_name) ? toset([var.project_name]) : toset([])

  project_id = azuredevops_project.this.id
  name       = each.value
}

data "azuredevops_git_repository" "wiki" {
  count      = var.wiki_name != null ? 1 : 0
  depends_on = [azuredevops_wiki.this]

  project_id = azuredevops_project.this.id
  name       = var.wiki_name
}

data "azuread_group" "group_access" {
  for_each = local.group_access

  display_name = each.value
}

data "azuread_group" "aad_approvers" {
  for_each = toset(var.additional_aad_groups)

  display_name = each.value
}

data "azuread_client_config" "current" {}

data "azuredevops_team" "default_team" {
  project_id = azuredevops_project.this.id
  name       = "${azuredevops_project.this.name} Team"
}

data "azuredevops_group" "limited_project_admin" {
  project_id = azuredevops_project.this.id
  name       = "Limited Project Administrators"

  depends_on = [azuredevops_group.limited_project_admin]
}




=================================
==================||=========
# group
# In order to add Azure AD groups as members to Azure DevOps groups, need to create a group with the origin as the Azure AD group ID,
# and then set the members of the Azure DevOps group to be the descriptor of this group
# Reference:
#   https://github.com/microsoft/terraform-provider-azuredevops/issues/313
#   https://github.com/microsoft/terraform-provider-azuredevops/issues/51#issuecomment-759217529
# 
# NOTE: cannot provide a limited scope when using `origin_id` (https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/group#origin_id)
#   As such, this group will be created in the organization, rather than the project it refers to. A caveat with this is that, if a separate project tries to create
#   a group with the same origin_id, it will fail with a 50x error.
resource "azuredevops_group" "aad" {
  for_each = local.group_access

  origin_id = data.azuread_group.group_access[each.key].object_id
}

resource "azuredevops_group_membership" "this" {
  for_each   = local.group_access
  depends_on = [azuredevops_group.aad, azuredevops_group.limited_project_admin, azuredevops_team.this]

  group   = data.azuredevops_group.this[each.key].descriptor
  members = each.key == "Contributors" && var.project_teams != {} ? concat([azuredevops_group.aad[each.key].descriptor], [for team in azuredevops_team.this : team.descriptor]) : [azuredevops_group.aad[each.key].descriptor]

  # This will ensure that group membership is handled fully via code (i.e. anything done outside of code will be removed and replaced with what is in code)
  mode = "overwrite"
}

resource "azuredevops_group" "aad_approvers" {
  for_each = toset(var.additional_aad_groups)

  origin_id = data.azuread_group.aad_approvers[each.key].object_id
}

resource "azuredevops_group" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  display_name = "Limited Project Administrators"
  scope        = azuredevops_project.this.id
}

resource "azuredevops_group_membership" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  group   = azuredevops_group.limited_project_admin[""].descriptor
  members = [azuredevops_group.aad["Limited Project Administrators"].descriptor]
}


=============================
# limited-proj
# The following permissions are not managed in this file because of the specified reason:
#
# 1. Release Pipeline permissions - Not avaialble via Terraform provider
# 2. Build Pipeline permissions - Managed via build_folder permission in provider. Permissions granted at root folder level.
# 3. Service Connection permissions - No project level permissions are granted to LPAs for this by-design. Permissions are granted per Service Connection

#Add LPA with all permissions at project root area path
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#area-path-object-level
resource "azuredevops_area_permissions" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  #Set at root area path so this filters down to all areas in the project
  path = "/"
  permissions = {
    CREATE_CHILDREN        = "Allow"
    GENERIC_READ           = "Allow"
    DELETE                 = "Allow"
    WORK_ITEM_READ         = "Allow"
    WORK_ITEM_WRITE        = "Allow"
    WORK_ITEM_SAVE_COMMENT = "Allow"
    MANAGE_TEST_PLANS      = "Allow"
    MANAGE_TEST_SUITES     = "Allow"
  }
}

#Add LPA with most permissions at root of build folder structure.
#This filters down to all pipelines in the project
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#pipeline-or-build-object-level
resource "azuredevops_build_folder_permissions" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  # Set at root foler level so this permission applies down to all 
  path      = "\\"
  principal = azuredevops_group.limited_project_admin[""].descriptor

  permissions = {
    "AdministerBuildPermissions" : "Deny",
    "DeleteBuildDefinition" : "Deny",
    "DeleteBuilds" : "Allow",
    "DestroyBuilds" : "Allow",
    "EditBuildDefinition" : "Allow",
    "EditBuildQuality" : "Allow",
    "ManageBuildQualities" : "Allow",
    "ManageBuildQueue" : "Allow",
    "QueueBuilds" : "Allow",
    "RetainIndefinitely" : "Allow",
    "StopBuilds" : "Allow",
    "UpdateBuildInformation" : "Allow",
    "ViewBuildDefinition" : "Allow",
    "ViewBuilds" : "Allow",
  }
}

#Add LPA with most permissions at root of git repository permission structure.
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#git-repository-object-level
resource "azuredevops_git_permissions" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  permissions = {
    Administer              = "Deny"
    CreateBranch            = "Allow"
    CreateTag               = "Allow"
    CreateRepository        = "Deny"
    DeleteRepository        = "Deny"
    EditPolicies            = "NotSet"
    ForcePush               = "Allow"
    GenericRead             = "Allow"
    GenericContribute       = "Allow"
    PolicyExempt            = "NotSet"
    ManageNote              = "Allow"
    ManagePermissions       = "Deny"
    RemoveOthersLocks       = "Allow"
    RenameRepository        = "Deny"
    PullRequestBypassPolicy = "Allow"
    PullRequestContribute   = "Allow"
  }
}

# #We want to grant EditPolicies only at the repository level and not the project level.
# #This allows LPAs to manage repo level branch policies but not override project level branch policies.
# resource "azuredevops_git_permissions" "limited_project_admin_per_repo" {
#   for_each = var.limited_project_admins_enabled ? azuredevops_git_repository.this : {}

#   project_id    = azuredevops_project.this.id
#   principal     = azuredevops_group.limited_project_admin[""].descriptor
#   repository_id = each.value.id
#   permissions = {
#     EditPolicies = "Allow"
#   }
#   replace = false
# }

#Allow LPAs to manage iterations at the project level
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#iteration-path-object-level
resource "azuredevops_iteration_permissions" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  path       = "/"
  permissions = {
    CREATE_CHILDREN = "Allow"
    GENERIC_READ    = "Allow"
    DELETE          = "Allow"
  }
}

#Allow LPAs to have project level permissions that can be delegated to them
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#project-level-permissions
resource "azuredevops_project_permissions" "limited_project_admin" {
  for_each = (var.limited_project_admins_enabled == true) ? { "" = {} } : {}

  project_id = azuredevops_project.this.id
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  permissions = {
    #System-Only Permissions (DO NOT USE)
    #MANAGE_SYSTEM_PROPERTIES
    #BYPASS_PROPERTY_CACHE
    #AGILETOOLS_BACKLOG
    #AGILETOOLS_PLANS

    #Denied permissions
    GENERIC_WRITE     = "Deny"
    RENAME            = "Deny"
    MANAGE_PROPERTIES = "Deny"
    UPDATE_VISIBILITY = "Deny"

    DELETE = "Deny"

    #project-level settings
    GENERIC_READ           = "Allow"
    SUPPRESS_NOTIFICATIONS = "Allow"

    #Build settings
    PUBLISH_TEST_RESULTS = "Allow"
    ADMINISTER_BUILD     = "Allow"
    START_BUILD          = "Allow"
    EDIT_BUILD_STATUS    = "Allow"
    UPDATE_BUILD         = "Allow"

    #Test plans settings
    DELETE_TEST_RESULTS        = "Allow"
    VIEW_TEST_RESULTS          = "Allow"
    MANAGE_TEST_ENVIRONMENTS   = "Allow"
    MANAGE_TEST_CONFIGURATIONS = "Allow"

    #Boards settings
    CHANGE_PROCESS               = "Allow"
    WORK_ITEM_DELETE             = "Allow"
    WORK_ITEM_MOVE               = "Allow"
    WORK_ITEM_PERMANENTLY_DELETE = "Allow"
    BYPASS_RULES                 = "Allow"
  }
}

#Allow LPAs to view and manage service hooks
resource "azuredevops_servicehook_permissions" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  permissions = {
    ViewSubscriptions   = "allow"
    EditSubscriptions   = "allow"
    DeleteSubscriptions = "allow"
    PublishEvents       = "allow"
  }
}

#Add LPA permission to managee tags in the current project
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#work-item-tags
resource "azuredevops_tagging_permissions" "example-permissions" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  permissions = {
    Enumerate = "Allow"
    Create    = "Allow"
    Update    = "Allow"
    Delete    = "Allow"
  }
}

#Add LPA with all permissions at root of shared work item queries folder
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#work-item-query-and-query-folder-object-level
resource "azuredevops_workitemquery_permissions" "limited_project_admin" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  project_id = azuredevops_project.this.id
  path       = "/"
  principal  = azuredevops_group.limited_project_admin[""].descriptor
  permissions = {
    Contribute        = "Allow"
    Delete            = "Allow"
    Read              = "Allow"
    ManagePermissions = "Allow"
  }
}

#Add LPA as administrator over entire Library of Variable Groups and Secure Files
#This is granted as these resoruces are not yet managed via Terraform and we do not want to block teams from using these if needed
#https://learn.microsoft.com/en-us/azure/devops/pipelines/policies/permissions?view=azure-devops#set-library-security-in-azure-pipelines
resource "azuredevops_securityrole_assignment" "limited_project_admin_variable_group" {
  for_each = var.limited_project_admins_enabled ? toset([""]) : toset([])

  identity_id = azuredevops_group.limited_project_admin[""].origin_id
  scope       = "distributedtask.library"
  role_name   = "Administrator"
  resource_id = "${azuredevops_project.this.id}$0"
}

#Add LPA as project-level administrator for user defined azure rm service connections
#https://learn.microsoft.com/en-us/azure/devops/pipelines/policies/permissions?view=azure-devops#set-service-connection-security-in-azure-pipelines
resource "azuredevops_securityrole_assignment" "nuget_limited_project_admin_service_connection_admin" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_serviceendpoint_nuget.this : {}

  identity_id = azuredevops_group.limited_project_admin[""].origin_id
  scope       = "distributedtask.serviceendpointrole"
  role_name   = "Administrator"
  resource_id = "${azuredevops_project.this.id}_${each.value.id}"
}

#Add LPA as org-level administrator for user defined nuget rm service connections
#Required to edit authentication information of service connection
resource "azuredevops_securityrole_assignment" "nuget_limited_project_admin_service_connection_admin_collection" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_serviceendpoint_nuget.this : {}

  identity_id = azuredevops_group.limited_project_admin[""].origin_id
  scope       = "distributedtask.serviceendpointrole"
  role_name   = "Administrator"
  resource_id = "collection_${each.value.id}"

  lifecycle {
    ignore_changes = [scope]
  }
}

#Add LPA as project-level administrator for user defined azure rm service connections
resource "azuredevops_securityrole_assignment" "azurerm_limited_project_admin_service_connection_admin" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_serviceendpoint_azurerm.this : {}

  identity_id = azuredevops_group.limited_project_admin[""].origin_id
  scope       = "distributedtask.serviceendpointrole"
  role_name   = "Administrator"
  resource_id = "${azuredevops_project.this.id}_${each.value.id}"
}

#Add LPA as org-level administrator for user defined azure rm service connections
#Required to edit authentication information of service connection
resource "azuredevops_securityrole_assignment" "azurerm_limited_project_admin_service_connection_admin_collection" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_serviceendpoint_azurerm.this : {}

  identity_id = azuredevops_group.limited_project_admin[""].origin_id
  scope       = "distributedtask.serviceendpointrole"
  role_name   = "Administrator"
  resource_id = "collection_${each.value.id}"

  lifecycle {
    ignore_changes = [scope]
  }

}

#Add LPA as administrator for user defined environments
#https://learn.microsoft.com/en-us/azure/devops/pipelines/policies/permissions?view=azure-devops#set-security-for-environments-in-azure-pipelines
resource "azuredevops_securityrole_assignment" "limited_project_admin_environment" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_environment.this : {}

  identity_id = azuredevops_group.limited_project_admin[""].origin_id
  scope       = "distributedtask.environmentreferencerole"
  role_name   = "Administrator"
  resource_id = "${azuredevops_project.this.id}_${each.value.id}"
}

#Add LPA as administrator of default project team
resource "azuredevops_team_administrators" "default_team_limited_project_admin" {
  for_each = (var.limited_project_admins_enabled == true) ? toset([""]) : toset([])

  project_id     = azuredevops_project.this.id
  team_id        = data.azuredevops_team.default_team.id
  mode           = "add"
  administrators = [data.azuredevops_group.limited_project_admin.descriptor]
}

#Add LPA as administrator of user defined teams
resource "azuredevops_team_administrators" "limited_project_admin" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_team.this : {}

  project_id     = azuredevops_project.this.id
  team_id        = each.value.id
  mode           = "add"
  administrators = [data.azuredevops_group.limited_project_admin.descriptor]
}

#Add LPA as administrator of user defined feeds
#https://learn.microsoft.com/en-us/azure/devops/artifacts/feeds/feed-permissions?view=azure-devops#permissions-table
#https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions-access?view=azure-devops#azure-artifacts
resource "azuredevops_feed_permission" "limited_project_admin" {
  for_each = (var.limited_project_admins_enabled == true) ? azuredevops_feed.this : {}

  feed_id             = each.value.id
  role                = "administrator"
  identity_descriptor = data.azuredevops_group.limited_project_admin.descriptor
  project_id          = each.value.project_id != null ? azuredevops_project.this.id : null
}



=============================
# main
resource "azuredevops_project" "this" {
  name               = var.project_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = var.project_work_item_template
  description        = var.project_description
  features = {
    "artifacts" = var.project_artifacts_enabled ? "enabled" : "disabled"
  }
}

=============================



=================================
==================================
# pipeline-auth
resource "azuredevops_pipeline_authorization" "environment" {
  for_each = { for combo in local.environment_pipeline_map : "${combo.env_name}-${combo.pipeline_name}" => combo if 1 == 1 }

  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_environment.this[each.value.env_name].id
  type        = "environment"
  pipeline_id = (each.value.all_pipelines == false) ? azuredevops_build_definition.this[each.value.pipeline_name].id : null
}

# resource "azuredevops_pipeline_authorization" "repository" {
#   for_each = azuredevops_build_definition.this

#   project_id  = azuredevops_project.this.id
#   resource_id = each.value.repository[0].repo_id
#   type        = "repository"
#   pipeline_id = each.value.id
# }

resource "azuredevops_pipeline_authorization" "service_connection_azurerm" {
  for_each = { for combo in local.service_connection_pipeline_map : "${combo.service_connection_name}-${combo.pipeline_name}" => combo if combo.type == "azurerm" }

  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_serviceendpoint_azurerm.this[each.value.service_connection_name].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.this[each.value.pipeline_name].id
}

resource "azuredevops_pipeline_authorization" "service_connection_nuget" {
  for_each = { for combo in local.service_connection_pipeline_map : "${combo.service_connection_name}-${combo.pipeline_name}" => combo if combo.type == "nuget" }

  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_serviceendpoint_nuget.this[each.value.service_connection_name].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.this[each.value.pipeline_name].id
}







==================================
==================================
# pipeline.tf
# #Pipelines can be sorted into folders. Create them first.
# resource "azuredevops_build_folder" "this" {
#   for_each   = local.unique_pipeline_folders
#   project_id = azuredevops_project.this.id
#   path       = each.value
# }

# resource "azuredevops_build_definition" "this" {
#   for_each   = local.processed_pipelines
#   depends_on = [azuredevops_build_folder.this]

#   project_id = azuredevops_project.this.id
#   name       = each.key
#   repository {
#     branch_name         = each.value.branch_name == "" ? "refs/heads/main" : "refs/heads/${each.value.branch_name}"
#     repo_id             = each.value.associated_repository == azuredevops_project.this.name ? data.azuredevops_git_repository.this[each.value.associated_repository].id : azuredevops_git_repository.this[each.value.associated_repository].id
#     repo_type           = "TfsGit"
#     yml_path            = each.value.yaml_file_path
#     report_build_status = each.value.report_build_status
#   }
#   ci_trigger {
#     use_yaml = each.value.yaml_ci_trigger
#   }

#   path = each.value.folder_path


#   lifecycle {
#     ignore_changes = [
#       agent_pool_name,
#       ci_trigger,
#       features,
#       pull_request_trigger,
#       queue_status,
#       repository[0].branch_name,
#       repository[0].report_build_status,
#       schedules,
#       variable,
#       variable_groups
#     ]
#   }
# }




======||
# tags.tf

====||=
variables.encyption.tf


====||


=====||
variables.network.tf





==================================
==================================
# out




===================================
==================================
# R


==================================
==================================
# TERRA


==================================
==================================
# var







==================================
==================================
# ver




==================================
==================================
==================================
------------------







===========||===================





========================||========================


--------------------------------------


---------------------------------


-------------------------------------------------


---------------------------------------------


-----------------------------------------------




======================||==========================
========================||========================




---



###=======================================

---






###=======================================

---


---





###=======================================

---




---
### 
=======




=====






╵=============================||=================================================

--------------------------------------------------


========


