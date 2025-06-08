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








================================||
# customer-managed-key.tf



#################
# Create the Key Vault




=======================================
======================================
## .gitlab-ci.yml


=======================================
======================================
# .terraform-docs.yml



=================================
==================||=========
# CHANGELOG.md


=============================
# CODEOWNERS

=============================
# GETTING_STARTED.md



=================================
==================================
# globals.tf






==================================
==================================
# main.tf



======||
# tags.tf

====||=
variables.encyption.tf


====||


=====||
variables.network.tf





==================================
==================================
# outputs.tf




===================================
==================================
# README.md


==================================
==================================
# TERRAFORM_DOCS_INSTRUCTIONS.md


==================================
==================================
# variables.tf







==================================
==================================
# versions.tf




==================================
==================================
==================================
------------------







===========||===================
module "cosmosdb_account" {




========================||========================
Gremlin API Example:

--------------------------------------
Cassandra API Example

---------------------------------
SQL API Example

-------------------------------------------------
MongoDB API Example

---------------------------------------------
Table API Example

-----------------------------------------------
PostgreSQL API Example



======================||==========================
========================||========================
# main.tf



---



###=======================================
# globals.tf
---






###=======================================
# variables.tf
---


---





###=======================================
# outputs.tf
---




---
### 




=====
Intended audience
This document is meant to be consumed by the Cloud Operations team while they are trying to make a decision on how to an action against Azure DevOps.

Document Intent
This document is meant to explain all aspects of how Azure DevOps is used at BOKF. This explains things like where permissions can be assigned, why we have made the decisions we did in how they are set, and what mechanism should be configuring a permission.

More information will be elaborated on where appropriate for Azure DevOps specific functionality allows.

Glossary
The following terms are used throughout this document and should be understood.

Azure DevOps (ADO)

The tool we are discussing here

Project Collection Administrators (PCA)

Built-in role in ADO

Cloud operations team

Project Administrators (PA)

Built-in role in ADO

Largely empty across projects

Limited Project Administrators (LPA)

Custom BOKF role

Former PAs exist here now

Has nearly all permissions that PA did besides the ability toWhat manage permissions

Terraform
There are many mentions to Terraform in this document. The below resources are relevant to this and should be understood on how they fit into the equation.

Module
The Azure DevOps Project Terraform Module is located in a GitLab repository and published to the Terraform Module Registry.

Usage
The previously referenced module is used in the Azure DevOps SaaS GitLab repository. Each project in ADO has its own terraform file where resources for that project are defined.

Users are specified in their own file. This allows users to be referenced across one or more project level reviewer policies.

Organization Level
There are very few organization level settings that are in-scope for this document. Most of them are set it and forget it.

What is an organization: Get started as a project administrator - Azure DevOps | Microsoft Learn

Users
Users are added to the ADO in the Organization Settings section.

What this is: Add users to organizations and manage access - Azure DevOps | Microsoft Learn

How these are provisioned: Terraform

More information: About access levels - Azure DevOps | Microsoft Learn

Users should only be specified in Terraform if they are used with the Automatically Included Reviewers policy detailed below.

When users leave the company and their accounts are deleted it causes a terminating failure of the terraform pipeline.

Boards
The only org-wide configurable option for boards that includes permissions we grant to users is related to the Boards Process.

Process
What this is: Default processes and process templates - Azure Boards | Microsoft Learn

Permission specific information: Set permissions for work tracking - Azure DevOps | Microsoft Learn

When and how does this get changed: Process settings are changed manually in the tool by authorized users.

Process permissions can only be edited by PCA’s.

Pipelines
Agent Pool
Do not make any changes at the org level for permissions of agent pools. This will filter inadvertent permissions across every agent pool in the organization.

Deployment Pools
Do not make any changes at the org level for permissions of deployment pools. This will filter inadvertent permissions across every deployment pool in the organization.

Project Level
Project
What is a project: About projects and scaling your organization - Azure DevOps | Microsoft Learn

Wiki
What this is: Create a project wiki to share information - Azure DevOps | Microsoft Learn

Permission specific information: Manage permissions for READMEs and wiki pages - Azure DevOps | Microsoft Learn

When and how does this get changed: This is configured via Terraform and should not be changed by PCAs.

More information: Terraform ensures that commits to the main wiki branch can be done without incurring branch policy errors for all project users. This is required for optimal project wiki experience.

Agent Pool
What this is: Create and manage agent pools - Azure Pipelines | Microsoft Learn

When and how does this get changed: New agent pools are created on-demand by Service NOW request submitted by organization users.

Do not change any user level permissions for Agent Pools.

Sharing Agent Pools across projects should be allowed and encouraged where appropriate.

Agent Pools should be allowed to be used by all pipelines in a project.

Agents
New agents in Agent Pools are installed by the cloud team.

This is to ensure that Agents added to Pools have all required software, configurations, and any other shenanigans taken care of before they are added to a pool that can impact one or more projects.

Boards
Area Paths
What this is: Define area paths and assign to a team - Azure Boards | Microsoft Learn

When and how does this get changed: Fully managed by LPAs in the tool. no PCA interaction

Iteration Paths
What this is: Define iteration paths and configure team iterations - Azure Boards | Microsoft Learn

When and how does this get changed: Fully managed by LPAs in the tool. no PCA interaction

Delivery Plans
What this is: Add or edit a Delivery Plan in Azure Boards - Azure Boards | Microsoft Learn

Permission specific information: Set permissions for work tracking - Azure DevOps | Microsoft Learn

When and how does this get changed: This is managed wholly by end users of the tool with no interaction of PCAs.

FAQ about Boards
Q: How do I get another board?

A: Make a new Team

 

Q: How do I add additional boards to my existing team?

A: There are portfilio levels that can be added at the Boards Process level in org settings. Any newly created portfolio levels will be available on all projects that use the changed Process. 

 

Q: How do i start or stop a sprint?

A: This isn’t Jira, there is no concept of starting, stopping, or completing a sprint in ADO. LPAs set dates on Iterations and assign work items to iterations. Y

Repos
Users with stakeholder licenses have no access to repo functionality in private projects in ADO.

If a user is properly a member of groups that grant access to a repo but cannot see it, check their license level.

Cross-Repository Branch Policies
Why cant these be configured in the tool directly by LPAs?

Project level branch policy configuration is where we ensure separation of duty and minimum number of reviewer requirements are respected in Azure Repos.

Because of this, we cannot allow any in-tool configuration of these by LPAs to ensure these policies are always in place.

How do these get configured by non-PCAs?

Any user with access to the Azure DevOps terraform repository in GitLab can configure the Automatically Included Reviewers policy.

No other project level branch policies are configurable by non PCA users via Terraform or any other method.

Example
This is an example of configuring reviewer policies via terraform.

The first policy targets the default branch with a single optional reviewer, the second targets the default branch with two required approvers, and the third targets the main branch with a single optional approver. 



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
  }
