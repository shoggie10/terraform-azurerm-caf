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

## 



=====






================================||



======



#################





=======================================
======================================
## 



=======================================
======================================
# global




=================================
==================||=========
# 



=============================
# 




=============================
# main


=============================



=================================
==================================









==================================
==================================
# 
variable "project_name" {
  type        = string
  description = "The name of the project"

  validation {
    condition     = length(var.project_name) <= 32
    error_message = "The project name must be less than or equal to 32 characters, so as not to exceed the 64 character limit of AD group names"
  }
}

variable "project_work_item_template" {
  type        = string
  description = "The work item template of the project"
  default     = "Agile"
}

variable "project_description" {
  type        = string
  description = "The description of the project"
  default     = null
}

variable "override_group_prefix" {
  type        = string
  description = "Overrides project name portion of Azure AD group prefix. This allows reusing one set of groups across multiple projects."
  default     = ""
}

variable "project_artifacts_enabled" {
  type        = bool
  description = "Whether to disable the Artifact repository. NOTE: this is a temporary argument and will eventually be removed in a future release, when it will be disabled in all projects."
  default     = false
}

variable "repos" {
  type        = set(string)
  description = "A map of repositories, with an optional number of approvals required and reviewers. Reviewers can be direct users, project groups, or AAD groups, and can be required only for certain paths (files/directories, globs accepted), if specified"
}

variable "default_num_approvals_required" {
  type        = number
  description = "The number of approvals required for PRs to the default branch"
  default     = 2
}

# TODO: implement ability to have project groups as default reviewers 
variable "project_repo_reviewer_policies" {
  type = map(object({
    reviewer_ids   = list(string)
    repository_ref = optional(string, null)
    require_votes  = optional(bool, false)
    match_type     = optional(string, "DefaultBranch")
    message        = optional(string, "Automatically included pull request reviewers. Managed via Terraform.")
    path_filters   = optional(list(string), [])
  }))
  description = "Reviewers that are set at the project level. Can include Limited Project Administrator or Repositroy Admin"
  default     = {}

  validation {
    condition = alltrue([
      for key, reviewer in var.project_repo_reviewer_policies : (
        reviewer.match_type == "DefaultBranch" ||
        (reviewer.match_type != "DefaultBranch" && can(regex("^refs/heads/.+", reviewer.repository_ref)))
      )
    ])
    error_message = "Each reviewer must have a valid repository_ref based on the match_type. If match_type is Exact, repository_ref must be a qualified ref (e.g., refs/heads/master). If match_type is Prefix, repository_ref must be a ref path (e.g., refs/heads/releases)."
  }

  validation {
    condition = alltrue([
      for key, reviewer in var.project_repo_reviewer_policies : contains(["DefaultBranch", "Exact", "Prefix"], reviewer.match_type)
    ])
    error_message = "match_type must be one of 'DefaultBranch', 'Exact', or 'Prefix'."
  }

  validation {
    condition = alltrue([
      for key, reviewer in var.project_repo_reviewer_policies : (
        reviewer.match_type != "DefaultBranch" || reviewer.repository_ref == null
      )
    ])
    error_message = "When match_type is 'DefaultBranch', repository_ref must not be specified."
  }

  validation {
    condition = alltrue([
      for key, reviewer in var.project_repo_reviewer_policies : alltrue([
        for id in reviewer.reviewer_ids : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
      ])
    ])
    error_message = "Each reviewer_id must be a valid GUID."
  }
}

variable "pipelines" {
  type = map(object({
    associated_repository = optional(string)
    default_branch        = optional(string, "main")
    folder_path           = optional(string, "\\")
    report_build_status   = optional(bool, true)
    yaml_ci_trigger       = optional(bool, true)
    yaml_file_path        = optional(string, "azure-pipelines.yml")
  }))
  default = {}
}

# TODO: add ability to specify AAD groups as members of project teams. At this time, I don't believe this functionality is needed, but probably should be implemented going forward
variable "project_teams" {
  type        = set(string)
  description = "List of project teams that should have access to Azure DevOps boards and work items. Users can be direct users, or project groups. Access level can be \"admin\" or \"member\""
  default     = []
}

variable "service_connections" {
  type = map(
    object({
      name                  = string
      type                  = string
      authentication_scheme = string
      authentication_data = optional(object({
        username         = optional(string)
        subscriptionId   = optional(string)
        subscriptionName = optional(string)
      }))
      data = optional(object({
        url = optional(string)
      }))
      authorized_pipeline_names = list(string)
    })
  )
  default = {}

  description = <<EOT
You can create a service connection within Azure Pipelines to external and remote services for executing tasks in a job. These Service Connections securely store authentication information used by tasks.

The following service connection types are supported by this module: azurerm, nuget.

When using azurerm, all authentication_data properties are required where the "username" property is the service principal client id. Supported authentication_scheme values are WorkloadIdentityFederation or ServicePrincipal.

WHen using nuget, the data.url property specifies the feed url. Supported authentiation_scheme values are apikey or userpass.

No passwords, tokens, keys, or any other secret values are supported as inputs at this time. These Service Connections are created with placeholder password values. Callers are expecte to manually update this in the ADO UI.
EOT

  validation {
    condition     = alltrue([for sc in var.service_connections : sc.type == "azurerm" || sc.type == "nuget"])
    error_message = "value"
  }

  validation {
    condition = alltrue([
      for sc in var.service_connections : (
        (sc.type == "azurerm" && (sc.authentication_scheme == "ServicePrincipal" || sc.authentication_scheme == "WorkloadIdentityFederation")) ||
        (sc.type != "azurerm")
      )
    ])
    error_message = ""
  }
}

variable "deployment_environments" {
  description = "List of environments for deployment"
  type = map(object({
    authorized_pipeline_names = optional(list(string))
    all_pipelines             = optional(bool, false)
  }))
  default = {}
}

variable "artifact_feeds" {
  description = ""
  type = map(object({
    org_scoped_feed = optional(bool, true)
  }))

  default = {}
}

variable "readers_enabled" {
  type        = bool
  description = "Whether or not this project has a Readers group"
  default     = false
}

variable "build_admins_enabled" {
  type        = bool
  description = "Whether or not this project has a Build Administrators group"
  default     = false
}

variable "release_admins_enabled" {
  type        = bool
  description = "Whether or not this project has a Release Administrators group"
  default     = false
}

variable "project_admins_enabled" {
  type        = bool
  description = "Whether or not this project has a Project Administrators group"
  default     = false
}

### Limited Project Admins
variable "limited_project_admins_enabled" {
  type        = bool
  description = "Whether or not this project has a Limited Project Administrators group"
  default     = false
}


variable "additional_aad_groups" {
  type        = set(string)
  description = "Additional project groups that have been created, that are listed as approvers"
  default     = []
}

variable "wiki_name" {
  type        = string
  description = "The name of the Wiki repository"
  default     = null
}




======||
# 

====||=
var


====||


=====||






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


