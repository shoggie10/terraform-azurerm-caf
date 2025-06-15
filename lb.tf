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

## bcotools
module "project_BCOTools" {
  source  = "app.terraform.io/xxxx/project/ado"
  version = "<3.0.0"

  project_name               = "BCOTools"
  project_work_item_template = "Basic"
  repos = ["FusionTools"]
  pipelines = {
    FusionTools = {
      associated_repository = "FusionTools"
    }
  }

  project_admins_enabled         = true
  limited_project_admins_enabled = true

  project_repo_reviewer_policies = {
    "default_optional" = {
      match_type    = "DefaultBranch"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = true
      reviewer_ids = [
        module.tcarver.id
      ]
      path_filters = [
        "*"
      ]
    }
  }
}


=====
edddddds
module "project_EDS" {
  source  = "app.terraform.io/xxxx/project/ado"
  version = "<3.0.0"

  project_name                   = "EDS"
  project_description            = "EDS"
  
  #This was created with the v1 mechanism for creating wikis, we use the v2 mechanism now.
  wiki_name                      = "EDS.wiki"
  project_admins_enabled         = true
  limited_project_admins_enabled = true
  repos = [
    "ADF",
    "AzureSQLDB",
    "Databricks",
    "EXE",
    "EXE_BackbaseNRT",
    "EXE_BDW_DatabaseTransfer",
    "EXE_BDW_DataStaging",
    "EXE_BDW_FileToPrestage",
    "EXE_BDW_IntradayDataTransfer",
    "EXE_BDW_JobExecution",
    "EXE_BDW_JobExecutionLogList",
    "EXE_BDW_JobTaskExecuter",
    "EXE_BDW_PostValidation",
    "EXE_BDW_PreValidation",
    "EXE_BlendNRT",
    "EXE_DMF_Metadata_Utility",
    "EXE_IMPACT",
    "EXE_MSP",
    "EXE_FastNet",
    "Scripts",
    "SQL",
    "SSAS",
    "SSIS",
    "Web"
  ]
  pipelines = {
    "ADF_EDS_BuildPipeline_Dev" = {
      associated_repository = "ADF"
      yaml_file_path        = "DevOps/BuildPipeline.yaml"
      folder_path           = "\\ADF"
    }
    "ADF_EDS_BuildPipeline_Prod" = {
      associated_repository = "ADF"
      yaml_file_path        = "DevOps/BuildPipeline.yaml"
      folder_path           = "\\ADF"
    }
    "ADF_EDS_BuildPipeline_Test" = {
      associated_repository = "ADF"
      yaml_file_path        = "DevOps/BuildPipeline.yaml"
      folder_path           = "\\ADF"
    }
    "SQL_EDS_CodeScanPipeline_Dev" = {
      associated_repository = "SQL"
      yaml_file_path        = "DevOps/CodeScanPipeline.yml"
      folder_path           = "\\SQL"
    }
  }
  project_teams = [
    "EDS Release Admins",
    "EDS Code Reviewers",
    "EDS Team",
    "EDS Prod Release",
    "EDS Test Release",
    "DataLake Approvers",
    "SBOD Approvers",
    "BOLT Approvers",
    "TreasuryInterface Approvers"
  ]
}







================================||
project_Templates
data "azuredevops_group" "CodeApprovers" {
  name       = "xxxx.AzureDevOps.Templates CodeApprovers"
  project_id = module.project_xxxx_AzureDevOps_Templates.id
}

data "azuredevops_group" "ManagerApprovers" {
  name       = "xxxx.AzureDevOps.Templates ManagerApprovers"
  project_id = module.project_xxxx_AzureDevOps_Templates.id
}

module "project_xxxx_AzureDevOps_Templates" {
  source  = "app.terraform.io/xxxx/project/ado"
  version = "<3.0.0"

  project_name               = "xxxx.AzureDevOps.Templates"
  project_work_item_template = "Basic"
  repos = [
    "AzureMigrationService",
    "xxxx-templates",
    "adHocDevopsApi",
    "Build-Pipeline-5x-Example",
    "Example-Pipeline-ConsoleApp"
  ]
  project_repo_reviewer_policies = {
    "default1" = {
      match_type    = "DefaultBranch"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = true
      reviewer_ids = [
        data.azuredevops_group.CodeApprovers.origin_id
      ]
    }
    "default2" = {
      match_type    = "DefaultBranch"
      message       = "Automatically added via branch policies configured via Terraform."
      require_votes = true
      reviewer_ids = [
        data.azuredevops_group.ManagerApprovers.origin_id,
      ]
    }
  }
  pipelines = {
    Build-Pipeline-6x-Example = {
      associated_repository = "Build-Pipeline-5x-Example"
      yaml_file_path        = "azure-build-pipeline.yml"
    }
    Example-Pipeline-ConsoleApp = {
      associated_repository = "Example-Pipeline-ConsoleApp"
    }
  }
  project_admins_enabled         = true
  limited_project_admins_enabled = true
}

======
# salesforceplat
module "project_Salesforce_Platform" {
  source  = "app.terraform.io/xxxx/project/ado"
  version = "<3.0.0"

  project_name               = "SalesforcePlatform"
  project_description        = "Projects for Salesforce Platform"
  project_work_item_template = "Salesforce Platform-Agile"
  repos = [
    "CRMIntegration",
    "DataTeamPractice",
    "DBAmp",
    "FSC",
    "INCIntegrationSSIS",
    "SF",
    "TMG"
  ]
  pipelines = {
    "CRMIntegration" = {
      associated_repository = "CRMIntegration"
      yaml_file_path        = "azure-pipelines.yml"
      folder_path           = "\\"
    }
    "DBAmp" = {
      associated_repository = "DBAmp"
      yaml_file_path        = "azure-pipelines.yml"
      folder_path           = "\\"
    }
    "FSC" = {
      associated_repository = "FSC"
      yaml_file_path        = "azure-pipelines.yml"
      folder_path           = "\\"
    }
    "INCIntegrationSSIS" = {
      associated_repository = "INCIntegrationSSIS"
      yaml_file_path        = "azure-pipelines.yml"
      folder_path           = "\\"
    }
    "SF" = {
      associated_repository = "SF"
      yaml_file_path        = "azure-pipelines.yml"
      folder_path           = "\\"
    }
    # "SFDatabases" = {
    #   associated_repository = "SFDatabases"
    #   yaml_file_path        = "azure-pipelines.yml"
    #   folder_path           = "\\"
    # }
    "TMG" = {
      associated_repository = "TMG"
      yaml_file_path        = "azure-pipelines.yml"
      folder_path           = "\\"
    }
  }
  project_admins_enabled         = true
  limited_project_admins_enabled = true
}






#################





=======================================
======================================
## 



=======================================
======================================
# global




=================================
==================||=========
# group



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


