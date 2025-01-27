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
=================||




#------------------- Firewall Rules ---------------------#
#--------------------------------------------------------#
### https://www.terraform.io/docs/providers/azurerm/r/firewall_network_rule_collection.html#rule

### https://docs.microsoft.com/en-us/azure/mysql/concepts-connectivity-architecture
resource "azurerm_firewall_network_rule_collection" "Databricks_allow" {
  name                = "Databricks_network_allow"
  azure_firewall_name = azurerm_firewall.fw-hub.name
  resource_group_name = local.network_resource_group_name
  priority            = 104
  action              = "Allow"

  rule {
    name = "Hive"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    destination_ports = [
      "3306",
    ]

    destination_fqdns = [
      "consolidated-eastusc3-prod-metastore-0.mysql.database.azure.com",
      "consolidated-eastus-prod-metastore.mysql.database.azure.com",
      "consolidated-eastus-prod-metastore-addl-1.mysql.database.azure.com",
      "consolidated-eastusc2-prod-metastore-0.mysql.database.azure.com"
    ]

    protocols = [
      "TCP"
    ]
  }
}

### DataBricks Rules for FW based on https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr

resource "azurerm_firewall_application_rule_collection" "Databricks_allow" {
  name                = "Databricks_Allow"
  azure_firewall_name = azurerm_firewall.fw-hub.name
  resource_group_name = local.network_resource_group_name
  priority            = 102
  action              = "Allow"
  rule {
    name = "db_http_resources"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "crl.microsoft.com",
      "azure.archive.ubuntu.com",
      "ppa.launchpad.net",
      "www.terracotta.org",
      "security.ubuntu.com",
      "ifconfig.co",
      "ctldl.windowsupdate.com",
      "go.microsoft.com"
    ]

    protocol {
      port = "80"
      type = "Http"
    }
  }

  rule {
    name = "RStudio"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "r-project.org",
      "mirror.las.iastate.edu",
      "ftp.ussg.iu.edu",
      "rweb.crmda.ku.edu",
      "repo.miserver.it.umich.edu",
      "cran.wustl.edu",
      "archive.linux.duke.edu",
      "cran.case.edu",
      "ftp.osuosl.org",
      "lib.stat.cmu.edu",
      "cran.mirrors.hoobly.com",
      "mirrors.nics.utk.edu",
      "cran.microsoft.com",
      "cran.rstudio.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "DBResources"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "management.azure.com",
      "*.blob.storage.azure.net",
      "*.bokf.com",
      "aka.ms",
      "azcopyvnext.azureedge.net",
      "api.loganalytics.io",
      "motd.ubuntu.com",
      "pypi.python.org",
      "files.pythonhosted.org",
      "pypi.org",
      "registry.npmjs.org",
      "dns.google.com",
      "login.microsoftonline.com",
      "packages.microsoft.com",
      "cdnjs.cloudflare.com",
      "nvidia.github.io",
      "deb.nodesource.com",
      "md-rshd52pckc2j.z12.blob.storage.azure.net",
      "md-1g1fmhcr5ql2.z18.blob.storage.azure.net",
      "md-3tsqgccbnlw3.z29.blob.storage.azure.net",
      "md-ztn2cqkvcbqp.z28.blob.storage.azure.net",
      "md-jsvgsbrk2h1p.z28.blob.storage.azure.net",
      "md-hq2fkq4rbp1h.z13.blob.storage.azure.net",
      "shavamanifestcusprod1.blob.core.windows.net",
      "rdfepirv2bl2prdstr01.blob.core.windows.net",
      "rdfepirv2bl2prdstr02.blob.core.windows.net",
      "rdfepirv2bl2prdstr03.blob.core.windows.net",
      "rdfepirv2bl2prdstr04.blob.core.windows.net",
      "rdfepirv2bl3prdstr01.blob.core.windows.net",
      "rdfepirv2bl3prdstr02.blob.core.windows.net",
      "rdfepirv2bl3prdstr03.blob.core.windows.net",
      "rdfepirv2bl3prdstr04.blob.core.windows.net",
      "zrdfepirv2bl4prdstr01.blob.core.windows.net",
      "zrdfepirv2bl5prdstr06.blob.core.windows.net",
      "zrdfepirv2bl5prdstr04.blob.core.windows.net",
      "zrdfepirv2bl5prdstr12a.blob.core.windows.net",
      "zrdfepirv2bl6prdstr09a.blob.core.windows.net",
      "zrdfepirv2bl6prdstr02a.blob.core.windows.net",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dbmanagedstorageOpsdev"

    source_addresses = [
      "172.21.130.0/24"
    ]

    target_fqdns = [
      "dbstorageygeyb2yvhgxm6.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dbmanagedstorageAnalyticsdev"

    source_addresses = [
      "172.21.131.0/24"
    ]

    target_fqdns = [
      "dbstoragejxkgqjfrfc3w4.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dbmanagedstorageOpstst"

    source_addresses = [
      "172.22.2.0/24"
    ]

    target_fqdns = [
      "dbstorageyxb54rzs4zdg4.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dbmanagedstorageAnalyticstst"

    source_addresses = [
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "dbstorage3oaj7gnuuawyk.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dbmanagedstorageOpsprd"

    source_addresses = [
      "172.20.2.0/24"
    ]

    target_fqdns = [
      "dbstorageawngrjetaj7qg.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dbmanagedstorageAnalyticsprd"

    source_addresses = [
      "172.20.3.0/24"
    ]

    target_fqdns = [
      "dbstorageg7lvddefiad7w.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "DBMetastore"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "consolidated-eastus-prod-metastore.mysql.database.azure.com",
      "consolidated-eastus-prod-metastore-addl-1.mysql.database.azure.com",
      "consolidated-eastusc2-prod-metastore-0.mysql.database.azure.com",
      "consolidated-eastusc3-prod-metastore-0.mysql.database.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "DBArtifactBlobstorage"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "dbartifactsprodeastus.blob.core.windows.net",
      "arprodeastusa1.blob.core.windows.net",
      "arprodeastusa2.blob.core.windows.net",
      "arprodeastusa3.blob.core.windows.net",
      "arprodeastusa4.blob.core.windows.net",
      "arprodeastusa5.blob.core.windows.net",
      "arprodeastusa6.blob.core.windows.net",
      "dbartifactsprodeastus2.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "DBLogBlobstorage"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "dblogprodwestus.blob.core.windows.net",
      "dblogprodeastus.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "DBEventHub"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "prod-westus-observabilityEventHubs.servicebus.windows.net",
      "prod-eastusc2-observabilityeventhubs.servicebus.windows.net",
      "prod-eastusc3-observabilityeventhubs.servicebus.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "DBSCCRelay"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "eastus-c3.azuredatabricks.net",
      "tunnel.eastus2.azuredatabricks.net",
      "tunnel.eastusc3.azuredatabricks.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "AllowSentinel"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "b321199a-f396-431e-bbb2-b538a9d7c5ff.ods.opinsights.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}
resource "azurerm_firewall_application_rule_collection" "Databricks_deny" {
  name                = "Databricks_Deny"
  azure_firewall_name = azurerm_firewall.fw-hub.name
  resource_group_name = local.network_resource_group_name
  priority            = 109
  action              = "Deny"

  rule {
    name = "Deny"

    source_addresses = [
      "172.21.130.0/24",
      "172.21.131.0/24",
      "172.20.2.0/24",
      "172.20.3.0/24",
      "172.22.2.0/24",
      "172.22.3.0/24"
    ]

    target_fqdns = [
      "*"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }
  }
}
======||===
locals {
  # -- Global vars -- #
  deployedBy = "azure-security-bokf-${var.environment}"
  #--Network specific vars--#
  #Virtual Network#
  network_vnet_name = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-vnet"
  #Resource Group#
  network_resource_group_name = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-rg-network"
  #Subnet#
  network_subnet_name_base = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-snet"
  #Public IP#
  network_ip_name_base = "bokf-${var.network_application_id}-${var.environment_long}-${var.location_short}-pubip"
  #Virtual Network Gateway#
  network_vng_name_base = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-vng"
  #Private Link#
  network_pl_name_base = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-pl"
  #Private Endpoint#
  network_pe_name_base = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-pe"
  #Load Balancer#
  network_lb_name_base = "bokf-${var.network_application_id}-${var.environment}-${var.location_short}-lb"
  #--Security Specific vars--#
  #Resource Group#
  fw_resource_group_name = "bokf-${var.fw_application_id}-${var.environment}-${var.location_short}-rg-fw"
  #Firewall#
  fw_firewall_name = "bokf-${var.fw_application_id}-${var.environment}-${var.location_short}-fw"

}

locals {
  #Virtual Network#
  edl_vnet_name = "bokf-${var.edl_application_id}-${var.environment_alt}-${var.location_short}-vnet-datalake"
  #Resource Group#
  edl_resource_group_name = "bokf-${var.edl_application_id}-${var.environment_long}-${var.location_short}-rg-datalake"
  #Subnet#
  edl_subnet_name_base = "bokf-${var.edl_application_id}-${var.environment_alt}-${var.location_short}-snet"
  #Public IP#
  edl_ip_name_base = "bokf-${var.edl_application_id}-${var.environment}-${var.location_short}-pubip"
  #Virtual edl Gateway#
  edl_vng_name_base = "bokf-${var.edl_application_id}-${var.environment}-${var.location_short}-vng"
  #Private Link#
  edl_pl_name_base = "bokf-${var.edl_application_id}-${var.environment}-${var.location_short}-pl"
  #Private Endpoint#
  edl_pe_name_base = "bokf-${var.edl_application_id}-${var.environment}-${var.location_short}-pe"
  #Load Balancer#
  edl_lb_name_base = "bokf-${var.edl_application_id}-${var.environment}-${var.location_short}-lb"
  #Route Table#
  edl_rt_name_base = "bokf-${var.edl_application_id}-${var.environment}-${var.location_short}-rt"
}
#----- Data Block for VNET and Subnet Configuration -----#
#--------------------------------------------------------#
data "azurerm_virtual_network" "vnet-hub" {
  name                = "${local.network_vnet_name}-network"
  resource_group_name = local.network_resource_group_name
}

data "azurerm_subnet" "snet-fw" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet-hub.name
  resource_group_name  = local.network_resource_group_name
}

#----- Public IP and Firewall Resource Definition -------#
#--------------------------------------------------------#

resource "azurerm_public_ip" "fw-pub-ip" {
  name                = "${local.network_ip_name_base}-fw"
  location            = var.location_long
  resource_group_name = local.network_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    applicationId      = var.fw_application_id
    costCenter         = var.fw_cost_center
    managedBy          = var.fw_managed_by
    environment        = var.environment
    assetClass         = "standard"
    dataClassification = "confidential"
    requestedBy        = "lloyd@bokf.com"
    sourceCode         = var.sourceCode
    deployedBy         = local.deployedBy
  }
}

resource "azurerm_firewall" "fw-hub" {
  name                = "${local.fw_firewall_name}-hub"
  location            = var.location_long
  resource_group_name = local.network_resource_group_name

  zones = [
    "1",
    "2",
    "3"
  ]

  ip_configuration {
    name                 = "${local.fw_firewall_name}-hub-configuration"
    subnet_id            = data.azurerm_subnet.snet-fw.id
    public_ip_address_id = azurerm_public_ip.fw-pub-ip.id
  }


  tags = {
    applicationId      = var.fw_application_id
    costCenter         = var.fw_cost_center
    managedBy          = var.fw_managed_by
    environment        = var.environment
    assetClass         = "standard"
    dataClassification = "confidential"
    requestedBy        = "lloyd@bokf.com"
    sourceCode         = var.sourceCode
    deployedBy         = local.deployedBy
  }
}

data "azurerm_log_analytics_workspace" "sentinel" {
  name                = "sentinel-log-analytics-workspace-BOKF-${var.environment_long}"
  resource_group_name = local.edl_resource_group_name
}

data "azurerm_monitor_diagnostic_categories" "sentinel" {
  resource_id = data.azurerm_log_analytics_workspace.sentinel.id
}

resource "azurerm_monitor_diagnostic_setting" "fw-hub-NetworkRule" {
  name                           = "sendToALA"
  target_resource_id             = azurerm_firewall.fw-hub.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.sentinel.id
  log_analytics_destination_type = "Dedicated"

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "365"
    }
  }
  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "365"
    }
  }
  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "365"
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "ApplicationRules" {
  name                = "ApplicationRules"
  azure_firewall_name = azurerm_firewall.fw-hub.name
  resource_group_name = local.network_resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name = "QualysAgent"

    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    target_fqdns = [
      "*.apps.qualys.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "ServiceNow"

    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    target_fqdns = [
      "*.bokf.service-now.com",
      "*.bokfdev.service-now.com",
      "*.bokfuat.service-now.com",
      "*.bokftraining.service-now.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "Crowdstrike"

    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    target_fqdns = [
      "*.cloudsink.net",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "CoreAKSServices"

    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    target_fqdns = [
      "bokf-3984-prd-eastus-pv-edl.catalog.purview.azure.com",
      "*.hcp.eastus.azmk8s.io",
      "*.ods.opinsights.azure.com",
      "azure.archive.ubuntu.com",
      "security.ubuntu.com",
      "dc.services.visualstudio.com",
      "api.snapcraft.io",
      "*.agentsvc.azure-automation.net",
      "*.oms.opinsights.azure.com",
      "billing-agent-apim-eus.azure-api.net",
      "prod.warmpath.msftcloudes.com",
      "eastus.handler.control.monitor.azure.com",
      "eastus.monitoring.azure.com",
      "login.microsoftonline.com",
      "*.servicebus.windows.net",
      "motd.ubuntu.com",
      "*.githubusercontent.com",
      "*.mcr.microsoft.com",
      "*.docker.io",
      "production.cloudflare.docker.com",
      "cloud.streamsets.com",
      "kubernetes.default.svc.cluster.local",
      "mcr.microsoft.com",
      "*.vault.azure.net",
      "*.blob.core.windows.net",
      "ifconfig.co",
      "store.policy.core.windows.net",
      "*.blob.storage.azure.net",
      "*.microsoft.com",
      "ctldl.windowsupdate.com",
      "management.azure.com"
    ]

    protocol {
      port = "80"
      type = "Http"
    }

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "Aqua"

    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    target_fqdns = [
      "*.aese.aquasec.com",
      "registry.aquasec.com"
    ]
    protocol {
      port = "8443"
      type = "Https"
    }
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "allow_our_databricks"


    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    target_fqdns = [
      "adb-1763415570457674.14.azuredatabricks.net",
      "adb-4589478816391136.16.azuredatabricks.net",
      "adb-7418674309738545.5.azuredatabricks.net",
      "adb-1633592426823480.0.azuredatabricks.net",
      "adb-4196185629570810.10.azuredatabricks.net",
      "adb-4471872891921740.0.azuredatabricks.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "kusto_reqs"
    source_addresses = [
      "172.20.0.0/24",
      "172.21.0.0/24",
      "172.22.0.0/24",
    ]
    target_fqdns = [
      "*.core.windows.net"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "AKS_Access"

    source_addresses = [
      "172.20.0.0/24",
      "172.21.0.0/24",
      "172.22.0.0/24",
      "172.21.32.0/19",
      "172.22.32.0/19",
      "172.20.32.0/19"
    ]

    target_fqdns = [
      "github.com",
      "*.github.com",
      "*.terraform.io",
      "tap-api.proofpoint.com",
      "tap-api-v2.proofpoint.com",
      "api.threatstream.com",
      "s3.us-east-2.amazonaws.com",
      "s3.us-west-1.amazonaws.com",
      "*.s3.amazonaws.com",
      "sqs.us-west-1.amazonaws.com",
      "sqs.us-east-2.amazonaws.com",
      "ts-optic.s3.amazonaws.com",
      "releases.hashicorp.com",
      "*.streamsets.com",
      // TODO: only want to be using virtual repos, not direct access to local repos
      "bokf-docker.jfrog.io",
      "bokf-is-docker-local.jfrog.io",
      "bokf.jfrog.io",
      "management.azure.com",
      "download.maxmind.com",
      "api.crowdstrike.com",
      "*.okta.com",
      "*.oktapreview.com",
      "data.policy.core.windows.net",
      "packages.microsoft.com",
      "ifconfig.co",
      "helm.gremlin.com",
      "api.gremlin.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "ThreatStream"
    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]
    target_fqdns = [
      "*.threatstream.com",
      "ts-optic.s3.amazonaws.com",
      "*.anomali.com",
      "graph.microsoft.com",
      "graph.windows.net"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }
  }

  rule {
    name = "AKS_Azure_Services"

    source_addresses = [
      "172.20.0.128/25",
      "172.21.128.128/25",
      "172.22.0.128/25"
    ]

    fqdn_tags = [
      "AppServiceEnvironment",
      "AzureBackup",
      "AzureKubernetesService",
      "HDInsight",
      "MicrosoftActiveProtectionService",
      "WindowsDiagnostics",
      "WindowsUpdate"
    ]
  }

}

resource "azurerm_firewall_network_rule_collection" "EDL-AKD" {
  name                = "EDL-AKS"
  azure_firewall_name = azurerm_firewall.fw-hub.name
  resource_group_name = local.network_resource_group_name
  priority            = 404
  action              = "Allow"

  rule {
    name = "AKS_MGMT"

    source_addresses = [
      "172.20.0.128/25",
      "172.21.128.128/25",
      "172.22.0.128/25"
    ]

    destination_ports = [
      "*"
    ]

    destination_addresses = [
      "52.149.239.144",
      "52.188.30.178",
      "52.142.33.51"
    ]

    protocols = [
      "TCP",
      "UDP"
    ]
  }
  rule {
    name = "AKS_EventHub"

    source_addresses = [
      "172.20.0.128/25",
      "172.21.128.128/25",
      "172.22.0.128/25"
    ]

    destination_ports = [
      "5671"
    ]

    destination_addresses = [
      "40.71.10.173",
      "52.168.147.11",
      "52.226.36.235"
    ]
    protocols = [
      "TCP",
      "UDP"
    ]
  }
  rule {
    name = "ZScaler_NSS"

    source_addresses = [
      "172.22.0.0/25",
      "172.21.128.0/25",
      "172.20.0.0/25"

    ]
    destination_addresses = [
      "104.129.192.0/20",
      "137.83.128.0/18",
      "165.225.0.0/17",
      "165.225.192.0/18",
      "185.46.212.0/22",
      "199.168.148.0/22",
      "209.51.184.0/26",
      "213.152.228.0/24",
      "216.218.133.192/26",
      "216.52.207.64/26",
      "27.251.211.238/32",
      "64.74.126.64/26",
      "70.39.159.0/24",
      "72.52.96.0/26",
      "8.25.203.0/24",
      "89.167.131.0/24",
      "136.226.0.0/16",
      "147.161.128.0/17"
    ]
    protocols = [
      "TCP",
      "UDP",
    ]
    destination_ports = [
      "443",
      "12002",
      "53",
      "123"
    ]
  }
}

resource "azurerm_firewall_network_rule_collection" "Network_Rules" {
  name                = "Network_Rules"
  azure_firewall_name = azurerm_firewall.fw-hub.name
  resource_group_name = local.network_resource_group_name
  priority            = 1028
  action              = "Allow"

  rule {
    name = "Network_Rules"

    source_addresses = [
      "172.20.0.0/16",
      "172.21.0.0/16",
      "172.22.0.0/16"
    ]

    destination_ports = [
      "123",
    ]

    destination_addresses = [
      "91.189.89.198",
      "91.189.91.157",
      "91.189.89.199",
      "91.189.94.4"
    ]

    protocols = [
      "TCP",
      "UDP"
    ]
  }
}
-----\\---
% terraform plan
Running plan in the remote backend. Output will stream here. Pressing Ctrl-C
will stop streaming the logs, but will not stop the plan running remotely.

Preparing the remote plan...

The remote workspace is configured to work with configuration at
tf relative to the target repository.

Terraform will upload the contents of the following directory,
excluding files or directories as defined by a .terraformignore file
at /Users/sxa7bu/AZURE/azure-security/.terraformignore (if it is present),
in order to capture the filesystem context the remote workspace expects:
    /Users/sxa7bu/AZURE/azure-security

To view this run in a browser, visit:
https://app.terraform.io/app/bokf/azure-security-bokf-dev/runs/run-zFX5McwouhdQ1wPE

Waiting for the plan to start...

Terraform v1.0.3
on linux_amd64
Initializing plugins and modules...
azurerm_public_ip.fw-pub-ip: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/publicIPAddresses/bokf-0000-dev-eastus-pubip-fw]
azurerm_firewall.fw-hub: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub]
azurerm_firewall_application_rule_collection.Databricks_deny: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/Databricks_Deny]
azurerm_firewall_network_rule_collection.Network_Rules: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/networkRuleCollections/Network_Rules]
azurerm_firewall_network_rule_collection.Databricks_allow: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/networkRuleCollections/Databricks_network_allow]
azurerm_monitor_diagnostic_setting.fw-hub-NetworkRule: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub|sendToALA]
azurerm_firewall_application_rule_collection.ApplicationRules: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/ApplicationRules]
azurerm_firewall_network_rule_collection.EDL-AKD: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/networkRuleCollections/EDL-AKS]
azurerm_firewall_application_rule_collection.Databricks_allow: Refreshing state... [id=/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/Databricks_Allow]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply":

  # azurerm_firewall_application_rule_collection.ApplicationRules has been changed
  ~ resource "azurerm_firewall_application_rule_collection" "ApplicationRules" {
        id                  = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/ApplicationRules"
        name                = "ApplicationRules"
        # (4 unchanged attributes hidden)

      ~ rule {
            name             = "AKS_Azure_Services"
          + source_ip_groups = []
          + target_fqdns     = []
            # (2 unchanged attributes hidden)
        }
        # (9 unchanged blocks hidden)
    }
  # azurerm_firewall_application_rule_collection.Databricks_allow has been changed
  ~ resource "azurerm_firewall_application_rule_collection" "Databricks_allow" {
        id                  = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/Databricks_Allow"
        name                = "Databricks_Allow"
        # (4 unchanged attributes hidden)

      + rule {
          + fqdn_tags        = []
          + name             = "immutta"
          + source_addresses = [
              + "172.21.131.0/24",
            ]
          + source_ip_groups = []
          + target_fqdns     = [
              + "production-bank-of-oklahoma.hosted.immutacloud.com",
            ]

          + protocol {
              + port = 443
              + type = "Https"
            }
        }
        # (15 unchanged blocks hidden)
    }
  # azurerm_monitor_diagnostic_setting.fw-hub-NetworkRule has been changed
  ~ resource "azurerm_monitor_diagnostic_setting" "fw-hub-NetworkRule" {
        id                         = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub|sendToALA"
        name                       = "sendToALA"
        # (2 unchanged attributes hidden)

      + log {
          + category = "AZFWApplicationRule"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWApplicationRuleAggregation"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWDnsQuery"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWFatFlow"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWFlowTrace"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWFqdnResolveFailure"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWIdpsSignature"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWNatRule"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWNatRuleAggregation"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWNetworkRule"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWNetworkRuleAggregation"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }
      + log {
          + category = "AZFWThreatIntel"
          + enabled  = false

          + retention_policy {
              + days    = 0
              + enabled = false
            }
        }

        # (4 unchanged blocks hidden)
    }
  # azurerm_public_ip.fw-pub-ip has been changed
  ~ resource "azurerm_public_ip" "fw-pub-ip" {
      + availability_zone       = "Zone-Redundant"
        id                      = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/publicIPAddresses/bokf-0000-dev-eastus-pubip-fw"
      + ip_tags                 = {}
        name                    = "bokf-0000-dev-eastus-pubip-fw"
      + sku_tier                = "Regional"
        tags                    = {
            "applicationId"      = "0000"
            "assetClass"         = "standard"
            "costCenter"         = "7915"
            "dataClassification" = "confidential"
            "deployedBy"         = "azure-security-bokf-dev"
            "environment"        = "dev"
            "managedBy"          = "IS_ENG"
            "requestedBy"        = "lloyd@bokf.com"
            "sourceCode"         = "https://gitlab.com/bokf/is/azure-security"
        }
        # (8 unchanged attributes hidden)
    }
  # azurerm_firewall.fw-hub has been changed
  ~ resource "azurerm_firewall" "fw-hub" {
        id                  = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub"
        name                = "bokf-0000-dev-eastus-fw-hub"
      + private_ip_ranges   = []
        tags                = {
            "applicationId"      = "0000"
            "assetClass"         = "standard"
            "costCenter"         = "7915"
            "dataClassification" = "confidential"
            "deployedBy"         = "azure-security-bokf-dev"
            "environment"        = "dev"
            "managedBy"          = "IS_ENG"
            "requestedBy"        = "lloyd@bokf.com"
            "sourceCode"         = "https://gitlab.com/bokf/is/azure-security"
        }
        # (7 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the
relevant attributes using ignore_changes, the following plan may include
actions to undo or respond to these changes.

─────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_firewall_application_rule_collection.ApplicationRules will be updated in-place
  ~ resource "azurerm_firewall_application_rule_collection" "ApplicationRules" {
        id                  = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/ApplicationRules"
        name                = "ApplicationRules"
        # (4 unchanged attributes hidden)

      ~ rule {
            name             = "AKS_Access"
          ~ target_fqdns     = [
              + "api.gremlin.com",
              + "bokf-docker.jfrog.io",
              + "bokf.jfrog.io",
              + "helm.gremlin.com",
                # (23 unchanged elements hidden)
            ]
            # (3 unchanged attributes hidden)

            # (1 unchanged block hidden)
        }
        # (9 unchanged blocks hidden)
    }

  # azurerm_firewall_application_rule_collection.Databricks_allow will be updated in-place
  ~ resource "azurerm_firewall_application_rule_collection" "Databricks_allow" {
        id                  = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub/applicationRuleCollections/Databricks_Allow"
        name                = "Databricks_Allow"
        # (4 unchanged attributes hidden)

      - rule {
          - fqdn_tags        = [] -> null
          - name             = "immutta" -> null
          - source_addresses = [
              - "172.21.131.0/24",
            ] -> null
          - source_ip_groups = [] -> null
          - target_fqdns     = [
              - "production-bank-of-oklahoma.hosted.immutacloud.com",
            ] -> null

          - protocol {
              - port = 443 -> null
              - type = "Https" -> null
            }
        }
        # (15 unchanged blocks hidden)
    }

  # azurerm_monitor_diagnostic_setting.fw-hub-NetworkRule will be updated in-place
  ~ resource "azurerm_monitor_diagnostic_setting" "fw-hub-NetworkRule" {
        id                             = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-0000-dev-eastus-rg-network/providers/Microsoft.Network/azureFirewalls/bokf-0000-dev-eastus-fw-hub|sendToALA"
      + log_analytics_destination_type = "Dedicated"
      ~ log_analytics_workspace_id     = "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-2913-dev-eastus-rg-datalake/providers/Microsoft.OperationalInsights/workspaces/sentinel-log-analytics-workspace-bokf-dev" -> "/subscriptions/664c3d7f-8244-467c-b933-4a2ae3a5964e/resourceGroups/bokf-2913-dev-eastus-rg-datalake/providers/Microsoft.OperationalInsights/workspaces/sentinel-log-analytics-workspace-BOKF-dev"
        name                           = "sendToALA"
        # (1 unchanged attribute hidden)

      - log {
          - category = "AZFWApplicationRule" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWApplicationRuleAggregation" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWDnsQuery" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWFatFlow" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWFlowTrace" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWFqdnResolveFailure" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWIdpsSignature" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWNatRule" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWNatRuleAggregation" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWNetworkRule" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWNetworkRuleAggregation" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }
      - log {
          - category = "AZFWThreatIntel" -> null
          - enabled  = false -> null

          - retention_policy {
              - days    = 0 -> null
              - enabled = false -> null
            }
        }

        # (4 unchanged blocks hidden)
    }

Plan: 0 to add, 3 to change, 0 to destroy.





-----------------------------------------------------

## Required Module Specific Variables

variable "consistency_level" {
  description = "(Required) The Consistency Level to use for this CosmosDB Account. Valid values are (BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix)"
  type        = string
  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "Valid values for cosmosdb kind are (BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix)."
  }
}

