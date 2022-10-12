package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"grafana-dashboard-sync/http"
	"os"
	"strings"
)

var (
	apiUrl    string
	apiKey    string
	directory string
	rootCmd   = &cobra.Command{
		Use:   "grafana-dashboard-sync",
		Short: "Grafana Dashboard Sync",
		Long:  "Grafana Dashboard Sync",
		Run: func(cmd *cobra.Command, args []string) {
			dashboards := http.ExportDashboards(apiUrl, apiKey)

			var dir string
			if strings.HasSuffix(directory, "/") {
				dir = directory
			} else {
				dir = directory + "/"
			}

			for _, dashboard := range dashboards {
				if err := os.WriteFile(dir+dashboard.FileName, dashboard.RawBoard, os.FileMode(0666)); err != nil {
					fmt.Fprintf(os.Stderr, "%s for %s\n", err, dashboard.FileName)
				}
			}
		},
	}
)

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVar(&apiUrl, "url", "http://127.0.0.1:3000", "Url to Grafana API")
	rootCmd.PersistentFlags().StringVar(&apiKey, "apikey", "", "Grafana API key")
	rootCmd.PersistentFlags().StringVar(&directory, "directory", "", "Destination directory for exported dashboards")
}
