package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"grafana-dashboard-sync/config"
	"grafana-dashboard-sync/http"
	"os"
	"strings"
)

var pushCmd = &cobra.Command{
	Use:   "push-dashboards",
	Short: "Push dashboard from json files to Grafana",
	Long:  "Push dashboard from json files to Grafana",
	Run: func(cmd *cobra.Command, args []string) {
		dir := config.NormalizePath(directory)

		entries, err := os.ReadDir(dir); if err != nil {
			fmt.Fprint(os.Stderr, err)
			os.Exit(1)
		}

		for _, entry := range entries {
			if !entry.IsDir() && strings.HasSuffix(entry.Name(), "json") {
				path := dir + entry.Name()
				fmt.Println(path)
				dashboard, err := os.ReadFile(path); if err != nil {
					fmt.Fprintf(os.Stderr, "%s for %s\n", err, entry.Name())
				} else {
					http.UpdateDashboard(apiUrl, apiKey, dashboard)
				}
			}
		}


	},
}

func init() {
	pushCmd.PersistentFlags().StringVar(&apiUrl, "url", "http://127.0.0.1:3000", "Url to Grafana API")
	pushCmd.PersistentFlags().StringVar(&apiKey, "apikey", "", "Grafana API key")
	pushCmd.PersistentFlags().StringVar(&directory, "directory", "", "Directory with dashboards to push")
}