variable "resource_group_name" {
  description = "(Required) Name of the resource group where the cosmosdb belongs."
  type        = string
}

## Optional Module Specific Variables

variable "additional_ip_addresses" {
  description = "(Optional) One or more IP Addresses, or CIDR Blocks which should be able to access CosmosDb. Additional Ip's can be whitelisted when 'private endpoint is not enabled'"
  type        = list(any)
  default     = []
}

variable "additional_subnet_ids" {
  description = "(Optional) Subnet/s to be allowed in the firewall to access CosmosDb"
  type        = list(any)
  default     = []
}

variable "allowed_origins" {
  description = <<EOT
  (Optional) Configures the allowed origins for this Cosmos DB account in CORS Feature:
  A list of origin domains that will be allowed by CORS.
  EOT
  type        = list(string)
  default     = []
}

variable "backup_type" {
  description = "(Optional) The type of the backup. Possible values are Continuous and Periodic. Defaults to Periodic."
  type        = string
  default     = "Periodic"
}

variable "capabilities" {
  description = <<EOT
  (Optional) Configures the capabilities to enable for this Cosmos DB account:
  Possible values are
  AllowSelfServeUpgradeToMongo36, DisableRateLimitingResponses,
  EnableAggregationPipeline, EnableCassandra, EnableGremlin,EnableMongo, EnableTable, EnableServerless,
  MongoDBv3.4 and mongoEnableDocLevelTTL.
  EOT
  type        = list(string)
  default     = []
}

