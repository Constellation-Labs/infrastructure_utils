package http

import (
	"encoding/json"
	"net/netip"
)

type GlobalSnapshot struct {
	Data struct {
		Ordinal uint64 `json:"ordinal"`
	} `json:"data"`
}

type ClusterNodeInfo struct {
	State string `json:"state"`
	Ip    NodeIp `json:"ip"`
	Id    string `json:"id"`
}

type NodeIp struct {
	netip.Addr
}

func (t NodeIp) MarshalJSON() ([]byte, error) {
	return json.Marshal(t.Addr.String())
}

func (t *NodeIp) UnmarshalJSON(data []byte) error {
	var addr string
	if err := json.Unmarshal(data, &addr); err != nil {
		return err
	}
	parsed, err := netip.ParseAddr(addr)
	if err != nil {
		return err
	}
	t.Addr = parsed
	return nil
}

type ClusterInfo = []ClusterNodeInfo
