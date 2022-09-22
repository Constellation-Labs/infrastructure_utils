package periodic

import (
	"log"
	"tessellation/config"
	"tessellation/http"
	"tessellation/rollback"
	"time"
)

func CheckL0(ticker *time.Ticker, rollbackInProgress *bool, prevOrdinal *uint64, config config.Config) {
	for range ticker.C {
		if *rollbackInProgress {
			log.Println("Rollback in progress. Skipping check.")
		} else {

			ordinal, err := http.FetchLatestOrdinal(config.BlockExplorerUrl)
			if err != nil {
				log.Println("Coundn't fetch latest ordinal:", err)
				return
			}

			if ordinal > *prevOrdinal {
				log.Println("Cluster healthy:", ordinal, ">", *prevOrdinal)
				*rollbackInProgress = false
				*prevOrdinal = ordinal
			} else {
				log.Println("Rollback needed:", ordinal, "<=", *prevOrdinal)
				*rollbackInProgress = true
				rollback.RestartL0(config.RollbackScriptPath)

				time.Sleep(time.Second * 10) // TODO: Remove?

				ready, err := http.FetchAreNodesReady(config.Ips)
				if err != nil {
					log.Fatalln("Couldn't check readiness of nodes:", err)
				}

				if ready {
					log.Println("Rollback succeeded")
					*prevOrdinal = 0
					*rollbackInProgress = false
				} else {
					log.Fatalln("Nodes are not Ready. Run rollback manually and restart auto-rollback script.")
				}
			}
		}
	}
}
