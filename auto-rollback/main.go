package main

import (
	"log"
	"os"
	"tessellation/config"
	"tessellation/periodic"
	"time"
)

var PrevOrdinal = uint64(0)
var RollbackInProgress = false

func main() {
	log.Println("Auto-Rollback")

	cfg := config.Load()
	log.Println("Config loaded")

	exit := make(chan string)
	ticker := time.NewTicker(cfg.Interval)

	go periodic.CheckL0(ticker, &RollbackInProgress, &PrevOrdinal, cfg)

	for {
		select {
		case <-exit:
			os.Exit(0)
		}
	}
}
