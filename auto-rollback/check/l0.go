package check

import (
	"log"
	"net/netip"
	"tessellation/config"
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

type L0Checker struct {
	DidRollback       bool
	IsCheckInProgress bool
	PrevOrdinal       uint64
	config            config.Config
}

func (c *L0Checker) Init(config config.Config) L0Checker {
	c.DidRollback = false
	c.IsCheckInProgress = false
	c.PrevOrdinal = uint64(0)
	c.config = config
	return *c
}

func (c *L0Checker) PrepareForNextRun() L0Checker {
	c.DidRollback = false
	return *c
}

func (c *L0Checker) Check() {
	defer func() {
		if r := recover(); r != nil {
			c.DidRollback = false
			c.IsCheckInProgress = false
			log.Println("Recovered from:", r)
		}
	}()

	c.IsCheckInProgress = true

	var nodes []netip.AddrPort
	for _, addr := range c.config.Ips {
		addrPort := netip.AddrPortFrom(addr, c.config.L0Port)
		nodes = append(nodes, addrPort)
	}

	ordinal, err := http.FetchLatestOrdinal(c.config.BlockExplorerUrl)
	if err != nil {
		log.Println("[L0] Couldn't fetch latest ordinal:", err)
		// TODO: Notify
		return
	}

	log.Println(ordinal, c.PrevOrdinal)

	if ordinal > c.PrevOrdinal {
		log.Println("[L0] OK")
		c.PrevOrdinal = ordinal
	} else {
		log.Println("[L0] Rollback needed:", ordinal, "<=", c.PrevOrdinal)
		// TODO: Notify
		rollback.Restart(c.config.RollbackScriptPath)

		time.Sleep(time.Second * 10)

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
			c.DidRollback = true
		} else {
			log.Panicln("[L0] Nodes are either Offline/Leaving or not present in the cluster. Run rollback manually and restart auto-rollback script.")
			// TODO: Notify
		}
	}

	c.IsCheckInProgress = false
}
