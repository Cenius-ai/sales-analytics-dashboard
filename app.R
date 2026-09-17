# app.R — Sales Analytics Dashboard entry point
# Sources global.R, ui.R, server.R and launches the Shiny app

# ── Source modules ───────────────────────────────────────────────────────────
source("global.R", local = FALSE)
source("ui.R", local = FALSE)
source("server.R", local = FALSE)

# ── Build and launch ─────────────────────────────────────────────────────────
port <- as.integer(Sys.getenv("PORT", "3838"))

cat(sprintf("\n=== Sales Analytics Dashboard ===\n"))
cat(sprintf("Listening on http://0.0.0.0:%d\n", port))
cat(sprintf("Seeded %d rows of sales data\n", nrow(sales_data)))
cat(sprintf("Products: %s\n", paste(levels(sales_data$product), collapse = ", ")))
cat(sprintf("Regions:  %s\n", paste(levels(sales_data$region), collapse = ", ")))
cat(sprintf("================================\n\n"))

app <- shinyApp(ui = ui, server = server)
runApp(app, host = "0.0.0.0", port = port, launch.browser = FALSE)
