package rollback

import (
	"bufio"
	"fmt"
	"log"
	"net/netip"
	"os/exec"
	"strings"
)

type JoinTarget struct {
	Id string
	Ip netip.Addr
}

func runWithStdout(cmd *exec.Cmd) {
	cmdReader, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatalln("Error creating StdoutPipe for Cmd", err)
		return
	}

	scanner := bufio.NewScanner(cmdReader)
	go func() {
		for scanner.Scan() {
			fmt.Printf("\t%s\n", scanner.Text())
		}
	}()

	err = cmd.Start()
	if err != nil {
		log.Fatalln("Error starting Cmd: ", err)
		return
	}

	err = cmd.Wait()
	if err != nil {
		log.Fatalln("Error waiting for Cmd: ", err)
		return
	}
}

func toTargets(nodes []netip.AddrPort) string {
	var targets []string
	for _, node := range nodes {
		targets = append(targets, node.Addr().String())
	}
	return "\"" + strings.Join(targets, " ") + "\""
}

func Restart(scriptPath string, hostsPath string) {
	runWithStdout(exec.Command(scriptPath, "restart"))
}

func RestartL1Initial(scriptPath string) {
	runWithStdout(exec.Command(scriptPath, "restartL1Initial"))
}

func RestartL1Choosen(scriptPath string, nodes []netip.AddrPort) {
	runWithStdout(exec.Command(scriptPath, "restartL1Choosen", toTargets(nodes)))
}

func JoinL1Choosen(scriptPath string, nodes []netip.AddrPort, toNode JoinTarget) {
	runWithStdout(exec.Command(scriptPath, "joinL1Choosen", toNode.Ip.String(), toNode.Id, toTargets(nodes)))
}
