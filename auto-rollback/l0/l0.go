package l0

import (
	"log"
	"net/netip"
	"tessellation/http"
	"tessellation/rollback"
	"time"
)

type NodeCheckResult struct {
	Valid   []netip.AddrPort
	Invalid []netip.AddrPort
}

func verifyNodeStates(ips []netip.AddrPort, clusterInfo http.ClusterInfo) *NodeCheckResult {
	var valid []netip.AddrPort
	var invalid []netip.AddrPort

	for _, ip := range ips {
		for _, info := range clusterInfo {
			if info.Ip.String() == ip.Addr().String() {
				if info.State != "Leaving" && info.State != "Offline" {
					valid = append(valid, ip)
				} else {
					invalid = append(invalid, ip)
				}
			}
		}
	}

	return &NodeCheckResult{
		Valid:   valid,
		Invalid: invalid,
	}
}

type Checker interface {
	Check()
	DidRollback() bool
}

type l0Checker struct {
	didRollback       bool
	isCheckInProgress bool
	PrevOrdinal       uint64
	ips               []netip.Addr
	port              uint16
	blockExplorerUrl  string
	rollbackService   rollback.Service
}

func GetService(rollbackService rollback.Service, port uint16, ips []netip.Addr, blockExplorerUrl string) Checker {
	return &l0Checker{
		didRollback:       false,
		isCheckInProgress: false,
		PrevOrdinal:       uint64(0),
		port:              port,
		ips:               ips,
		blockExplorerUrl:  blockExplorerUrl,
		rollbackService:   rollbackService,
	}
}

func (c *l0Checker) DidRollback() bool {
	return c.didRollback
}

func (c *l0Checker) Check() {
	defer func() {
		if r := recover(); r != nil {
			c.didRollback = false
			c.isCheckInProgress = false
			log.Println("Recovered from:", r)
		}
	}()

	if c.isCheckInProgress {
		log.Println("[L0] Skipping check because another one is already in progress.")
		return
	}

	c.didRollback = false
	c.isCheckInProgress = true

	var nodes []netip.AddrPort
	for _, addr := range c.ips {
		addrPort := netip.AddrPortFrom(addr, c.port)
		nodes = append(nodes, addrPort)
	}

	ordinal, err := http.FetchLatestOrdinal(c.blockExplorerUrl)
	if err != nil {
		log.Println("[L0] Couldn't fetch latest ordinal:", err)
		// TODO: Notify
		return
	}

	if ordinal > c.PrevOrdinal {
		log.Println("[L0] OK")
		c.PrevOrdinal = ordinal
	} else {
		log.Println("[L0] Rollback needed:", ordinal, "<=", c.PrevOrdinal)
		// TODO: Notify
		c.rollbackService.Restart()

		nodeToCheck := nodes[0]
		clusterInfo, err := http.FetchClusterInfo(nodeToCheck)
		if err != nil {
			log.Panicln("[L0] Couldn't fetch cluster/info from", nodeToCheck.String(), err)
		}

		nodeCheckResult := verifyNodeStates(nodes, clusterInfo)

		if len(nodeCheckResult.Invalid) == 0 {
			log.Println("[L0] Rollback succeeded")
			c.PrevOrdinal = 0
			time.Sleep(time.Second * 10)
			c.didRollback = true
		} else {
			log.Panicln("[L0] Nodes are either Offline/Leaving or not present in the cluster. Run rollback manually and restart auto-rollback script.")
			// TODO: Notify
		}
	}

	c.isCheckInProgress = false
}
