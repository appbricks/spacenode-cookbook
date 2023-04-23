//go:build !darwin && !linux

package internal

import (
	"fmt"
	"net/netip"

	"github.com/mevansam/goutils/logger"
	"tailscale.com/net/dns"
)

func GetSystemNameservers(defItf string) ([]netip.Addr, error) {

	var (
		err error

		dnsConfigurator dns.OSConfigurator
		dnsConfig       dns.OSConfig
	)

	if dnsConfigurator, err = dns.NewOSConfigurator(logger.DebugMessage, defItf); err != nil {
		return nil, fmt.Errorf("Unable to create OS DNS configurator: %s", err.Error())
	
	}
	if dnsConfig, err = dnsConfigurator.GetBaseConfig(); err != nil {
		return nil, fmt.Errorf("Unable to retrieve OS DNS config: %s", err.Error())
	}
	return dnsConfig.Nameservers, nil
}
