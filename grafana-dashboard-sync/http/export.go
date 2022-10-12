package http

import (
	"context"
	"fmt"
	"github.com/grafana-tools/sdk"
	"os"
)

type ExportedDashboard struct {
	RawBoard []byte
	FileName string
}

func ExportDashboards(apiUrl string, apiKey string) []ExportedDashboard {
	var (
		boardLinks []sdk.FoundBoard
		rawBoard   []byte
		meta       sdk.BoardProperties
		err        error
	)

	ctx := context.Background()
	c, err := sdk.NewClient(apiUrl, apiKey, sdk.DefaultHTTPClient)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create a client: %s\n", err)
		os.Exit(1)
	}

	if boardLinks, err = c.Search(ctx, sdk.SearchType(sdk.SearchTypeDashboard)); err != nil {
		fmt.Fprint(os.Stderr, err)
		os.Exit(1)
	}

	var exportedDashboards []ExportedDashboard

	for _, link := range boardLinks {
		if rawBoard, meta, err = c.GetRawDashboardByUID(ctx, link.UID); err != nil {
			fmt.Fprintf(os.Stderr, "%s for %s\n", err, link.URI)
			continue
		}

		dashboard := ExportedDashboard{
			RawBoard: rawBoard,
			FileName: fmt.Sprintf("%s.json", meta.Slug),
		}

		exportedDashboards = append(exportedDashboards, dashboard)
	}

	return exportedDashboards
}
