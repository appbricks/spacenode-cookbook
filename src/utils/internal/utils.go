package internal

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/mitchellh/go-homedir"

	"github.com/mevansam/goutils/run"
)

var (
	outputBuffer bytes.Buffer

	shell run.CLI
	sherr error
)

var CliName = func(cliName string) string {
	return cliName
}

var CliSearchPaths = func(cliName string) []string {
	return []string{}
}

func CreateCLI(cliName string, outputBuffer *bytes.Buffer, errorBuffer *bytes.Buffer) (run.CLI, string, error) {

	var (
		err error

		cliPath string
	)

	cliBinaryName := CliName(cliName)
	for _, path := range CliSearchPaths(cliName) {
		if _, err = os.Stat(filepath.Join(path, cliBinaryName)); err == nil {
			cliPath = filepath.Join(path, cliBinaryName)
			break
		}
	}
	if len(cliPath) == 0 {
		if cliPath, err = LookupFilePathInSystem(cliBinaryName); err != nil {
			return nil, cliPath, err
		}
	}

	cwd, _ := os.Getwd()
	cli, err := run.NewCLI(cliPath, cwd, outputBuffer, errorBuffer)
	return cli, cliPath, err
}

func LookupFilePathInSystem(fileName string) (string, error) {

	var (
		err error
	)

	defer outputBuffer.Reset()

	if sherr == nil {
		if runtime.GOOS == "darwin" || runtime.GOOS == "linux" || runtime.GOOS == "openbsd" {
			if err = shell.Run([]string{"-c", fmt.Sprintf("which %s", fileName)}); err != nil {
				return "", fmt.Errorf(
					"error looking up file '%s' in system path: %s",
					fileName, strings.TrimSuffix(outputBuffer.String(), "\n"),
				)
			}
			return strings.TrimSuffix(outputBuffer.String(), "\n"), nil

		} else if runtime.GOOS == "windows" {
			if err = shell.Run([]string{"/C", fmt.Sprintf("where %s", fileName)}); err != nil {
				return "", fmt.Errorf(
					"error looking up file '%s' in system path: %s",
					fileName, strings.TrimSuffix(outputBuffer.String(), "\r\n"),
				)
			}
			return strings.TrimSuffix(outputBuffer.String(), "\r\n"), nil
		}
	}
	return "", sherr
}

func init() {
	home, _ := homedir.Dir()
	if runtime.GOOS == "darwin" || runtime.GOOS == "linux" || runtime.GOOS == "openbsd" {
		shell, sherr = run.NewCLI("/bin/sh", home, &outputBuffer, &outputBuffer)
	} else if runtime.GOOS == "windows" {
		shell, sherr = run.NewCLI("C:\\Windows\\System32\\cmd.exe", home, &outputBuffer, &outputBuffer)
	} else {
		sherr = fmt.Errorf("unsupported OS")
	}
}
