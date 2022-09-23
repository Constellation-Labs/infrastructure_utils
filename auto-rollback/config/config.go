package config

import (
	"flag"
	"log"
	"net/netip"
	"strings"
	"tessellation/fs"
	"time"
)

var blockExplorerUrl *string = flag.String("block-explorer", "", "Url to block-explorer")
var rollbackScriptPath *string = flag.String("script", "./rollback", "Path to rollback script")
var hostsPath *string = flag.String("hosts", "./cluster-hosts", "Path to hosts file")
var interval *string = flag.String("interval", "3m", "Interval of checking block-explorer")
var l0Port *uint = flag.Uint("port", 9000, "L0 public port")
var l1Port *uint = flag.Uint("l1-port", 9010, "L1 public port")

type Config struct {
	BlockExplorerUrl   string
	RollbackScriptPath string
	HostsPath          string
	Interval           time.Duration
	L0Port             uint16
	L1Port             uint16
	Ips                []netip.Addr
}

func normalizeUrl(url string) string {
	if strings.HasSuffix(url, "/") {
		return url
	} else {
		return url + "/"
	}
}

func Load() Config {
	flag.Parse()
	ips, err := fs.ReadHosts(*hostsPath)
	if err != nil {
		log.Fatalln("Cannot read hosts:", err)
	}
	interval, err := time.ParseDuration(*interval)
	if err != nil {
		log.Fatalln("Cannot parse duration:", err)
	}

	return Config{
		BlockExplorerUrl:   normalizeUrl(*blockExplorerUrl),
		RollbackScriptPath: *rollbackScriptPath,
		HostsPath:          *hostsPath,
		Interval:           interval,
		L0Port:             uint16(*l0Port),
		L1Port:             uint16(*l1Port),
		Ips:                ips,
	}
}