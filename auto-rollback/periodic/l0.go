package periodic

import (
	"log"
	"net/netip"
	"tessellation/config"
	"tessellation/http"
	"tessellation/rollback"
	"time"
)

func CheckL0(ticker *time.Ticker, rollbackInProgress *bool, config config.Config) {
	var prevOrdinal = uint64(0)

	var nodes []netip.AddrPort
	for _, addr := range config.Ips {
		addrPort := netip.AddrPortFrom(addr, config.L0Port)
		nodes = append(nodes, addrPort)
	}

	log.Println("[L0] Periodic check initialized")

	for range ticker.C {
		if *rollbackInProgress {
			log.Println("[L0] Rollback in progress. Skipping check.")
		} else {
			ordinal, err := http.FetchLatestOrdinal(config.BlockExplorerUrl)
			if err != nil {
				log.Println("[L0] Coundn't fetch latest ordinal:", err)
				return
			}

			if ordinal > prevOrdinal {
				log.Println("[L0] OK")
				*rollbackInProgress = false
				prevOrdinal = ordinal
			} else {
				log.Println("[L0] Rollback needed:", ordinal, "<=", prevOrdinal)
				*rollbackInProgress = true
				rollback.Restart(config.RollbackScriptPath, config.HostsPath)

				time.Sleep(time.Second * 10) // TODO: Remove?

				nodeToCheck := nodes[0]
				clusterInfo, err := http.FetchClusterInfo(nodeToCheck)
				if err != nil {
					log.Panicln("[L0] Couldn't fetch cluster/info from", nodeToCheck.String(), err)
				}

				nodeCheckResult := NodeCheck(nodes, clusterInfo)

				if len(nodeCheckResult.Invalid) == 0 {
					log.Println("[L0] Rollback succeeded")
					prevOrdinal = 0
					time.Sleep(time.Second * 10)
					*rollbackInProgress = false
				} else {
					*rollbackInProgress = false
					log.Panicln("[L0] Nodes are either Offline/Leaving or not present in the cluster. Run rollback manually and restart auto-rollback script.")
				}
			}
		}
	}
}