variable "database_settings" {
  description = "(Optional) Supported API for the databases in the account and a list of databases to provision. Allowed values of API type are Sql, Cassandra, MongoDB, Gremlin, Table. If 'use_autoscale' is set, 'throughput' becomes 'max_throughput' with a minimum value of 1000."
  type = object({
    api_type = string
    databases = list(object({
      name          = string
      throughput    = number
      use_autoscale = bool #If set, throughput will become max_throughput
    }))
  })
  default = {
    api_type  = "Sql"
    databases = []
  }
  validation {
    condition     = contains(["Sql", "Cassandra", "MongoDB", "Gremlin", "Table"], var.database_settings.api_type)
    error_message = "Valid values for database API type are (Sql, Cassandra, MongoDB, Gremlin and Table)."
  }
}

variable "database_throughput" {
  description = "(Optional) RU throughput value for the selected database."
  type        = number
  default     = 400
}

variable "enable_automatic_failover" {
  description = "(Optional) Enable automatic failover for this Cosmos DB account. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_automatic_failover))
    error_message = "Valid values are true, false."
  }
}

variable "enable_diagnostics" {
  description = "(Optional) Enable Cosmosdb diagnostic setting. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_diagnostics))
    error_message = "Valid values are true, false."
  }
}

variable "enable_multiple_write_locations" {
  description = "(Optional) Enable multiple write locations for this Cosmos DB account. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_multiple_write_locations))
    error_message = "Valid values are true, false."
  }
}

