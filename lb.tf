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
Here’s a draft merge‐request description you can use. Just drop in your actual plan run URL in place of `<PLAN_RUN_URL>`:

---

## Refactor: Remove direct repo & pipeline management from parent module

### Summary

This PR refactors our Terraform parent-module to stop creating Azure DevOps repos and pipelines directly, and instead:

* **Preserves** all existing repos/pipelines in state (no destroys) via `removed {}` blocks
* **Replaces** resource blocks with data lookups for any existing objects
* **Makes** `repos` and `pipelines` inputs optional (default to `[]` / `{}`)
* **Updates** pipeline‐authorization and permission blocks to index into data sources
* **Ensures** no destructive changes: **Plan shows 0 destroy**

### Details of changes

1. **variables.tf**

   * Added defaults for `var.repos` and `var.pipelines` so they’re optional.
2. **git-repository.tf**

   * Commented-out/deleted `azuredevops_git_repository` resource.
   * Added `removed { from = azuredevops_git_repository.this }` with `lifecycle { destroy = false }`.
   * Introduced `data.azuredevops_git_repository.this` (for\_each over `var.repos`).
3. **pipelines.tf**

   * Commented-out/deleted `azuredevops_build_folder` & `azuredevops_build_definition` resources.
   * Added `removed {}` blocks for both resource types.
   * Introduced `data.azuredevops_build_definition.this` (for\_each over processed pipelines).
4. **pipeline-authorization.tf**

   * Swapped all references from `azuredevops_build_definition.this` → `data.azuredevops_build_definition.this`.
   * Wrapped each `for_each` in a length-guard so blocks are skipped when no pipelines are provided.
   * Added `removed {}` blocks for all `azuredevops_pipeline_authorization.*` resources.
5. **limited-project-admin.tf**

   * Added `removed {}` for `azuredevops_git_permissions.limited_project_admin_per_repo` (plus any other permission types as needed).
6. **examples.tf**

   * Removed `repos = […]` / `pipelines = {…}` from sample call (they now default to empty).
   * Bumped `required_version = ">= 1.7.0"` to support `removed {}` in HCL.
7. **Other files** (`branch-policies.tf`, `groups.tf`, `environments.tf`, `main.tf`) remain functionally unchanged.

### Why this matters

* **No repos or pipelines** will be destroyed by Terraform—existing ADO objects remain intact.
* We retain full ability to look up and manage authorizations via data sources.
* Downstream modules and examples continue to work with zero friction.

---

**Plan run:**
[View zero-destroy plan in Terraform Cloud →](PLAN_RUN_URL)

---








================================||

Here’s a clean and professional **Merge Request (MR) description** that summarizes your cleanup work, aligns with your colleagues’ goals, and explains the rationale:

---

## 🔧 Merge Request: Cleanup of Repo, Pipeline, and Permission Resources from ADO Terraform Project

### ✅ Summary

This merge request removes all Terraform-managed **Git repositories**, **pipelines**, and their associated **permissions** from the project module in accordance with our team’s SaaS state decoupling strategy.

---

### 🧹 Changes Included

* Removed all `azuredevops_git_repository` resource blocks
* Removed all `azuredevops_build_definition` pipeline resources
* Removed associated `azuredevops_git_permissions` and `azuredevops_build_definition_permissions` tied to the deleted repos and pipelines
* Removed related variables (`repos`, `pipelines`, etc.) and their usages in `for_each` expressions
* Identified all removed resources to be handled with `terraform state rm` to ensure:

  * Resources are no longer managed by Terraform
  * No actual infrastructure is destroyed in Azure DevOps

---

### 📌 Next Steps

* Run `terraform state rm` for all removed resources (see cleanup script or plan doc)
* Confirm that no unintended resource deletions occur
* Ensure any future management of these ADO resources is tracked externally (e.g., manually or by another tool)

---

### 🛑 Important Notes

* This MR **does not destroy** any Azure DevOps resources
* It simply **untracks them from Terraform state**
* This is part of our move toward **more granular state management and reduced Terraform blast radius**

---




======




#################





=======================================
======================================
## 



=======================================
======================================
# 
A: I would expect this to be done in the SaaS repo to impact state there and not specified in the module
I finding it a bit difficult to think of the best way to implement the cleanup process for the repos and pipelines before I follow this path here. I am not sure of how you picture the workflow from parent module (here) to the root module (SaaS repo) but I think the best path to do the clean up is first to untrack the relevant repos and pipelines and associated resources here and then work on cleaning up individuals repo and pipeline in the SaaS repo. The SaaS repo module is the one calling the parent module here. What do you think?

B: does this work run-over-run or will it only work once and then throw and error? thats my major concern. if this is idempotent it works for me.

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


