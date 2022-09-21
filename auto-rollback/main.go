package main

import (
	"log"
	"os"
	"os/exec"
	"time"
)

func rollback(scriptPath string) {
	cmd, err := exec.Command(scriptPath, "restart").Output()
	log.Println(string(cmd))
	if err != nil {
		log.Fatalln("Error while executing rollback script", err)
	}
}

func getTicker() *time.Ticker {
	interval, err := time.ParseDuration(*intervalInSeconds)
	if err != nil {
		log.Fatalln("Cannot parse duration.")
	}
	return time.NewTicker(interval)
}

func main() {
	log.Println("Auto-Rollback")
	loadConfig()

	prevOrdinal := uint64(0)
	rollbackInProgress := false

	exit := make(chan string)

	for range getTicker().C {
		if rollbackInProgress {
			log.Println("Rollback in progress. Skipping check.")
		} else {

			ordinal, err := fetchLatestOrdinal()
			if err != nil {
				log.Println("Coundn't fetch latest ordinal: %s", err)
				return
			}

			if ordinal > prevOrdinal {
				log.Println("Cluster healthy:", ordinal, ">", prevOrdinal)
				rollbackInProgress = false
				prevOrdinal = ordinal
			} else {
				log.Println("Rollback needed:", ordinal, "<=", prevOrdinal)
				rollbackInProgress = true
				rollback(*rollbackScriptPath)

				time.Sleep(time.Second * 10) // TODO: Remove?

				ready, err := fetchAreNodesReady()
				if err != nil {
					log.Fatalln("Couldn't check readiness of nodes: %s", err)
				}

				if ready {
					log.Println("Rollback succeeded")
					prevOrdinal = 0
					rollbackInProgress = false
				} else {
					log.Fatalln("Nodes are not Ready. Run rollback manually and restart auto-rollback script.")
				}
			}
		}
	}

	for {
		select {
		case <-exit:
			os.Exit(0)
		}
	}
}
