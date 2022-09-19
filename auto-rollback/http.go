package main

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"net/netip"
	"strings"
)

func fetchLatestOrdinal() (uint64, error) {
	var url string
	if strings.HasSuffix(*blockExplorerUrl, "/") {
		url = *blockExplorerUrl
	} else {
		url = *blockExplorerUrl + "/"
	}
	resp, err := http.Get(url + "global-snapshots/latest")
	if err != nil {
		log.Println(err)
		return 0, err
	}
	var result GlobalSnapshot
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		log.Println("Can not unmarshal JSON")
		return 0, err
	}
	return result.Data.Ordinal, nil
}

func fetchClusterInfo(ip netip.AddrPort) (ClusterInfo, error) {
	resp, err := http.Get("http://" + ip.String() + "/cluster/info")
	if err != nil {
		log.Println(err)
		return nil, err
	}

	var result ClusterInfo
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		log.Println("Can not unmarshal JSON")
		return nil, err
	}

	return result, nil
}

func fetchAreNodesReady() (bool, error) {
	genesis := ips[0]
	clusterInfo, err := fetchClusterInfo(genesis)
	if err != nil {
		return false, err
	}

	var nodeInfo []NodeInfo

	for _, ip := range ips {
		for _, node := range clusterInfo {
			if node.Ip == ip.Addr().String() {
				nodeInfo = append(nodeInfo, node)
			}
		}
	}

	if len(nodeInfo) != len(ips) {
		return false, errors.New("Couldn't find all the targets in cluster/info of genesis node")
	}

	foundReadyPeer := false
	for _, node := range nodeInfo {
		if node.State == "Ready" {
			foundReadyPeer = true
			break
		}
	}

	if foundReadyPeer {
		return true, nil
	}

	return false, errors.New("None of targets is in Ready state")

}
