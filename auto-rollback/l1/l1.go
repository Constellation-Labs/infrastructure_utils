package l1

import (
	"log"
	"net/netip"
	"tessellation/http"
	"tessellation/rollback"
)

type l1Checker struct {
	isCheckInProgress bool
	isFirstRun        bool
	ips               []netip.Addr
	port              uint16
	rollbackService   rollback.Service
}

type Checker interface {
	Check()
}

func GetService(rollbackService rollback.Service, port uint16, ips []netip.Addr) Checker {
	return &l1Checker{
		isFirstRun:        true,
		isCheckInProgress: false,
		ips:               ips,
		port:              port,
		rollbackService:   rollbackService,
	}
}

func (c *l1Checker) Check() {
	defer func() {
		if r := recover(); r != nil {
			c.isCheckInProgress = false
			log.Println("Recovered from:", r)
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

		log.Println("[L1] Some peers are not responsive:", down, "-> Restaring and rejoining them to", rejoinTarget)

		rejoinTargetInfo, err := http.FetchNodeInfo(rejoinTarget)
		if err != nil {
			log.Panicln("[L1] Couldn't fetch node/info from rejoin target peer")
		}

		c.rollbackService.RejoinL1Chosen(down, rejoinTargetInfo.Id, rejoinTargetInfo.Host.Addr)
	} else {
		log.Println("[L1] All the peers are down:", down, "-> Restarting L1 cluster.")
		c.rollbackService.RestartL1Initial()
	}

	c.isCheckInProgress = false
}
