//go:build windows

package main

import (
	"os"
	"path/filepath"

	"golang.org/x/sys/windows"
	"golang.zx2c4.com/wireguard/windows/tunnel/winipcfg"

	"github.com/mevansam/goutils/run"
)

func init() {

	sysPaths.GlobalDataDir = filepath.Join(os.Getenv("ProgramData"), "mycs")
	sysPaths.LocalDataDir = filepath.Join(os.Getenv("LOCALAPPDATA"), ".mycs")

	// maps cli names to windows intallation specific names and paths
	run.AddCliNameMapping("vagrant", "vagrant.exe")
	run.AddCliNameMapping("vboxmanage", "VBoxManage.exe")
	// provide search paths for vboxmanage cli
	if drives, err := run.GetLogicalDrives(); err == nil {
		for _, d := range drives {
			run.AddCliSearchPaths("vboxmanage",
				filepath.Join(d, "Program Files", "Oracle", "VirtualBox"),
				filepath.Join(d, "Oracle", "VirtualBox"),
				filepath.Join(d, "VirtualBox"),
			)
		}
	}

	// map given interface name to corresponding bridge itf name vbox will recognize
	vboxItfName = func(itfName string) string {
		addrs, err := winipcfg.GetAdaptersAddresses(windows.AF_INET, winipcfg.GAAFlagIncludeAllInterfaces)
		if err != nil {
			panic(err)
		}
		for _, addr := range addrs {
			if addr.FriendlyName() == itfName {
				return addr.Description()
			}
		}
		return itfName
	}
}
