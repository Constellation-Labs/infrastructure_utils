package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
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
	rootCmd.AddCommand(pullCmd)
	rootCmd.AddCommand(pushCmd)
}
