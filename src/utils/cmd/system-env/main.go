package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/netip"
	"regexp"
	"runtime"
	"strings"

	"tailscale.com/net/interfaces"

	"github.com/mevansam/goutils/logger"
	"github.com/mevansam/goutils/run"
	"github.com/mevansam/goutils/utils"

	. "appbricks.io/mycs-cookbook-utils/internal"
)

type output struct {
	Version        string `json:"version"`
	BuildTimestamp string `json:"buildTimestamp"`

	OS   string `json:"os"`
	Arch string `json:"arch"`

	Network  network `json:"network"`
	Tools    tools   `json:"tools"`
	VBoxInfo vbox    `json:"vbox"`

	Error string   `json:"error"`
	Msgs  []string `json:"msgs"`
}

type tools struct {
	VagrantInstalled string `json:"vagrantInstalled"`
	VBoxInstalled    string `json:"vboxInstalled"`
}

type network struct {
	DefaultItf     string       `json:"defaultItf"`
	DefaultIP      netip.Addr   `json:"defaultIP"`
	DefaultNetwork netip.Prefix `json:"defaultNetwork"`
	GatewayIP      netip.Addr   `json:"gatewayIP"`
	Nameservers    []netip.Addr `json:"nameservers"`
	PublicIP       netip.Addr   `json:"publicIP"`
}

type vbox struct {
	DefaultBridge string `json:"defaultBridge"`
	VBoxManageCLI string `json:"vboxmanageCLI"`
}

// returns the corresponding bridge
// itf name vbox will recognize
var vboxItfName = func(itfName string) string {
	return ""
}

func main() {

	var (
		err error
		ok  bool

		resp *http.Response
		body []byte

		vboxmanage   run.CLI
		outputBuffer bytes.Buffer
		results      map[string][][]string

		jsonOutput []byte
	)

	logger.Initialize()

	output := output{
		Version:        Version,
		BuildTimestamp: BuildTimestamp,
		OS:             runtime.GOOS,
		Arch:           runtime.GOARCH,
		Msgs:           []string{},
	}
	defer func() {
		if jsonOutput, err = json.Marshal(output); err != nil {
			output.Error = fmt.Sprintf("Unable to generate JSON output for system-env: %s", err.Error())
		}
		fmt.Print(string(jsonOutput))
	}()

	if output.Network.DefaultItf, err = interfaces.DefaultRouteInterface(); err != nil {
		output.Error = fmt.Sprintf("Unable to read default interface: %s", err.Error())
		return
	}
	if output.Network.GatewayIP, _, ok = interfaces.LikelyHomeRouterIP(); !ok {
		output.Error = "Unable to read default host ip and gateway."
		return
	}
	if err = interfaces.ForeachInterface(func(itf interfaces.Interface, pfxs []netip.Prefix) {
		if itf.Name == output.Network.DefaultItf {
			for _, pfx := range pfxs {
				if pfx.Addr().Is4() {
					output.Network.DefaultIP = pfx.Addr()
					output.Network.DefaultNetwork = pfx.Masked()
					break
				}
			}
		}
	}); err != nil {
		output.Error = fmt.Sprintf("Unable to read network address: %s", err.Error())
		return
	}
	if output.Network.Nameservers, err = GetSystemNameservers(output.Network.DefaultItf); err != nil {
		output.Error = fmt.Sprintf("Unable to read network nameservers: %s", err.Error())
		return
	}

	if resp, err = http.Get("http://ifconfig.me"); err != nil {
		output.Error = fmt.Sprintf("Unable lookup external facing public IP of this network: %s", err.Error())
	} else {
		if body, err = io.ReadAll(resp.Body); err != nil {
			output.Error = fmt.Sprintf("Unable read response from http://ifconfig.me: %s", err.Error())
		} else {
			if output.Network.PublicIP, err = netip.ParseAddr(string(body)); err != nil {
				output.Error = fmt.Sprintf("Error parsing public IP '%s': %s", string(body), err.Error())
			}
		}
	}

	if _, _, err = CreateCLI("vagrant", &outputBuffer, &outputBuffer); err != nil {
		output.Msgs = append(output.Msgs,
			fmt.Sprintf("Unable to create CLI for 'vagrant': %s", err.Error()),
		)
		output.Tools.VagrantInstalled = "false"
	} else {
		output.Tools.VagrantInstalled = "true"
	}

	if vboxmanage, output.VBoxInfo.VBoxManageCLI, err = CreateCLI("vboxmanage", &outputBuffer, &outputBuffer); err != nil {
		output.Msgs = append(output.Msgs,
			fmt.Sprintf("Unable to create CLI for 'vboxmanage': %s", err.Error()),
		)
		output.Tools.VBoxInstalled = "false"
	} else {
		output.Tools.VBoxInstalled = "true"

		output.VBoxInfo.DefaultBridge = vboxItfName(output.Network.DefaultItf)
		if len(output.VBoxInfo.DefaultBridge) == 0 {
			if err = vboxmanage.Run([]string{"list", "bridgedifs"}); err != nil {
				output.Error = fmt.Sprintf(
					"Error retrieving Virtual Box bridge interfaces: %s",
					strings.TrimSuffix(outputBuffer.String(), "\n"),
				)
				return
			}
			results = utils.ExtractMatches(outputBuffer.Bytes(), map[string]*regexp.Regexp{
				"defBridge": regexp.MustCompile(fmt.Sprintf("^Name:\\s+(%s:.*)$", output.Network.DefaultItf)),
			})
			if b := results["defBridge"]; len(b) > 0 && len(b[0]) == 2 {
				output.VBoxInfo.DefaultBridge = b[0][1]
			}
			outputBuffer.Reset()
		}
	}
}
