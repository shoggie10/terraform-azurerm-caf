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
==========||========================
Boards			
Work Items			Allows managing items relevant to project tasks.
Backlogs			Essential for prioritizing and planning tasks.
Sprints			Key for organizing iterations and deadlines.
Queries			Enables data retrieval and status tracking.
Delivery Plans			Critical for overseeing project timelines.
Analytics views			Provides insights into project metrics.
Portfolio plans (Beta)			High-level strategic planning and alignment.
			
Area			
Create child nodes			Enables detailed project structuring.
Delete this node			Necessary for maintaining a clean structure.
Edit this node			Allows updates to reflect current project states.
Edit work item comments in this node			Enables collaboration and communication on tasks.
Edit work items in this node			Critical for task updates and tracking.
Manage test plans			Important for overseeing testing strategies.
Manage test suites			Crucial for detailed test management.
View permissions for this node			Ensures proper access control and visibility.
View work items in this node			Allows monitoring of tasks and progress.
			
Iteration			
Create child nodes			Supports detailed iteration planning.
Delete this node			Helps in restructuring or cleaning up iterations.
Edit this node			Necessary for adapting iteration details.
View permissions for this node			Essential for managing access to iteration details.
			
Delivery Plans			
Delete			Allows high-level control over plan lifecycle.
Edit			Necessary for making timely adjustments.
Manage			Central to coordinating and overseeing plans.
View			Enables team-wide visibility and planning.
			
REPOS (Wiki Security)			
Bypass policies when completing pull requests			Allows critical changes to bypass standard checks.
Bypass policies when pushing			Enables urgent updates without usual restrictions.
Contribute			Fundamental for ongoing project contributions.
Contribute to pull requests			Supports collaborative code review and integration.
Create branch			Essential for version control.
Create repository			Critical for new project initialization.
Create tag			Useful for marking significant milestones.
Delete or disable repository			Important for managing repository lifecycle.
Edit policies			Crucial for setting governance on repository use.
Force push (rewrite history, delete branches and tags)			Allows rewriting history in critical scenarios.
Manage notes			Useful for documenting important decisions.
Manage permissions			Controls access to sensitive information.
Read			Basic access for team members to view contents.
Remove others' locks			Helps resolve access conflicts within the team.
Rename repository			Necessary for aligning repository names with project themes.
			
Bracnhes			
Bypass policies when completing pull requests			Allows critical changes to proceed without delays.
Bypass policies when pushing			Permits urgent updates to bypass standard controls.
Contribute			Essential for regular contributions to the codebase.
Edit policies			Vital for setting and adjusting branch governance.
Force push (rewrite history, delete branches and tags)			Grants ability to alter history in critical scenarios.
Manage permissions			Controls who can modify access settings for branches.
Remove others' locks			Facilitates resolution of access conflicts on branches.
			
			
PIPELINES			
Build Pipelines			
Administer build permissions			
Delete build pipeline			
Delete builds			
Destroy builds			
Edit build pipeline			
Edit build quality			
Edit queue build configuration			
Manage build qualities			
Manage build queue			
Override check-in validation by build			
Queue builds			
Retain indefinitely			
Stop builds			
Update build information			
View build pipeline			
View builds			
Release Pipelines			
Administer release permissions			
Create releases			
Delete release pipeline			
Delete release stage			
Delete releases			
Edit release pipeline			
Edit release stage			
Manage deployments			
Manage release approvers			
Manage releases			
View release pipeline			
View releases			
Environments			
Administrator			Full control over environment configurations.
Creator			Can create new environments within defined scope.
User			Access to use and interact within environments.
Reader			View-only access for oversight and reporting.
Library			
Administrator			Manages library settings and permissions.
Creator			Can add new resources to the library.
User			General access to use resources.
Reader			Read-only access to view library contents.
Task Groups			
Administer task group permissions			Controls who can modify task group permissions.
Delete task group			Necessary for managing lifecycle of task groups.
Edit task group			Allows modifications to adapt to project needs.
Deployment Groups			
Administrator			Manages overall settings and access control.
Creator			Can set up new deployment groups within scope.
User			General access for deployments and operations.
Reader			View-only access for oversight and monitoring.
Agent pool			
Administrator			Full control over agent configurations.
Creator			Can add new agents or modify existing setups.
User			Access to use agents for operations.
Reader			Read-only access for monitoring and reporting.
Service Connection			
Administrator			Oversees service connections and security.
Creator			Can establish new service connections.
User			Access to utilize service connections in operations.
Reader			View-only access to inspect service configurations.
			
			
			
Artifacts			
Read Artifacts			Basic access for team members to view artifacts.
Manage Artifacts			Required for publishing or managing lifecycle.
Promote Artifacts			Allows moving artifacts through various stages.
Test Plans			
View Test Plans			Essential for oversight on testing procedures.
Create Test Plans			Allows adding new test plans aligned with features.
Manage Test Plans			Necessary for maintaining or adjusting test plans.
Run Test Plans			Required for executing planned test cases.








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
