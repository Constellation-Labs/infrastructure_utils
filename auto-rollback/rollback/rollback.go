package rollback

import (
	"bufio"
	"log"
	"net/netip"
	"os/exec"
	"strings"
	"time"
)

type JoinTarget struct {
	Id string
	Ip netip.Addr
}

type Service interface {
	Restart()
	RestartL1Initial()
	RestartL1Chosen(nodes []netip.AddrPort)
	JoinL1Chosen(nodes []netip.AddrPort, toNodeId string, toNodeIp netip.Addr)
	RejoinL1Chosen(nodes []netip.AddrPort, toNodeId string, toNodeIp netip.Addr)
}

type rollback struct {
	terminateAfter time.Duration
	scriptPath     string
}

func toTargets(nodes []netip.AddrPort) string {
	var targets []string
	for _, node := range nodes {
		targets = append(targets, node.Addr().String())
	}
	return strings.Join(targets, " ")
}

func GetService(scriptPath string, terminateAfter time.Duration) Service {
	return &rollback{
		scriptPath:     scriptPath,
		terminateAfter: terminateAfter,
	}
}

func (r rollback) runWithStdout(arg ...string) {
	cmd := exec.Command(r.scriptPath, arg...)
	cmdReader, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatalln("Error creating StdoutPipe for Cmd", err)
		return
	}

	scanner := bufio.NewScanner(cmdReader)
	go func() {
		for scanner.Scan() {
			log.Printf("\t%s\n", scanner.Text())
		}
	}()

	err = cmd.Start()
	if err != nil {
		log.Fatalln("Error starting Cmd: ", err)
	}

	timer := time.AfterFunc(r.terminateAfter, func() {
		cmd.Process.Kill()
	})

	err = cmd.Wait()
	if err != nil {
		log.Fatalln("Command timeout: ", r.scriptPath, arg, err)
	}
	timer.Stop()
}

func (r rollback) Restart() {
	r.runWithStdout("restart")
}

func (r rollback) RestartL1Initial() {
	r.runWithStdout("restartL1Initial")
}

func (r rollback) RestartL1Chosen(nodes []netip.AddrPort) {
	r.runWithStdout("restartL1Choosen", toTargets(nodes))
}

func (r rollback) JoinL1Chosen(nodes []netip.AddrPort, toNodeId string, toNodeIp netip.Addr) {
	r.runWithStdout("joinL1Choosen", toNodeId, toNodeIp.String(), toTargets(nodes))
}

func (r rollback) RejoinL1Chosen(nodes []netip.AddrPort, toNodeId string, toNodeIp netip.Addr) {
	r.RestartL1Chosen(nodes)
	r.JoinL1Chosen(nodes, toNodeId, toNodeIp)
}
