package check

import (
	"log"
	"net/netip"
	"tessellation/config"
	"tessellation/http"
	"tessellation/rollback"
)

type L1Checker struct {
	IsCheckInProgress bool
	IsFirstRun        bool
	config            config.Config
}

func (c *L1Checker) Init(config config.Config) L1Checker {
	c.IsCheckInProgress = false
	c.IsFirstRun = true
	c.config = config
	return *c
}

func (c *L1Checker) PrepareForNextRun() L1Checker {
	c.IsFirstRun = false
	return *c
}

func (c *L1Checker) Check() {
	defer func() {
		if r := recover(); r != nil {
			c.IsCheckInProgress = false
			log.Println("Recovered from:", r)
		}
	}()

	c.IsCheckInProgress = true

	var nodes []netip.AddrPort
	for _, addr := range c.config.Ips {
		addrPort := netip.AddrPortFrom(addr, c.config.L1Port)
		nodes = append(nodes, addrPort)
	}

	var inCluster []netip.AddrPort
	var down []netip.AddrPort

	for _, node := range nodes {
		err := http.FetchNodeHealth(node)
		if err != nil {
			down = append(down, node)
		} else {
			inCluster = append(inCluster, node)
		}
	}

	if len(down) == 0 {
		log.Println("[L1] OK")
	} else if len(down) < len(nodes) {
		peerInCluster := inCluster[0]

		log.Println("[L1] Some peers are not responsive:", down, "-> Restaring and rejoining them to", peerInCluster)

		clusterInfo, err := http.FetchClusterInfo(peerInCluster)
		if err != nil {
			log.Panicln("[L1] Couldn't fetch cluster/info from ready peer")
		}

		// TODO: Use node/info when 'id` is available there`
		var rejoinTarget rollback.JoinTarget
		for _, info := range clusterInfo {
			if info.Ip.Addr.String() == peerInCluster.Addr().String() {
				rejoinTarget = rollback.JoinTarget{
					Ip: info.Ip.Addr,
					Id: info.Id,
				}
			}
		}

		rollback.RestartL1Choosen(c.config.RollbackScriptPath, down)
		rollback.JoinL1Choosen(c.config.RollbackScriptPath, down, rejoinTarget)
	} else {
		log.Println("[L1] All the peers are down:", down, "-> Restarting L1 cluster.")
		rollback.RestartL1Initial(c.config.RollbackScriptPath)
	}

	c.IsCheckInProgress = true
}
