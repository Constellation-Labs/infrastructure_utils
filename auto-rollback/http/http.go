package http

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"net/netip"
)

func ToUrl(ip netip.AddrPort) string {
	return "http://" + ip.String() + "/"
}

func FetchNodeHealth(ip netip.AddrPort) error {
	url := ToUrl(ip) + "node/health"
	resp, err := http.Get(url)

	if err != nil {
		return err
	} else if resp.StatusCode >= 400 {
		return errors.New("Node is not healthy: " + ip.String())
	} else {
		return nil
	}
}

func FetchNodeInfo(ip netip.AddrPort) (*NodeInfo, error) {
	resp, err := http.Get(ToUrl(ip) + "node/info")
	if err != nil {
		log.Println(err)
		return nil, err
	}
	if resp.StatusCode >= 400 {
		return nil, errors.New(resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	var result NodeInfo
	if err := json.Unmarshal(body, &result); err != nil {
		log.Println("Can not unmarshal GlobalSnapshot")
		return nil, err
	}
	return &result, nil
}

func FetchLatestOrdinal(blockExplorerUrl string) (uint64, error) {
	resp, err := http.Get(blockExplorerUrl + "global-snapshots/latest")
	if err != nil {
		log.Println(err)
		return 0, err
	}
	if resp.StatusCode >= 400 {
		return 0, errors.New(resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println(err)
		return 0, err
	}
	var result GlobalSnapshot
	if err := json.Unmarshal(body, &result); err != nil {
		log.Println("Can not unmarshal GlobalSnapshot")
		return 0, err
	}
	return result.Data.Ordinal, nil
}

func FetchClusterInfo(ip netip.AddrPort) (ClusterInfo, error) {
	resp, err := http.Get(ToUrl(ip) + "cluster/info")
	if err != nil {
		log.Println("err", err)
		return nil, err
	}

	if resp.StatusCode >= 400 {
		return nil, errors.New(resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	var result ClusterInfo
	if err := json.Unmarshal(body, &result); err != nil {
		log.Println("Can not unmarshal ClusterInfo")
		return nil, err
	}

	return result, nil
}
