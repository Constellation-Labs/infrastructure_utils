package periodic

import (
	"net/netip"
	"tessellation/http"
)

type NodeCheckResult struct {
	Valid   []netip.AddrPort
	Invalid []netip.AddrPort
}

func NodeCheck(ips []netip.AddrPort, clusterInfo http.ClusterInfo) *NodeCheckResult {
	var valid []netip.AddrPort
	var invalid []netip.AddrPort

	for _, ip := range ips {
		for _, info := range clusterInfo {
			if info.Ip.String() == ip.Addr().String() {
				if info.State != "Leaving" && info.State != "Offline" {
					valid = append(valid, ip)
				} else {
					invalid = append(invalid, ip)
				}
			}
		}
	}

	return &NodeCheckResult{
		Valid:   valid,
		Invalid: invalid,
	}
}
