## Commit
resource "apstra_blueprint_deployment" "deploy" {
  blueprint_id = apstra_datacenter_blueprint.dc1.id
  depends_on = [
    # for underlay
    apstra_datacenter_device_allocation.interface_map_assignment,
    apstra_datacenter_resource_pool_allocation.asn,
    apstra_datacenter_resource_pool_allocation.link-ip,
    apstra_datacenter_resource_pool_allocation.spine-lo-ip,
    apstra_datacenter_resource_pool_allocation.leaf-lo-ip,

    # for vrf1
#    apstra_datacenter_routing_zone.vrf1,
#    #apstra_datacenter_resource_pool_allocation.vrf1-vni,
#    apstra_datacenter_virtual_network.vn1,
#    apstra_datacenter_resource_pool_allocation.vn1-vni,
#    apstra_datacenter_resource_pool_allocation.vrf1-lo
  ]
  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
}