Object Level
Boards
Feature overview: What is Azure Boards? - Azure Boards | Microsoft Learn

Team
What is this: Manage teams, configure team tools - Azure DevOps | Microsoft Learn

How are these created: Terraform

Teams created via Terraform automatically have the LPA group for the destination project added as Team Administrators.

How are they managed: In the tool by LPAs or others added as Team Administrators by LPAs

Team Administrators who attempt to add a user who is not a member of our ADO org will be greeted with an error message telling them as such.

Add the user to the org via Terraform and tell the team admin to try again.

We cannot give the ability to create teams to non PA or PCAs. This is a limitation of ADO and how it doesn't allow the permission to be delegated.

Example
This is an example of creating ADO teams via Terraform. The project_teams variable controls what teams are created in a given project.

Add a new team name to the array to create a new team.



  project_teams = ["Team1", "Team2"]
Query
What is this: Define a work item query in Azure Boards - Azure Boards | Microsoft Learn

How are these created: Managed in the tool fully by end users

Repos
Feature overview: Collaborate on code - Azure Repos | Microsoft Learn

How are these created: In the tool directly by any project user

We crawl ACLs with automation code to ensure LPAs have the Edit Policies permission at the repository level.

The automation runs once a day at midnight to apply permissions to newly created repositories.

