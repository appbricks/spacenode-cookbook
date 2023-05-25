//go:build windows

package main

import (
	"os"
	"path/filepath"
	"runtime"

	"github.com/mevansam/goutils/run"
)

func init() {

	var (
		err error

		oscdimgPath string
	)

	// maps cli names to windows intallation specific names and paths
	run.AddCliNameMapping("oscdimg", "oscdimg.exe")
	// provide search paths for oscdimg cli
	if drives, err := run.GetLogicalDrives(); err == nil {
		for _, d := range drives {
			run.AddCliSearchPaths("oscdimg",
				filepath.Join(d, "Program Files (x86)", "Windows Kits", "10", "Assessment and Deployment Kit", "Deployment Tools", runtime.GOARCH, "Oscdimg"),
				filepath.Join(d, "Program Files", "Windows Kits", "10", "Assessment and Deployment Kit", "Deployment Tools", runtime.GOARCH, "Oscdimg"),
			)
		}
	}
	// add oscdimg cli path to system path so vagrant can find it
	if _, oscdimgPath, err = run.CreateCLI("oscdimg", os.Stdout, os.Stderr); err == nil {
		os.Setenv("PATH", os.Getenv("PATH")+";"+filepath.Dir(oscdimgPath))
	}
}