variable "enable_private_endpoint" {
  description = "(Optional) Private Endpoint requirement. Valid values are (true, false). "
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_private_endpoint))
    error_message = "Valid values are true, false."
  }
}

variable "enable_replication" {
  description = "(Optional) Enable replication of this Cosmos DB account to a secondary location. Valid values are (true, false)."
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_replication))
    error_message = "Valid values are true, false."
  }
}

variable "failover_location" {
  description = "(Optional) The name of the Azure region to host replicated data. Valid values are (eastus2, centralus)."
  type        = string
  default     = ""
  validation {
    condition     = contains(["", "eastus2", "centralus"], var.failover_location)
    error_message = "Valid values for failover_location are (eastus2 and centralus)."
  }
}

variable "failover_priority" {
  description = "(Optional) The failover priority of the region. A failover priority of 0 indicates a write region."
  type        = string
  default     = "0"
}

variable "index" {
  description = "(Optional) cosmosdb unique index (ex: 01,02...etc)"
  type        = string
  default     = "01"
}

variable "interval_in_minutes" {
  description = "(Optional) The interval in minutes between two backups. This is configurable only when type is Periodic. Possible values are between 60 and 1440."
  type        = number
  default     = 60
  validation {
    condition     = var.interval_in_minutes >= 60 && var.interval_in_minutes <= 1440 && floor(var.interval_in_minutes) == var.interval_in_minutes
    error_message = "Accepted values in between (minutes): 60 - 1440."
  }
}

