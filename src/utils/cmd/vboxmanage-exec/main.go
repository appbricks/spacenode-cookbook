package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"
	"time"

	"github.com/mevansam/goutils/logger"
	"github.com/mevansam/goutils/run"
	"github.com/mevansam/goutils/utils"

	. "appbricks.io/mycs-cookbook-utils/internal"
)

type output struct {
	Version        string `json:"version"`
	BuildTimestamp string `json:"buildTimestamp"`

	Msgs []string `json:"msgs"`
}

var options struct {
	shutdown bool
}

var (
	vboxmanage   run.CLI
	outputBuffer bytes.Buffer
)

func main() {

	var (
		err error

		jsonOutput []byte
	)

	logger.Initialize()

	flag.BoolVar(&options.shutdown, "shutdown", false, "Shutdown first before executing VBoxManage cli command.")
	flag.Parse()

	output := output{
		Version:        Version,
		BuildTimestamp: BuildTimestamp,
	}
	defer func() {
		if jsonOutput, err = json.Marshal(output); err != nil {
			log.Fatalf("Unable to generate JSON output for vboxmanage-exec: %s", err.Error())
		}
		fmt.Print(string(jsonOutput))
	}()

	if vboxmanage, _, err = run.CreateCLI("vboxmanage", &outputBuffer, &outputBuffer); err != nil {
		log.Fatalf("Unable to create CLI for 'vboxmanage': %s", err.Error())

	} else {
		args := flag.Args()

		if options.shutdown {
			shutdownVM(args[1])
		}

		err = vboxmanage.RunWithEnv(args, os.Environ())
		_ = os.WriteFile("vboxmanage.out", outputBuffer.Bytes(), 0644)
		if err != nil {
			log.Fatalf(
				"Error running '%s': %s\n\n%s",
				strings.Join(append([]string{"vboxmanage"}, args...), " "),
				err.Error(),
				outputBuffer.String(),
			)
		}
	}

	output.Msgs = strings.Split(strings.TrimSuffix(outputBuffer.String(), LineBreak), LineBreak)
}

func shutdownVM(name string) {
	defer outputBuffer.Reset()

	var (
		err error
	)

	getVMStatus := func() string {
		defer outputBuffer.Reset()
		if err = vboxmanage.Run([]string{ "showvminfo", name }); err == nil {
			results := utils.ExtractMatches(outputBuffer.Bytes(), map[string]*regexp.Regexp{
				"status": regexp.MustCompile(`^State:\s+(.*) \(.*\)$`),
			})
			if s := results["status"]; len(s) > 0 && len(s[0]) == 2 {
				return s[0][1]
			}
		}
		log.Fatalf("Failed to retrieve VM Status '%s':\n%s", name, outputBuffer.String())
		return ""
	}

	vmStatus := getVMStatus()
	if vmStatus != "powered off" && vmStatus != "aborted" {
		// send shutdown signal to vm
		if err = vboxmanage.Run([]string{ "controlvm", name, "acpipowerbutton" }); err != nil {
			log.Fatalf("Unable to shutdown VM '%s':\n%s", name, outputBuffer.String())
		}
		if !utils.InvokeWithTimeout(
			func() {
				for getVMStatus() != "powered off" {
					time.Sleep(time.Second)
				}
			},
			time.Second * 30,
		) {
			// force power off
			if err = vboxmanage.Run([]string{ "controlvm", name, "poweroff" }); err != nil {
				log.Fatalf("Unable to shutdown VM '%s':\n%s", name, outputBuffer.String())
			}
		}
	}
}