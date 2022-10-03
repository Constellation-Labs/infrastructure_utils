package main

import (
	"log"
	"tessellation/config"
	"tessellation/l0"
	"tessellation/l1"
	"tessellation/rollback"
	"tessellation/slack"
	"time"
)

func main() {
	log.Println("Auto-Rollback")

	cfg := config.Load()
	log.Println("Config loaded")

	ticker := time.NewTicker(cfg.Interval)

	rollbackService := rollback.GetService(cfg.RollbackScriptPath, cfg.CommandTimeout)
	slack := slack.GetService(cfg.SlackWebhookUrl)
	l0Service := l0.GetService(rollbackService, slack, cfg.L0Port, cfg.Ips, cfg.BlockExplorerUrl)
	l1Service := l1.GetService(rollbackService, slack, cfg.L1Port, cfg.Ips)

	for range ticker.C {
		l0Service.Check()

		if l0Service.DidRollback() {
			log.Println("[L1] Skipping check because L0 did a rollback.")
		} else if l0Service.FailedRollback() {
			log.Println("[L1] Skipping check because L0 rollback failed.")
		} else {
			l1Service.Check()
		}
	}
}
