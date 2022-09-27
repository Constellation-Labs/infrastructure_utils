package main

import (
	"log"
	"os"
	"tessellation/check"
	"tessellation/config"
	"time"
)

func main() {
	log.Println("Auto-Rollback")

	cfg := config.Load()
	log.Println("Config loaded")

	exit := make(chan string)
	ticker := time.NewTicker(cfg.Interval)

	l0 := new(check.L0Checker).Init(cfg)
	l1 := new(check.L1Checker).Init(cfg)

	for range ticker.C {
		if l0.IsCheckInProgress {
			log.Println("[L0] Skipping check because another one is already in progress.")
		} else {
			l0.Check()
		}

		if l1.IsFirstRun {
			log.Println("[L1] Skipping first run.")
		} else if l0.DidRollback {
			log.Println("[L1] Skipping check because L0 did a rollback.")
		} else if l1.IsCheckInProgress {
			log.Println("[L1] Skipping check because another one is already in progress.")
		} else {
			l1.Check()
		}

		l1.PrepareForNextRun()
		l0.PrepareForNextRun()
	}

	for {
		select {
		case <-exit:
			os.Exit(0)
		}
	}
}
