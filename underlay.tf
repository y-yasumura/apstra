terraform {
  required_providers {
    apstra = {
      source = "Juniper/apstra"
    }
  }
}
provider "apstra" {
  url                     = "https://admin:ReliableCow0%2B@13.38.52.89:21359"
  tls_validation_disabled = true
  blueprint_mutex_enabled = false
  api_timeout             = 0
  experimental            = true
}

locals {
  asn_pools = {
    spine_asns = ["Private-64512-65534"]
    leaf_asns  = ["Private-64512-65534"]
  }

  ipv4_pools = {
    spine_loopback_ips  = ["Private-10_0_0_0-8"]
    leaf_loopback_ips   = ["Private-10_0_0_0-8"]
    spine_leaf_link_ips = ["Private-172_16_0_0-12"]
    vrf_loopback_ips    = ["Private-10_0_0_0-8"]
  }

  vni_pools = {
    evpn_l3_vnis  = ["Default-10000-20000"]
    vxlan_vn_ids  = ["Default-10000-20000"]
  }

  switches = {
    spine1 = {
      device_key = "525400E9F348"
      initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
    }
    spine2 = {
      device_key = "525400C0328A"
      initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
    }
    evpn_esi_001_leaf1 = {
      device_key = "5254007460B8"
      initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
    }
    evpn_esi_001_leaf2 = {
      device_key = "525400F7346A"
      initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
    }
    evpn_single_001_leaf1 = {
      device_key = "52540015292E"
      initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
    }
  }
}

## Create Blueprint
resource "apstra_datacenter_blueprint" "dc1" {
  name        = "dc1"
  template_id = "evpn-vex-virtual"
}

## Assign ASN Pool
resource "apstra_datacenter_resource_pool_allocation" "asn" {
  for_each     = local.asn_pools
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  role         = each.key
  pool_ids     = each.value
}

## Assign LINK IP Pool
resource "apstra_datacenter_resource_pool_allocation" "link-ip" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  role         = "spine_leaf_link_ips"
  pool_ids     = local.ipv4_pools.spine_leaf_link_ips
}

## Assign Spine Loopback IP Pool
resource "apstra_datacenter_resource_pool_allocation" "spine-lo-ip" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  role         = "spine_loopback_ips"
  pool_ids     = local.ipv4_pools.spine_leaf_link_ips
}

## Assign Leaf Loopback IP Pool
resource "apstra_datacenter_resource_pool_allocation" "leaf-lo-ip" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  role         = "leaf_loopback_ips"
  pool_ids     = local.ipv4_pools.spine_leaf_link_ips
}

## Assign Interface Map $ System ID
resource "apstra_datacenter_device_allocation" "interface_map_assignment" {
  for_each                 = local.switches
  blueprint_id             = apstra_datacenter_blueprint.dc1.id
  node_name                = each.key
  initial_interface_map_id = each.value["initial_interface_map_id"]
  device_key               = each.value["device_key"]
  deploy_mode              = "deploy"
}

## Commit
#resource "apstra_blueprint_deployment" "deploy" {
#  blueprint_id = apstra_datacenter_blueprint.dc1.id
#  depends_on = [
#    apstra_datacenter_device_allocation.interface_map_assignment,
#    apstra_datacenter_resource_pool_allocation.asn,
#    apstra_datacenter_resource_pool_allocation.link-ip,
#    apstra_datacenter_resource_pool_allocation.spine-lo-ip,
#    apstra_datacenter_resource_pool_allocation.leaf-lo-ip
#  ]
#  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
#}