variable "is_test_run" {
  description = "(Optional) Is this a test run? Defaults to false. Only set to true to use in a test harness to disable certain networking features."
  type        = bool
  default     = false
}

variable "kind" {
  description = "(Optional) Specifies the Kind of CosmosDB to create - possible values are 'GlobalDocumentDB' and 'MongoDB'."
  type        = string
  default     = "GlobalDocumentDB"
  validation {
    condition     = contains(["MongoDB", "GlobalDocumentDB"], var.kind)
    error_message = "Valid values for cosmosdb kind are (GlobalDocumentDB or MongoDB)."
  }
}

variable "local_authentication_disabled" {
  description = <<EOT
  (Optional) Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication.
  Defaults to false. Can be set only when using the SQL API.
  Valid values are (true, false).
  EOT
  type        = bool
  default     = false
  validation {
    condition     = can(regex("true|false", var.local_authentication_disabled))
    error_message = "Valid values are true, false."
  }
}

variable "max_interval_in_seconds" {
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day)."
  type        = string
  default     = "5"
}

variable "max_staleness_prefix" {
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647."
  type        = string
  default     = "10"
}

variable "pe_subnet_id_primary" {
  description = <<EOT
  (Optional) Private endpoint Subnet id, required when Private_Endpoint is enabled
  Subnet_ID usage: "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}"
  EOT
  default     = ""
}

