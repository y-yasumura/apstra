# Create Routing Zone
resource "apstra_datacenter_routing_zone" "vrf1" {
  name         = "vrf1"
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  vlan_id      = 5    # optional
  vni          = 10001
}


## Assign VNI to RZ
#resource "apstra_datacenter_resource_pool_allocation" "vrf1-vni" {
#  blueprint_id = apstra_datacenter_blueprint.dc1.id
#  role         = "evpn_l3_vnis"
#  pool_ids     = local.vni_pools.vxlan_vn_ids
#  routing_zone_id = apstra_datacenter_routing_zone.vrf1.id
#}

data "apstra_datacenter_systems" "leafs" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  filters = [
    {
      role        = "leaf"
      system_type = "switch"
    }
  ]
}

data "apstra_datacenter_virtual_network_binding_constructor" "vnet_bindng_constructor" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  switch_ids   = data.apstra_datacenter_systems.leafs.ids
}

## Create Virtual Network
resource "apstra_datacenter_virtual_network" "vn1" {
  name                         = "vn1"
  blueprint_id                 = apstra_datacenter_blueprint.dc1.id
  type                         = "vxlan"
  routing_zone_id              = apstra_datacenter_routing_zone.vrf1.id
  ipv4_connectivity_enabled    = true
  ipv4_virtual_gateway_enabled = true
  ipv4_virtual_gateway         = "192.168.10.1"
  ipv4_subnet                  = "192.168.10.0/24"
  bindings                     = data.apstra_datacenter_virtual_network_binding_constructor.vnet_bindng_constructor.bindings
}

## Assign VNI to VN
resource "apstra_datacenter_resource_pool_allocation" "vn1-vni" {
  for_each     = local.vni_pools
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  role         = "vni_virtual_network_ids"
  pool_ids     = each.value
}

## Assign LoopbackIP to VRF
resource "apstra_datacenter_resource_pool_allocation" "vrf1-lo" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  role         = "leaf_loopback_ips"
  pool_ids     = local.ipv4_pools.leaf_loopback_ips
  routing_zone_id = apstra_datacenter_routing_zone.vrf1.id
}

## Create CT for VN
data "apstra_datacenter_ct_virtual_network_single" "vn1" {
  vn_id  = apstra_datacenter_virtual_network.vn1.id
  name   = "ct-vn1"
  tagged = "true"
}

resource "apstra_datacenter_connectivity_template" "ct-vn1" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  name         = "ct-vn1"
  primitives = [
    data.apstra_datacenter_ct_virtual_network_single.vn1.primitive
  ]
}

## Assign Application Point to CT
data "apstra_datacenter_systems" "leaf3" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  filter = {
    label = "evpn_single_001_leaf1"
  }
}

data "apstra_datacenter_interfaces_by_system" "leaf3" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  system_id = one(data.apstra_datacenter_systems.leaf3.ids)
}

#output "test" {
#  value = data.apstra_datacenter_interfaces_by_system.leaf3.if_map["ge-0/0/2"]
#}

resource "apstra_datacenter_connectivity_template_assignment" "vn1_assign" {
  blueprint_id              = apstra_datacenter_blueprint.dc1.id
  application_point_id      = data.apstra_datacenter_interfaces_by_system.leaf3.if_map["ge-0/0/2"]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.ct-vn1.id
  ]
}

## Commit
#resource "apstra_blueprint_deployment" "deploy-vrf1" {
#  blueprint_id = apstra_datacenter_blueprint.dc1.id
#  depends_on = [
#    apstra_datacenter_routing_zone.vrf1,
#    #apstra_datacenter_resource_pool_allocation.vrf1-vni,
#    apstra_datacenter_virtual_network.vn1,
#    apstra_datacenter_resource_pool_allocation.vn1-vni,
#    apstra_datacenter_resource_pool_allocation.vrf1-lo
#  ]
#  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
#}