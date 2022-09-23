package periodic

import (
	"log"
	"net/netip"
	"tessellation/config"
	"tessellation/http"
	"tessellation/rollback"
	"time"
)

func CheckL1(ticker *time.Ticker, rollbackInProgress *bool, config config.Config) {

	var nodes []netip.AddrPort
	for _, addr := range config.Ips {
		addrPort := netip.AddrPortFrom(addr, config.L1Port)
		nodes = append(nodes, addrPort)
	}

	log.Println("[L1] Periodic check initialized")

	for range ticker.C {
		if *rollbackInProgress {
			log.Println("[L1] Rollback in progress. Skipping check.")
		} else {
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

				rollback.RestartL1Choosen(config.RollbackScriptPath, down)
				rollback.JoinL1Choosen(config.RollbackScriptPath, down, rejoinTarget)
			} else {
				log.Println("[L1] All the peers are down:", down, "-> Restarting L1 cluster.")
				rollback.RestartL1Initial(config.RollbackScriptPath)
			}

		}
	}
}
