package l0

import (
	"errors"
	"fmt"
	"log"
	"net/netip"
	"tessellation/http"
	"tessellation/rollback"
	"tessellation/slack"
	"time"
)

type Checker interface {
	Check()
	DidRollback() bool
	FailedRollback() bool
}

type l0Checker struct {
	didRollback       bool
	failedRollback    bool
	isCheckInProgress bool
	PrevOrdinal       uint64
	ips               []netip.Addr
	port              uint16
	blockExplorerUrl  string
	rollbackService   rollback.Service
	slack             slack.Notifier
}

func GetService(rollbackService rollback.Service, slack slack.Notifier, port uint16, ips []netip.Addr, blockExplorerUrl string) Checker {
	return &l0Checker{
		didRollback:       false,
		failedRollback:    false,
		isCheckInProgress: false,
		PrevOrdinal:       uint64(0),
		port:              port,
		ips:               ips,
		blockExplorerUrl:  blockExplorerUrl,
		rollbackService:   rollbackService,
		slack:             slack,
	}
}

func (c *l0Checker) DidRollback() bool {
	return c.didRollback
}

func (c *l0Checker) FailedRollback() bool {
	return c.failedRollback
}

func (c *l0Checker) Check() {
	defer func() {
		if r := recover(); r != nil {
			c.didRollback = false
			c.isCheckInProgress = false
			c.failedRollback = true
			var err error
			switch x := r.(type) {
			case string:
				err = errors.New(x)
			case error:
				err = x
			default:
				err = errors.New("unknown error")
			}
			log.Println("L0 - Unhandled exception", err.Error())
			c.slack.NotifyException("L0 - Unhandled exception", err.Error())
		}
	}()

	if c.isCheckInProgress {
		log.Println("[L0] Skipping check because another one is already in progress.")
		return
	}

	c.failedRollback = false
	c.didRollback = false
	c.isCheckInProgress = true

	var nodes []netip.AddrPort
	for _, addr := range c.ips {
		addrPort := netip.AddrPortFrom(addr, c.port)
		nodes = append(nodes, addrPort)
	}

	ordinal, err := http.FetchLatestOrdinal(c.blockExplorerUrl)
	if err != nil {
		c.slack.NotifyException("L0 - Cluster check failed.", "Couldn't fetch the latest ordinal from block-explorer")
		log.Println("[L0] Couldn't fetch the latest ordinal from block-explorer:", err)
		return
	}

	if ordinal > c.PrevOrdinal {
		log.Println("[L0] OK")
		c.PrevOrdinal = ordinal
	} else {
		log.Println("[L0] Rollback needed:", ordinal, "<=", c.PrevOrdinal)
		c.slack.NotifyError("L0 - Triggered rollback.", fmt.Sprintln("The cluster is stuck at ordinal", ordinal))
		c.rollbackService.Restart()
		c.PrevOrdinal = 0
		c.slack.NotifySuccess("L0 - Rollback succeeded.", "")
		time.Sleep(time.Second * 10)
		c.didRollback = true
	}

	c.isCheckInProgress = false
}
