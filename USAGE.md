# Usage

## Starting the App

After installation, run:

```bash
Rscript app.R
```

The console will display a URL (commonly `http://localhost:3838`). Open that address in a web browser.

## Interacting with the Dashboard

- **Sidebar**:  
  - **Region filter**: Select one or more regions to subset the data.  
  - **Date range filter**: Choose a start and end date to narrow the period.

- **Main panel**:  
  - **Revenue bar chart**: A ggplot2 bar chart showing total revenue per product for the selected region(s) and dates.  
  - **Summary table**: A dplyr-aggregated table with product-level details (e.g., total revenue, units sold).

Adjust the filters; the chart and table update reactively. The underlying data is seeded within the app and does not require any external database or file.