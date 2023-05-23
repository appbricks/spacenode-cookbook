//go:build windows

package main

import (
	"path/filepath"
	"syscall"

	. "appbricks.io/mycs-cookbook-utils/internal"
	"golang.org/x/sys/windows"
	"golang.zx2c4.com/wireguard/windows/tunnel/winipcfg"
)

var (
	drives []string

	vboxmanagePaths []string
)

func init() {

	var (
		err syscall.Errno

		ret uintptr
	)

	availableDrives := []string{"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

	kernel32, _ := syscall.LoadLibrary("kernel32.dll")
	getLogicalDrivesHandle, _ := syscall.GetProcAddress(kernel32, "GetLogicalDrives")

	if ret, _, err = syscall.SyscallN(uintptr(getLogicalDrivesHandle), 0, 0, 0, 0); err != 0 {
		panic("Unable to enumerate the systems logical drives.")
	}
	bitMap := uint32(ret)
	for i := range availableDrives {
		if bitMap&1 == 1 {
			drives = append(drives, availableDrives[i])
		}
		bitMap >>= 1
	}
	for _, drive := range drives {
		drivePrefix := drive + ":\\"
		vboxmanagePaths = append(vboxmanagePaths,
			filepath.Join(drivePrefix, "Program Files", "Oracle", "VirtualBox"),
			filepath.Join(drivePrefix, "Oracle", "VirtualBox"),
			filepath.Join(drivePrefix, "VirtualBox"),
		)
	}

	// maps app names to windows intallation specific names and paths
	CliName = func(appName string) string {
		switch appName {
		case "vagrant":
			return "vagrant.exe"
		case "vboxmanage":
			return "VBoxManage.exe"
		}
		return appName
	}
	CliSearchPaths = func(appName string) []string {
		if appName == "vboxmanage" {
			return vboxmanagePaths
		}
		return []string{}
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
