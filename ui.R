# ui.R — Sales Analytics Dashboard UI
# Neobrutalist design: hard borders, 4px offset shadow, zero radius, dark surface

ui <- fluidPage(

  # ── Custom CSS ────────────────────────────────────────────────────────────
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$title("Sales Analytics Dashboard")
  ),

  # ── Top bar ───────────────────────────────────────────────────────────────
  tags$header(
    class = "topbar",
    tags$span(class = "topbar-brand", "SALES ANALYTICS"),
    tags$span(class = "topbar-accent", "DASHBOARD")
  ),

  # ── Layout: sidebar + main ────────────────────────────────────────────────
  sidebarLayout(

    # ── Sidebar ──────────────────────────────────────────────────────────
    sidebarPanel(
      class = "sidebar-neo",

      tags$div(
        class = "sidebar-header",
        tags$h3("FILTERS")
      ),

      dateRangeInput(
        inputId = "date_range",
        label   = "DATE RANGE",
        start   = min(sales_data$date),
        end     = max(sales_data$date),
        min     = min(sales_data$date),
        max     = max(sales_data$date),
        format  = "yyyy-mm-dd",
        separator = " to "
      ),

      selectizeInput(
        inputId  = "region",
        label    = "REGIONS",
        choices  = levels(sales_data$region),
        selected = levels(sales_data$region),
        multiple = TRUE,
        options  = list(
          placeholder = "Select regions...",
          plugins     = list("remove_button")
        )
      ),

      tags$hr(),

      tags$div(
        class = "sidebar-stats",
        tags$p(tags$strong("Rows in view:"), textOutput("row_count", inline = TRUE)),
        tags$p(tags$strong("Date range:"), textOutput("date_span", inline = TRUE)),
        tags$p(tags$strong("Total revenue:"), textOutput("total_rev", inline = TRUE))
      )
    ),

    # ── Main panel ────────────────────────────────────────────────────────
    mainPanel(
      class = "main-neo",

      tabsetPanel(
        id = "main_tabs",
        type = "tabs",

        # ── Overview tab ──────────────────────────────────────────────
        tabPanel(
          title = "OVERVIEW",
          value = "overview",

          tags$div(class = "tab-content",

            tags$div(class = "kpi-row",
              tags$div(class = "kpi-card",
                tags$span(class = "kpi-label", "TOTAL REVENUE"),
                tags$span(class = "kpi-value", textOutput("kpi_total_rev", inline = TRUE))
              ),
              tags$div(class = "kpi-card",
                tags$span(class = "kpi-label", "AVG DEAL"),
                tags$span(class = "kpi-value", textOutput("kpi_avg_deal", inline = TRUE))
              ),
              tags$div(class = "kpi-card",
                tags$span(class = "kpi-label", "TRANSACTIONS"),
                tags$span(class = "kpi-value", textOutput("kpi_count", inline = TRUE))
              ),
              tags$div(class = "kpi-card",
                tags$span(class = "kpi-label", "PRODUCTS"),
                tags$span(class = "kpi-value", textOutput("kpi_products", inline = TRUE))
              )
            ),

            tags$div(class = "chart-container",
              tags$h4("REVENUE BY PRODUCT"),
              plotOutput("overview_bar_chart", height = "420px")
            ),

            tags$div(class = "table-container",
              tags$h4("SUMMARY TABLE"),
              tableOutput("overview_summary_table")
            )
          )
        ),

        # ── Revenue Trend tab ──────────────────────────────────────────
        tabPanel(
          title = "REVENUE TREND",
          value = "trend",

          tags$div(class = "tab-content",

            tags$div(class = "chart-container",
              tags$h4("MONTHLY REVENUE TREND"),
              plotOutput("trend_line_chart", height = "420px")
            ),

            tags$div(class = "chart-container",
              tags$h4("REVENUE BY REGION OVER TIME"),
              plotOutput("trend_region_chart", height = "380px")
            )
          )
        ),

        # ── Data Explorer tab ──────────────────────────────────────────
        tabPanel(
          title = "DATA EXPLORER",
          value = "data",

          tags$div(class = "tab-content",
            tags$div(class = "table-container",
              tags$h4("RAW SALES DATA"),
              DTOutput("data_explorer_table")
            )
          )
        )
      )
    )
  ),

  # ── Footer ─────────────────────────────────────────────────────────────────
  tags$footer(
    class = "footer-neo",
    tags$span("Sales Analytics Dashboard"),
    tags$span(class = "footer-mono", paste("Data range:", min(sales_data$date), "–", max(sales_data$date))),
    tags$span(class = "footer-mono", paste(nrow(sales_data), "rows seeded"))
  )
)
