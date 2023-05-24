//go:build windows

package main

import (
	"path/filepath"

	"github.com/mevansam/goutils/run"
)

func init() {

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
}
