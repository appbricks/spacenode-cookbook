//go:build darwin

package internal

import (
	"bufio"
	"bytes"
	"net/netip"
	"regexp"
	"strings"

	"github.com/mevansam/goutils/run"
)

var (
	nameserverMatch = regexp.MustCompile(`^\s+nameserver\[\d+\]\s+:\s+(.*)\s*$`)
	resolverItfMatch = regexp.MustCompile(`^\s+if_index\s+:\s+\d+\s+\((.*)\)\s*$`)
)

func GetSystemNameservers(defItf string) ([]netip.Addr, error) {

	var (
		err error

		scutil       run.CLI
		outputBuffer bytes.Buffer

		line    string
		matches [][]string
	)

	if scutil, _, err = run.CreateCLI("scutil", &outputBuffer, &outputBuffer); err != nil {
		return nil, err
	}
	if err = scutil.Run([]string{"--dns"}); err != nil {
		return nil, err
	}

	nameservers := []netip.Addr{}
	itf         := ""

	foundNameServers := func() bool {
		if itf == defItf && len(nameservers) > 0 {
			return true
		}
		nameservers = []netip.Addr{}
		itf = ""
		return false
	}

	scanner := bufio.NewScanner(bytes.NewReader(outputBuffer.Bytes()))
	for scanner.Scan() {
		line = scanner.Text()

		if matches = resolverItfMatch.FindAllStringSubmatch(line, -1); len(matches) > 0 {
			itf = matches[0][1]
			continue
		}
		if matches = nameserverMatch.FindAllStringSubmatch(line, -1 ); len(matches) > 0 {
			nameservers = append(nameservers, netip.MustParseAddr(matches[0][1]))
			continue
		}
		if strings.HasPrefix(line, "resolver") {
			if foundNameServers() {
				return nameservers, nil
			}
		}
	}
	if foundNameServers() {
		return nameservers, nil
	}

	return nil, nil
}