variable "pe_subnet_id_secondary" {
  description = <<EOT
  (Optional) Private endpoint Subnet id, required when Private_Endpoint is enabled and replicating to a secondary region
  Subnet_ID usage: "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}"
  EOT
  default     = ""
}

variable "retention_days" {
  description = "(Optional) Cosmosdb retention daysl[Provide retention days if 'enable_diagnostics' is set to true]"
  default     = 7
}

variable "retention_in_hours" {
  description = "(Optional) The time in hours that each backup is retained. This is configurable only when type is Periodic. Possible values are between 8 and 720."
  type        = number
  default     = 8
  validation {
    condition     = var.retention_in_hours >= 8 && var.retention_in_hours <= 720 && floor(var.retention_in_hours) == var.retention_in_hours
    error_message = "Accepted values in between (hours): 8 - 720."
  }
}

variable "storage_redundancy" {
  description = "(Optional) The storage redundancy is used to indicate the type of backup residency. This is configurable only when type is Periodic. Possible values are Geo, Local and Zone."
  type        = string
  default     = "Local"
  validation {
    condition     = contains(["Geo", "Local", "Zone"], var.storage_redundancy)
    error_message = "Valid values for storage_redundancy are (Geo, Local and Zone)."
  }
}

variable "is_msdn_cosmosdb" {
  description = "Is this cosmos db to be used in an msdn subscription. Default is false."
  type        = bool
  default     = false
}

variable "dns_private_zone_rg" {
  type        = string
  description = "The resource group that the privatelink DNS zone record is in (Azure Private DNS)"
  default     = "dnsproxy-prd"
}

variable "is_virtual_network_filter_enabled" {
  description = "Is this cosmos db to be used in an msdn subscription. Default is false."
  type        = bool
  default     = true
}

variable "zone_redundant" {
  description = "(Optional) Should Zone Redundancy in the primary region be enabled?"
  type        = bool
  default     = false
}

variable "failover_zone_redundant" {
  description = "(Optional) Should Zone Redundancy in the failover region be enabled?"
  type        = bool
  default     = false
}

### ----
# Outputs
output "cosmosdb_id" {
  description = "ID of the deployed CosmosDB account"
  value       = azurerm_cosmosdb_account.db.id
}

output "cosmosdb_name" {
  description = "Name of the deployed CosmosDB account"
  value       = azurerm_cosmosdb_account.db.name
}

### locals
locals {
  cosmosdb_name = ""


}

------------------
module "cosmosdb_account" {
  source = "./modules/cosmosdb_account"

