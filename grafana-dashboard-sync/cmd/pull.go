package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"grafana-dashboard-sync/config"
	"grafana-dashboard-sync/http"
	"os"
)

var pullCmd = &cobra.Command{
	Use:   "pull-dashboards",
	Short: "Pulls dashboard to json files.",
	Long:  `Pulls dashboard to json files.`,
	Run: func(cmd *cobra.Command, args []string) {
		dashboards := http.ExportDashboards(apiUrl, apiKey)

		dir := config.NormalizePath(directory)

		for _, dashboard := range dashboards {
			if err := os.WriteFile(dir+dashboard.FileName, dashboard.RawBoard, os.FileMode(0666)); err != nil {
				fmt.Fprintf(os.Stderr, "%s for %s\n", err, dashboard.FileName)
			}
		}
	},
}

func init() {
	pullCmd.PersistentFlags().StringVar(&apiUrl, "url", "http://127.0.0.1:3000", "Url to Grafana API")
	pullCmd.PersistentFlags().StringVar(&apiKey, "apikey", "", "Grafana API key")
	pullCmd.PersistentFlags().StringVar(&directory, "directory", "", "Destination directory for pulled dashboards")
}