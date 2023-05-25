package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/mevansam/goutils/logger"
	"github.com/mevansam/goutils/run"

	. "appbricks.io/mycs-cookbook-utils/internal"
)

type output struct {
	Version        string `json:"version"`
	BuildTimestamp string `json:"buildTimestamp"`

	Msgs []string `json:"msgs"`
}

func main() {

	var (
		err error

		vboxmanage   run.CLI
		outputBuffer bytes.Buffer

		jsonOutput []byte
	)

	logger.Initialize()

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
