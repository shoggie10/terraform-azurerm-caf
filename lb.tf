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

mock_provider "aws"{
    override_data {
      target = data.aws_region.current
      values = {
      name = "us-east-2"
    }
    }
}

variables {
  vpc_name = "vpc-abc123"
  tags = {
    environment         = "dev"
    application_id      = "0000"
    asset_class         = "standard"
    data_classification = "confidential"
    managed_by          = "it_cloud"
    requested_by        = "me@email.com"
    cost_center         = "1234"
    source_code         = "https://gitlab.com/company/test"
    deployed_by         = "test-workspace"
    application_role    = ""
  }
}

###################
#Testing variables#
###################

run "comment_failure_variable" {
    command = plan

    variables {
      comment = <<EOF
      The comment argument has a maximum length of 256 characters.
      Hence, this is a very long text to produce an intentional error.
      The comment argument has a maximum length of 256 characters.
      Hence, this is a very long text to produce an intentional error.
      EOF
    }

    expect_failures = [ var.comment ]  
}

run "vpc_name_failure_variable" {
    command = plan

    variables {
      vpc_name = "wrong-vpc-abc1234"
    }

    expect_failures = [ var.vpc_name ]  
}

run "zone_name_format_failure" {
    #You cannot include an asterisk in the leftmost label of a domain name
    command = plan

    variables {
      account_name = "*-is-not-valid" 
    }

    expect_failures = [ aws_route53_zone.this ]  
}

run "zone_name_length_failure" {
    #This is pretty much unlikely. But anyway, the test is created!!
    command = plan

    variables {
      account_name = <<EOF
      The_zone_name_argument_has_a_maximum_length_of_1024_characters_
      Hence_this_is_a_very_long_text_to_produce_an_intentional_error_
      EOF
    }

    expect_failures = [ aws_route53_zone.this ]  
}

######################
#Testing the resource#
######################

run "validate_aws_route53_zone_creation_with_defaults" {
    command = apply    

    assert {
        condition     = can(aws_route53_zone.this)
        error_message = "Route 53 Zone was not created successfully."
    }    
}

run "validate_aws_route53_zone_creation_arguments" {
    command = apply

    variables {
      account_name = "test-account-name"
      comment = "test comment"      
    }    

    assert {
        condition     = aws_route53_zone.this.name == local.zone_name
        error_message = "The zone name argument is not the expected."
    }

    assert {
        condition     = aws_route53_zone.this.comment == var.comment
        error_message = "The comment argument is not the expected."
    }

    assert {
        condition     = alltrue([
            for i in resource.aws_route53_zone.this.vpc :
            i.vpc_id == data.aws_vpc.this.id ])
        error_message = "The vpc_id argument is not the expected."
    }    
}

#################
#Testing outputs#
#################

run "validate_outputs" {
  command = apply

  variables {
      account_name = "test-account-name"
      comment = "test comment"      
    }

  assert {
        condition = length(output.id) > 0
        error_message = "Hosted Zone ID not found"
    }

  assert {
        condition = length(output.name) > 0
        error_message = "Hosted Zone name not found"
    }          
}


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


