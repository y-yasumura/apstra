terraform {
  backend "remote" {
  ## The name of your Terraform Cloud organization.
    organization = "apstra"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "apstra"
    }
  }
}


## Create Blueprint
resource "apstra_datacenter_blueprint" "instantiation" {
  name        = "dc1"
  template_id = "evpn-vex-virtual"
}

## Assign ASN Pool
resource "apstra_datacenter_resource_pool_allocation" "asn" {
  for_each     = var.asn_pools
  blueprint_id = apstra_datacenter_blueprint.instantiation.id
  role         = each.key
  pool_ids     = each.value
}

## Assign IP Pool
resource "apstra_datacenter_resource_pool_allocation" "ipv4" {
  for_each     = var.ipv4_pools
  blueprint_id = apstra_datacenter_blueprint.instantiation.id
  role         = each.key
  pool_ids     = each.value
}

## Assign Interface Map $ System ID
resource "apstra_datacenter_device_allocation" "interface_map_assignment" {
  for_each                 = var.switches
  blueprint_id             = apstra_datacenter_blueprint.instantiation.id
  node_name                = each.key
  initial_interface_map_id = each.value["initial_interface_map_id"]
  device_key               = each.value["device_key"]
  deploy_mode              = "deploy"
}

## Commit
resource "apstra_blueprint_deployment" "deploy" {
  blueprint_id = apstra_datacenter_blueprint.instantiation.id
  depends_on = [
    apstra_datacenter_device_allocation.interface_map_assignment,
    apstra_datacenter_resource_pool_allocation.asn,
    apstra_datacenter_resource_pool_allocation.ipv4,
  ]
  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
}