Per-Repository Branch Policies
LPAs have the ability to set any Branch Policy they want at the repo or branch level per repository directly in the tool itself. They cannot set a less restrictive policy than inherits down from the project level.

For example, we require two votes on default and main/master branches. LPAs cannot set this to one vote for their repository with these permissions.

This is not an ideal management strategy if there are a huge number of repositories for an LPA to manage. It is what we are able to do with what we are given.

Pipelines
What is this: What is Azure Pipelines? - Azure Pipelines | Microsoft Learn

How are these created: In the tool directly by any project user

Environments
What is this: Create and target environments - Azure Pipelines | Microsoft Learn

How are these created: Terraform

Permission specific information: Security section of above link

When environments are created via Terraform, the LPA group is added as an administrator.

This allows them to manage existing environments without being able to create new environments. 

This is an intentional design decision.

Resources
We allow environment administrators the ability to assign specific IaaS compute resources to an environment in Azure DevOps for deployment of applications 

This allows application developers the ability to install ADO agents that can only impact the direct compute node the agent is installed on.

These agents do not impact the entire project if any issues arise due to agent, software, or any other configuration issue.

Example
This is an example of creating ADO environments via Terraform. The deployment_environmentsvariable controls what environments are created in a given project.

The first environment is created with the name “environment1” and is pre-authorized to be used by pipeline “pipeline1”. The second environment is named “shared-environment” and is pre-authorized to be used by all pipelines in the current project. The third environment is named “environment3” and is not pre-authorized for usage by any pipelines.

Note: LPAs are able to perform the same authorization in tool that is done in terraform here. This just avoids the need for an LPA to be present to perform the one-time authorization.



deployment_environments = {
    environment1 = {
      authorized_pipeline_names = ["pipeline1"]
    }
    shared-environment = {
      all_pipelines = true
    }
    environment3 = {}
  }
Service Connections
What is this: Service connections - Azure Pipelines | Microsoft Learn

Permission specific information: Manage security in Azure Pipelines - Azure Pipelines | Microsoft Learn

How these are created: Supported service connection types, AzureRM and Nuget, are created by Terraform. The rest are created by the cloud team manually in the ADO UI.

Regardless of how these are created, they are created with placeholder values for usernames, passwords, and/or tokens required for creation.

Application teams are responsible for updating and maintaining those values after creation.

How permissions are set: LPAs are set as administrators of individual Service Connections to allow them to 

More information:

It is possible to share service connections across projects.

Example
This is an example of creating ADO environments via Terraform. The service_connections variable controls what environments are created in a given project by Terraform.

Due to provider limits, only the below types of service connections are supported. AzureRM Service Connections have multiple authentication schemes available. Consult the previously referenced module documentation for more information about that.



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
Variable Groups
What this is: Manage variable groups - Azure Pipelines | Microsoft Learn

How these are created: By end users in the tool.

Once we have the ability to provision Azure Key Vaults for use with Variable Groups in ADO via Terraform all in one package, we plan to move creation of this into Terraform.

Secure Files
What this is: Secure files for Azure Pipelines - Azure Pipelines | Microsoft Learn

How these are created: By request only, manually in the tool.

More information: Due to the nature of how these secure files work, you will have to give whoever has possession of the file the Creator permission in the Library section of the project the file is being uploaded to. These files cannot be changed after upload and can only be downloaded by the pipeline after that.

In most circumstances, we as the cloud team probably do not want possession of the file that need to go in as it contains some sort of secret/authentication related data we dont need to have access to. make the user upload it themselves.

To replace a Secure File, you must delete it and upload it again.

Classic Build/Release
Terraform has no support for Classic pipelines in any fashion. This includes support for:

Classic Build Definitions

Classic Release Definitions

Deployment Groups

LPAs are given all permissions in the Release and Deployment Group sections of Azure DevOps to allow continued operations.

NOTE: This is something we may want to pull back from in projects that have no classic pipeline presence?

There is an option to disable creation of classic pipelines we can leverage in projects that have no classic usage.

LPAs cannot create new Classic Build pipelines and are very extremely strongly encouraged to move to a YAML pipeline instead if they need a net-new pipeline.











╵=============================||=================================================

--------------------------------------------------


========


