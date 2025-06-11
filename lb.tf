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




╵=============================||=================================================

--------------------------------------------------


========


