package config

import "strings"

func NormalizePath(path string) string {
	var dir string
	if strings.HasSuffix(path, "/") {
		dir = path
	} else {
		dir = path + "/"
	}

	return dir
}