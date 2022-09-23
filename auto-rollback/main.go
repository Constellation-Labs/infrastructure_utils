package main

import (
	"log"
	"os"
	"tessellation/config"
	"tessellation/periodic"
	"time"
)

var RollbackInProgress = false

func main() {
	log.Println("Auto-Rollback")

	cfg := config.Load()
	log.Println("Config loaded")

	exit := make(chan string)
	ticker := time.NewTicker(cfg.Interval)

	go catchError(func() {
		periodic.CheckL0(ticker, &RollbackInProgress, cfg)
	})
	go catchError(func() {
		periodic.CheckL1(ticker, &RollbackInProgress, cfg)
	})

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
	}()

	f()
}
