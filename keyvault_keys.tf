module "keyvault_keys" {
  depends_on = [module.keyvaults, module.keyvault_access_policies]

  source = "./modules/security/keyvault_key"

  for_each = local.security.keyvault_keys

  global_settings = local.global_settings
  settings        = each.value
  keyvaults       = local.combined_objects_keyvaults
  client_config   = local.client_config
}

#[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.keyvault_key].id
output "keyvault_keys" {
  value = module.keyvault_keys
}
===============||=========
List of Users in ADO: GET https://vssps.dev.azure.com/{organization}/_apis/graph/users?api-version=6.0-preview.1

GET https://vssps.dev.azure.com/{organization}/_apis/graph/users?api-version=6.0-preview.1
----
List of Projects in ADO: GET https://dev.azure.com/{organization}/_apis/projects?api-version=6.0
curl -u :<PAT> "https://dev.azure.com/{organization}/_apis/projects?api-version=6.0"
----
Azure CLI: az devops project list --organization https://dev.azure.com/{organization}

----
az devops user list --org $orgURL --query "members[].user.displayName" -o table


az devops user list --org $orgURL --query "members[].user.displayName" -o json |
  ConvertFrom-Json |
  Export-Csv -Path "users.csv" -NoTypeInformation


















================||=================
