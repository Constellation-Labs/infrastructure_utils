package rollback

import (
	"bufio"
	"fmt"
	"log"
	"os/exec"
)

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

func RestartL0(scriptPath string) {
	runWithStdout(exec.Command(scriptPath, "restart"))
}
