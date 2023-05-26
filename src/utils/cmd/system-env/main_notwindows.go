//go:build !windows

package main

import (
	"github.com/mitchellh/go-homedir"
)

func init() {
	home, _ := homedir.Dir()

	sysPaths.GlobalDataDir = "/usr/local/var/mycs"
	sysPaths.LocalDataDir = home + "/.mycs"
}
