package http

import (
	"context"
	"fmt"
	"github.com/grafana-tools/sdk"
	"os"
)

func UpdateDashboard(apiUrl string, apiKey string, dashboard []byte) {
	ctx := context.Background()
	c, err := sdk.NewClient(apiUrl, apiKey, sdk.DefaultHTTPClient)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create a client: %s\n", err)
		os.Exit(1)
	}

	if _, err = c.SetRawDashboard(ctx, dashboard); err != nil {
		fmt.Fprint(os.Stderr, err)
		os.Exit(1)
	}
}