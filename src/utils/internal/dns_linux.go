//go:build linux

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
	nameserversMatch = regexp.MustCompile(`^\s+DNS Servers:\s+(.*)\s*$`)
	resolverItfMatch = regexp.MustCompile(`^Link [0-9]+\s+\((.*)\)\s*$`)
)

func GetSystemNameservers(defItf string) ([]netip.Addr, error) {

	var (
		err error

		resolvectl   run.CLI
		outputBuffer bytes.Buffer

		line    string
		matches [][]string
	)

	if resolvectl, err = CreateCLI("resolvectl", &outputBuffer, &outputBuffer); err != nil {
		return nil, err
	}
	if err = resolvectl.Run([]string{}); err != nil {
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
			if foundNameServers() {
				return nameservers, nil
			}
			itf = matches[0][1]
			continue
		}
		if matches = nameserversMatch.FindAllStringSubmatch(line, -1 ); len(matches) > 0 {
			for _, ns := range strings.Split(matches[0][1], ",") {
				nameservers = append(nameservers, netip.MustParseAddr(strings.TrimSpace(ns)))
			}
			continue
		}
	}
	if foundNameServers() {
		return nameservers, nil
	}

	return nil, nil
}