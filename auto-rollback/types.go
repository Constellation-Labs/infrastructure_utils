package main

type GlobalSnapshot struct {
	Data struct {
		Ordinal uint64 `json:"ordinal"`
	} `json:"data"`
}

type NodeInfo struct {
	State string `json:"state"`
	Ip    string `json:"ip"`
}

type ClusterInfo = []NodeInfo