  location                         = "East US"
  resource_group_name              = "example-resource-group"
  cosmosdb_name                    = "example-cosmosdb"
  kind                             = "MongoDB"
  enable_private_endpoint          = false
  is_virtual_network_filter_enabled = false
  enable_automatic_failover        = true
  enable_multiple_write_locations = true
  key_vault_name                   = "example-keyvault"
  enable_systemassigned_identity   = true
  zone_redundant                   = true
  failover_location                = "West US"
  failover_zone_redundant          = false
  allowed_origins                  = ["https://example.com"]
  additional_subnet_ids            = []
  capabilities                     = ["EnableCassandra"]
  consistency_level                = "Session"
  max_interval_in_seconds          = 5
  max_staleness_prefix             = 10000
  backup_type                      = "Periodic"
  interval_in_minutes              = 30
  retention_in_hours               = 24
  storage_redundancy               = "GeoRedundant"
}




========================||========================
Gremlin API Example:
# Gremlin API Configuration Example

resource "azurerm_cosmosdb_gremlin_database" "gremlin_db" {
  name                = "gremlin-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_gremlin_graph" "gremlin_graph" {
  name                = "gremlin-graph"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_gremlin_database.gremlin_db.name

  index_policy {
    automatic      = true
    indexing_mode  = "consistent"
    included_paths = ["/*"]
    excluded_paths = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
--------------------------------------
Cassandra API Example
# Cassandra API Configuration Example

resource "azurerm_cosmosdb_cassandra_keyspace" "cassandra_keyspace" {
  name                = "cassandra-keyspace"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
}

resource "azurerm_cosmosdb_cassandra_table" "cassandra_table" {
  name                 = "cassandra-table"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  keyspace_name        = azurerm_cosmosdb_cassandra_keyspace.cassandra_keyspace.name

  schema {
    partition_key {
      name = "id"
    }

    clustering_key {
      name     = "timestamp"
      order_by = "ASC"
    }

    columns {
      name = "id"
      type = "uuid"
    }

    columns {
      name = "timestamp"
      type = "timestamp"
    }

    columns {
      name = "value"
      type = "text"
    }
  }

  throughput = 400
}
---------------------------------
SQL API Example
# SQL API Configuration Example

resource "azurerm_cosmosdb_sql_database" "sql_db" {
  name                = "sql-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_sql_container" "sql_container" {
  name                 = "sql-container"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  database_name        = azurerm_cosmosdb_sql_database.sql_db.name
  partition_key_path   = "/id"
  throughput           = 400

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
-------------------------------------------------
MongoDB API Example
# MongoDB API Configuration Example

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "mongo-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_mongo_collection" "mongo_collection" {
  name                 = "mongo-collection"
  resource_group_name  = var.resource_group_name
  account_name         = data.azurerm_cosmosdb_account.this.name
  database_name        = azurerm_cosmosdb_mongo_database.mongo_db.name
  partition_key_path   = "/_id"
  throughput           = 400

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}
---------------------------------------------
Table API Example
# Table API Configuration Example

resource "azurerm_cosmosdb_table" "table_db" {
  name                = "table-database"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = 400
  tags                = var.tags
}

resource "azurerm_cosmosdb_table_entity" "table_entity" {
  table_name          = azurerm_cosmosdb_table.table_db.name
  partition_key       = "partitionKey"
  row_key             = "rowKey"
  properties = {
    "property1" = "value1"
    "property2" = "value2"
  }
}
-----------------------------------------------
PostgreSQL API Example
# PostgreSQL API Configuration Example

resource "azurerm_cosmosdb_postgresql_cluster" "postgresql_cluster" {
  name                = "postgresql-cluster"
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  administrator_login = var.admin_login
  administrator_password = var.admin_password
  version             = "13"
  sku_name            = "GP_Gen5_2"
  storage_mb          = 5120
  backup_retention_days = 30
  geo_redundant_backup_enabled = true
  tags                = var.tags
}

resource "azurerm_cosmosdb_postgresql_database" "postgresql_db" {
  name                = "postgresql-database"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_postgresql_cluster.postgresql_cluster.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
  throughput          = 400
}

resource "azurerm_cosmosdb_postgresql_table" "postgresql_table" {
  name                = "postgresql-table"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_postgresql_cluster.postgresql_cluster.name
  database_name       = azurerm_cosmosdb_postgresql_database.postgresql_db.name
  schema              = "public"
  columns = [
    { name = "id", type = "SERIAL PRIMARY KEY" },
    { name = "name", type = "VARCHAR(100)" },
    { name = "created_at", type = "TIMESTAMP" }
  ]
  throughput           = 400
}




======================||==========================
========================||========================
# main.tf
---
resource "azurerm_cosmosdb_gremlin_database" "this" {
  name                = var.gremlin_database_name
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  throughput          = var.database_throughput

  tags = var.tags
}

resource "azurerm_cosmosdb_gremlin_graph" "this" {
  name                = var.gremlin_graph_name
  resource_group_name = var.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_gremlin_database.this.name

  index_policy {
    automatic      = true
    indexing_mode  = "consistent"
    included_paths = ["/*"]
    excluded_paths = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }

  tags = var.tags
}

module "rbac" {
  source = "app.terraform.io/xxxx/common/azure"

  for_each = var.role_assignments

  resource_id   = azurerm_cosmosdb_gremlin_graph.this.id
  resource_name = azurerm_cosmosdb_gremlin_graph.this.name

  role_based_permissions = {
    assignment = {
      role_definition_id_or_name = each.value.role_definition_id_or_name
      principal_id               = each.value.principal_id
    }
  }
  wait_for_rbac = false
}



---
  dynamic "autoscale_settings" {
    for_each = var.enable_autoscale ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }


###=======================================
# globals.tf
---
data "azurerm_client_config" "current" {}

data "azurerm_cosmosdb_account" "this" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name
}





###=======================================
# variables.tf
---
variable "gremlin_database_name" {
  description = "Name of the Gremlin database to create"
  type        = string
}

variable "gremlin_graph_name" {
  description = "Name of the Gremlin graph to create"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group the Cosmos DB account resides in"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "Name of the Cosmos DB account"
  type        = string
}

variable "database_throughput" {
  description = "Throughput for the Gremlin database (e.g., RU/s)"
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
DESCRIPTION
  nullable    = false
}

variable "terraform_module" {
  description = "Used to inform of a parent module"
  type        = string
  default     = ""
}




---
Updated variables.tf (Autoscale Throughput):

variable "enable_autoscale" {
  description = "Flag to enable autoscale throughput"
  type        = bool
  default     = false
}

variable "max_throughput" {
  description = "Maximum throughput for autoscale settings"
  type        = number
  default     = null
}





###=======================================
# outputs.tf
---
output "gremlin_database_id" {
  value       = azurerm_cosmosdb_gremlin_database.this.id
  description = "The ID of the Gremlin database"
}

output "gremlin_graph_id" {
  value       = azurerm_cosmosdb_gremlin_graph.this.id
  description = "The ID of the Gremlin graph"
}




---
### Output Additional Attributes: Include outputs for additional resource details, such as schema and throughput.
output "cassandra_keyspace_throughput" {
  value       = azurerm_cosmosdb_cassandra_keyspace.this.throughput
  description = "The throughput of the Cassandra keyspace"
}

output "cassandra_table_schema" {
  value       = azurerm_cosmosdb_cassandra_table.this.schema
  description = "The schema of the Cassandra table"
}




=====
### Validation Blocks: Add validation blocks for critical variables to prevent misconfigurations.

### Example for partition_key_name.:
variable "partition_key_name" {
  description = "The name of the partition key column"
  type        = string
  validation {
    condition     = contains(var.columns[*].name, var.partition_key_name)
    error_message = "Partition key name must match one of the defined column names."
  }
}



### Example for variable partition_key_name.: 
variable "partition_key_type" {
  description = "The data type of the partition key column (e.g., 'ascii', 'text', 'int')"
  type        = string
  validation {
    condition     = contains(["ascii", "text", "int", "uuid", "timestamp"], var.partition_key_type)
    error_message = "Partition key type must be a valid Cassandra type (e.g., 'ascii', 'text', 'int')."
  }
}




╵=============================||=================================================
The cosmosdb_cassandra_database module is designed specifically to create and manage Cosmos DB Cassandra API databases. This module adheres to the new design principles and integrates seamlessly with the foundational module cosmosdb_account_common, which serves as a flexible and reusable base for implementing Cosmos DB accounts for Cassandra and other API databases.

Key Features:
Simplifies the deployment and configuration of Cassandra API databases within a Cosmos DB account.
Leverages cosmosdb_account_common for centralized configurations, including consistency policies, geo-replication, network security, and tagging.
Promotes modularity, enabling independent scaling and management of Cassandra API databases.

Integration:
This module is designed to operate in conjunction with the cosmosdb_account_common foundational module. Ensure the foundational module is deployed and configured to establish consistent settings across all API databases while maintaining the flexibility to tailor Cassandra-specific requirements.

Planned updates include support for advanced features such as dynamic throughput scaling, enhanced diagnostic integration, and additional security configurations, aligned with improvements in the foundational module.

--------------------------------------------------
The cosmosdb_postgresql_database module is designed specifically to create and manage Cosmos DB PostgreSQL API databases. This module aligns with the new design approach and integrates seamlessly with the foundational module cosmosdb_account_common, which serves as a flexible and reusable base for implementing Cosmos DB accounts for PostgreSQL and other API databases.

Key Features:
Simplifies the deployment and management of PostgreSQL API databases within a Cosmos DB account.
Utilizes cosmosdb_account_common for shared configurations such as consistency policies, geo-replication, network security, and tagging.
Ensures modularity, enabling independent configuration and scaling of PostgreSQL API databases.

Integration:
This module is intended to work alongside the cosmosdb_account_common foundational module. Ensure the foundational module is deployed and properly configured to maintain consistent account-level settings while providing flexibility for PostgreSQL-specific database needs.

Future enhancements will include advanced features such as dynamic throughput scaling, enhanced diagnostic settings, and additional security measures, in line with updates to the foundational module.
========
artifact feeds also use this RBAC role permission but with different, and more, roles.

the scope value here determines what type of resource we are applying these permissions for
 

module "lb_backend_address_pool" {
  source   = "./modules/networking/lb_backend_address_pool"
  for_each = local.networking.lb_backend_address_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value


  remote_objects = {
    lb = local.combined_objects_lb
  }
}
output "lb_backend_address_pool" {
  value = module.lb_backend_address_pool
}

module "lb_backend_address_pool_address" {
  source   = "./modules/networking/lb_backend_address_pool_address"
  for_each = local.networking.lb_backend_address_pool_address

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    virtual_network         = local.combined_objects_networking
    lb_backend_address_pool = local.combined_objects_lb_backend_address_pool
  }
}
output "lb_backend_address_pool_address" {
  value = module.lb_backend_address_pool_address
}

module "lb_nat_pool" {
  source   = "./modules/networking/lb_nat_pool"
  for_each = local.networking.lb_nat_pool

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_nat_pool" {
  value = module.lb_nat_pool
}
module "lb_nat_rule" {
  source   = "./modules/networking/lb_nat_rule"
  for_each = local.networking.lb_nat_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_nat_rule" {
  value = module.lb_nat_rule
}

module "lb_outbound_rule" {
  source   = "./modules/networking/lb_outbound_rule"
  for_each = local.networking.lb_outbound_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  remote_objects = {
    resource_group          = local.combined_objects_resource_groups
    lb                      = local.combined_objects_lb
    lb_backend_address_pool = local.combined_objects_lb_backend_address_pool
  }
}
output "lb_outbound_rule" {
  value = module.lb_outbound_rule
}

module "lb_probe" {
  source   = "./modules/networking/lb_probe"
  for_each = local.networking.lb_probe

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_probe" {
  value = module.lb_probe
}
module "lb_rule" {
  source   = "./modules/networking/lb_rule"
  for_each = local.networking.lb_rule

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  backend_address_pool_ids = can(each.value.backend_address_pool_ids) || can(each.value.backend_address_pool) == false ? try(each.value.backend_address_pool_ids, null) : [
    for k, v in each.value.backend_address_pool : local.combined_objects_lb_backend_address_pool[try(v.lz_key, local.client_config.landingzone_key)][v.key].id
  ]
  probe_id = can(each.value.probe_id) || can(each.value.probe.key) == false ? try(each.value.probe_id, null) : local.combined_objects_lb_probe[try(each.value.probe.lz_key, local.client_config.landingzone_key)][each.value.probe.key].id

  remote_objects = {
    resource_group = local.combined_objects_resource_groups
    lb             = local.combined_objects_lb
  }
}
output "lb_rule" {
  value = module.lb_rule
}
