package main

import (
	"bytes"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/mevansam/goutils/run"

	. "appbricks.io/mycs-cookbook-utils/internal"
)

type output struct {
	Version        string `json:"version"`
	BuildTimestamp string `json:"buildTimestamp"`

	VMInfo string `json:"vminfo"`

	Msgs []string `json:"msgs"`
}

var options struct {
	infofile string
	timeout  int
}

func main() {

	var (
		err error

		vagrant      run.CLI
		outputBuffer bytes.Buffer

		jsonOutput []byte
	)

	flag.StringVar(&options.infofile, "info", "", "File containing additional information regarding the deployed vagrant instance.")
	flag.IntVar(&options.timeout, "timeout", 0, "Timeout in seconds to wait for the result file to be available.")
	flag.Parse()

	output := output{
		Version:        Version,
		BuildTimestamp: BuildTimestamp,
	}
	defer func() {
		if jsonOutput, err = json.Marshal(output); err != nil {
			log.Fatalf("Unable to generate JSON output for vagrant-exec: %s", err.Error())
		}
		fmt.Print(string(jsonOutput))
	}()

	if len(options.infofile) > 0 {
		_ = os.Remove(options.infofile)
	}

	if vagrant, err = CreateCLI("vagrant", &outputBuffer, &outputBuffer); err != nil {
		log.Fatalf("Unable to create CLI for 'vagrant': %s", err.Error())

	} else {
		args := flag.Args()
		if err = vagrant.RunWithEnv(args, os.Environ()); err != nil {
			log.Fatalf(
				"Error running '%s': %s\n\n%s",
				strings.Join(append([]string{"vagrant"}, args...), " "),
				err.Error(),
				outputBuffer.String(),
			)

		} else {
			_ = os.WriteFile("vagrant.out", outputBuffer.Bytes(), 0644)
			if len(options.infofile) > 0 {
				if output.VMInfo, err = readVMInfo(); err != nil {
					log.Fatalf("Error reading VM info file': %s", err.Error())
				}
			}
		}
	}

	output.Msgs = strings.Split(strings.TrimSuffix(outputBuffer.String(), "\n"), "\n")
}

func readVMInfo() (string, error) {

	var (
		err error

		data []byte
	)

	// trap interrupt
	quit := make(chan os.Signal, 1)
	signal.Reset(os.Interrupt, syscall.SIGTERM)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	signal.Ignore(syscall.SIGPIPE)

	ctx, cancel := context.WithDeadline(
		context.Background(),
		time.Now().Add(time.Duration(options.timeout)*time.Second),
	)
	defer cancel()

	result := make(chan error)
	go func() {
		for {
			if _, err1 := os.Stat(options.infofile); err1 != nil {
				if os.IsNotExist(err1) {
					select {
					case <-quit:
						result <- fmt.Errorf("Interrupt received while waiting for VM info file %s to exist.", options.infofile)
					case <-ctx.Done():
						result <- fmt.Errorf("Timedout waiting for VM info file %s to exist.", options.infofile)
					case <-time.After(time.Millisecond * 500):
						// continue check if file exists every 500ms
					}
				} else {
					result <- err1
				}
			} else {
				result <- nil
			}
		}
	}()

	if err = <-result; err == nil {
		if data, err = os.ReadFile(options.infofile); err == nil {
			return string(data), nil
		}
	}
	return "", err
}
