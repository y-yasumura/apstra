asn_pools = {
  spine_asns = ["Private-64512-65534"]
  leaf_asns  = ["Private-64512-65534"]
}

ipv4_pools = {
  spine_loopback_ips  = ["Private-10_0_0_0-8"]
  leaf_loopback_ips   = ["Private-10_0_0_0-8"]
  spine_leaf_link_ips = ["Private-172_16_0_0-12"]
}

vni_pools = {
  evpn_l3_vnis  = ["Default-10000-20000"]
  vxlan_vn_ids  = ["Default-10000-20000"]
}

switches = {
  spine1 = {
    device_key = "52540077917B"
    initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
  }
  spine2 = {
    device_key = "525400E4714E"
    initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
  }
  evpn_esi_001_leaf1 = {
    device_key = "525400B64792"
    initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
  }
  evpn_esi_001_leaf2 = {
    device_key = "5254007CFC91"
    initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
  }
  evpn_single_001_leaf1 = {
    device_key = "52540057175E"
    initial_interface_map_id = "Juniper_vEX__slicer-7x10-1"
  }
}
