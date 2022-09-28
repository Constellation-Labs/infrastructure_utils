package l1

import (
	"errors"
	"fmt"
	"log"
	"net/netip"
	"tessellation/http"
	"tessellation/rollback"
	"tessellation/slack"
)

type l1Checker struct {
	isCheckInProgress bool
	isFirstRun        bool
	ips               []netip.Addr
	port              uint16
	rollbackService   rollback.Service
	slack             slack.Notifier
}

type Checker interface {
	Check()
}

func GetService(rollbackService rollback.Service, slack slack.Notifier, port uint16, ips []netip.Addr) Checker {
	return &l1Checker{
		isFirstRun:        true,
		isCheckInProgress: false,
		ips:               ips,
		port:              port,
		rollbackService:   rollbackService,
		slack:             slack,
	}
}

func (c *l1Checker) Check() {
	defer func() {
		if r := recover(); r != nil {
			c.isCheckInProgress = false
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

	if c.isFirstRun {
		log.Println("[L1] Skipping first run.")
		c.isFirstRun = false
		return
	}

	if c.isCheckInProgress {
		log.Println("[L1] Skipping check because another one is already in progress.")
		return
	}

	c.isCheckInProgress = true

	var nodes []netip.AddrPort
	for _, addr := range c.ips {
		addrPort := netip.AddrPortFrom(addr, c.port)
		nodes = append(nodes, addrPort)
	}

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
		rejoinTarget := inCluster[0]

		log.Println("[L1] Some peers are not responsive:", down, "-> Restarting and rejoining them to", rejoinTarget)
		c.slack.NotifyError("L1 - Rejoining unresponsive nodes", fmt.Sprintln(down, "->", rejoinTarget))

		rejoinTargetInfo, err := http.FetchNodeInfo(rejoinTarget)
		if err != nil {
			c.slack.NotifyException("L1 - Rejoining nodes failed", fmt.Sprintln(down, "->", rejoinTarget))
			log.Println("[L1] Couldn't fetch node/info from rejoin target peer", err)
		}

		c.rollbackService.RejoinL1Chosen(down, rejoinTargetInfo.Id, rejoinTargetInfo.Host.Addr)
		c.slack.NotifySuccess("L1 - Rejoining nodes succeeded", fmt.Sprintln(down, "->", rejoinTarget))
	} else {
		log.Println("[L1] All the peers are down:", down, "-> Restarting L1 cluster.")
		c.slack.NotifyError("L1 - Restarting and rejoining all the nodes", "")
		c.rollbackService.RestartL1Initial()
		c.slack.NotifySuccess("L1 - Restarting and rejoining all the nodes succeeded", "")
	}

	c.isCheckInProgress = false
}
