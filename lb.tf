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
To integrate the additional information provided by the Zscaler team into the Zscaler Proxy Configuration section, we can update the instructions to reflect the new proxy logic and provide guidance on when and which proxy configuration to use based on the network and destination requirements.

Here’s an updated version of the Zscaler Proxy Configuration section with the new logic included:

5.2 Steps to Configure Zscaler Proxy for Docker
Step 1: Determine Which Proxy Configuration to Use
Before configuring Docker, you need to decide which Zscaler proxy configuration applies to your use case based on the following logic:

Does your destination require Source IP Whitelisting?

If yes, then you need to use the On-prem proxy configuration.

If no, proceed to the next question.

Are you traversing a vendor circuit?

If yes, use the external proxy configuration.

If no, proceed with the corporate network configuration.

The following proxy configurations should be used depending on the network environment:

For On-prem environments: Use the proxy Zxx.comp.com:80.

For non-On-prem (external) environments: Use the proxy Zxxarg.comp.com:80.

Step 2: Obtain Zscaler Proxy Details
Contact your network administrator for the appropriate Zscaler proxy hostname and port based on the proxy configuration logic.

For On-prem configurations, the proxy would be: Zxx.comp.com:80.

For external (non-On-prem) configurations, use: Zxxarg.comp.com:80.

You can now proceed with setting up Docker to route requests through the Zscaler proxy.

Step 3: Configure Docker to Use Zscaler Proxy
Open a terminal and set the proxy environment variables:

bash
Copy
export HTTP_PROXY=http://Zxxarg.comp.com:80
export HTTPS_PROXY=http://Zxxarg.comp.com:443
export NO_PROXY=localhost,127.0.0.1
Note: If you're on an on-prem environment, replace Zxxarg.comp.com with Zxx.comp.com.

To make these settings permanent, add them to your shell profile:

bash
Copy
echo "export HTTP_PROXY=http://Zxxarg.comp.com:80" >> ~/.bashrc
echo "export HTTPS_PROXY=http://Zxxarg.comp.com:443" >> ~/.bashrc
echo "export NO_PROXY=localhost,127.0.0.1" >> ~/.bashrc
source ~/.bashrc
Note: For on-prem configurations, update the proxy to Zxx.comp.com.

Step 4: Update Docker Daemon Configuration
Edit the Docker daemon.json file:

bash
Copy
sudo nano /etc/docker/daemon.json
Add the proxy configuration to the file:

json
Copy
{
  "proxies": {
    "default": {
      "httpProxy": "http://Zxxarg.comp.com:80",
      "httpsProxy": "http://Zxxarg.comp.com:443",
      "noProxy": ["localhost", "127.0.0.1"]
    }
  }
}
Note: For on-prem configurations, replace Zxxarg.comp.com with Zxx.comp.com.

Save the file (CTRL + X, then Y and Enter).

Restart Docker to apply the changes:

bash
Copy
sudo systemctl restart docker
Step 5: Test Proxy Configuration
Run a simple Docker pull command to verify that the proxy configuration is working:

bash
Copy
docker pull hello-world
If the pull command succeeds, it indicates that Zscaler is correctly routing the requests through the proxy.



=================||




=====||====






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


