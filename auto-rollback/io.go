package main

import (
	"bufio"
	"log"
	"net/netip"
	"os"
)

func readHosts(hostsPath string) []netip.AddrPort {
	file, err := os.Open(hostsPath)
	if err != nil {
		log.Fatalln("Cannot read hosts file")
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	if scanner.Err() != nil {
		log.Fatalln("Cannot read hosts file")
	}

	var addresses []netip.AddrPort
	for _, ip := range lines {
		addr, err := netip.ParseAddr(ip)
		if err != nil {
			log.Fatalln("Cannot parse IP address from hostfile")
		} else {
			addresses = append(addresses, netip.AddrPortFrom(addr, uint16(*port)))
		}
	}

	return addresses
}
