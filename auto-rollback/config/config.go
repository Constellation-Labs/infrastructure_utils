package config

import (
	"flag"
	"log"
	"net/netip"
	"tessellation/fs"
	"time"
)

var blockExplorerUrl *string = flag.String("block-explorer", "", "Url to block-explorer")
var rollbackScriptPath *string = flag.String("script", "./rollback", "Path to rollback script")
var hostsPath *string = flag.String("hosts", "./cluster-hosts", "Path to hosts file")
var interval *string = flag.String("interval", "3m", "Interval of checking block-explorer")
var port *uint = flag.Uint("port", 9000, "Target port")

type Config struct {
	BlockExplorerUrl   string
	RollbackScriptPath string
	HostsPath          string
	Interval           time.Duration
	Port               uint16
	Ips                []netip.AddrPort
}

func Load() Config {
	flag.Parse()
	ips, err := fs.ReadHosts(*hostsPath, uint16(*port))
	if err != nil {
		log.Fatalln("Cannot read hosts:", err)
	}
	interval, err := time.ParseDuration(*interval)
	if err != nil {
		log.Fatalln("Cannot parse duration:", err)
	}

	return Config{
		BlockExplorerUrl:   *blockExplorerUrl,
		RollbackScriptPath: *rollbackScriptPath,
		HostsPath:          *hostsPath,
		Interval:           interval,
		Port:               uint16(*port),
		Ips:                ips,
	}
}
