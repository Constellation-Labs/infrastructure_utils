package main

import (
	"log"
	"os"
	"tessellation/config"
	"tessellation/periodic"
	"time"
)

var DidRollback = false
var L0CheckInProgress = false
var L1CheckInProgress = false

func main() {
	log.Println("Auto-Rollback")

	cfg := config.Load()
	log.Println("Config loaded")

	exit := make(chan string)
	ticker := time.NewTicker(cfg.Interval)

	for range ticker.C {
		catchError(func() {
			if L0CheckInProgress {
				log.Println("Skipping L0 Check because another one is already in progress.")
			} else {
				L0CheckInProgress = true
				DidRollback = periodic.CheckL0(cfg)
				L0CheckInProgress = false
			}
		})
		catchError(func() {
			if DidRollback {
				log.Println("Skipping L1 Check because L0 did a rollback.")
			} else if L1CheckInProgress {
				log.Println("Skipping L1 Check because another one is already in progress.")
			} else {
				L1CheckInProgress = true
				periodic.CheckL1(cfg)
				L1CheckInProgress = false
			}
		})

		DidRollback = false
	}

	for {
		select {
		case <-exit:
			os.Exit(0)
		}
	}
}

func catchError(f func()) {
	defer func() {
		recover()
		DidRollback = false
		L0CheckInProgress = false
		L1CheckInProgress = false
	}()

	f()
}
