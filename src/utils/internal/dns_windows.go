//go:build windows

package internal

import (
	"net/netip"

	"golang.org/x/sys/windows"
	"golang.zx2c4.com/wireguard/windows/tunnel/winipcfg"
	"tailscale.com/net/interfaces"
)

func GetSystemNameservers(defItf string) ([]netip.Addr, error) {

	var (
		err error
		ok  bool

		iface *winipcfg.IPAdapterAddresses

		addr         netip.Addr
		dnsServerIPs []netip.Addr
	)

	if iface, err = interfaces.GetWindowsDefault(windows.AF_INET); err != nil {
		return nil, err
	}
	for dnsAddr := iface.FirstDNSServerAddress; dnsAddr != nil; dnsAddr = dnsAddr.Next {
		if addr, ok = netip.AddrFromSlice(dnsAddr.Address.IP()); ok {
			dnsServerIPs = append(dnsServerIPs, addr)
		}
	}
	return dnsServerIPs, nil
}
