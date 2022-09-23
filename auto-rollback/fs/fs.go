package fs

import (
	"bufio"
	"log"
	"net/netip"
	"os"
)

func readFile(path string) []string {
	file, err := os.Open(path)
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
	return lines
}

func ReadHosts(path string) ([]netip.Addr, error) {
	lines := readFile(path)

	var addresses []netip.Addr
	for _, ip := range lines {
		addr, err := netip.ParseAddr(ip)
		if err != nil {
			log.Fatalln("Cannot parse IP address from hostfile")
			return nil, err
		} else {
			addresses = append(addresses, addr)
		}
	}

	return addresses, nil
}
