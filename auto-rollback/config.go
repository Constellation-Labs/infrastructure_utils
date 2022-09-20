package main

import (
	"flag"
	"log"
	"net/netip"
)

var blockExplorerUrl *string = flag.String("block-explorer", "", "Url to block-explorer")
var rollbackScriptPath *string = flag.String("script", "./rollback", "Path to rollback script")
var hostsPath *string = flag.String("hosts", "./cluster-hosts", "Path to hosts file")
var intervalInSeconds *string = flag.String("interval", "3m", "Interval of checking block-explorer")
var port *uint = flag.Uint("port", 9000, "Target port")
var ips []netip.AddrPort

func loadConfig() {
	flag.Parse()
	ips = readHosts(*hostsPath)
	log.Println("Config loaded")
}
