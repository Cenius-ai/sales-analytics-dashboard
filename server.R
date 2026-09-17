# server.R — Sales Analytics Dashboard server logic
# Reactive filtering, ggplot2 outputs, DT table

server <- function(input, output, session) {

  # ── Reactive data filter ──────────────────────────────────────────────────
  filtered_data <- reactive({

    req(input$date_range, input$region)

    # Validate: at least one region selected
    validate(
      need(length(input$region) > 0, "Please select at least one region.")
    )

    # Validate: start date is not after end date
    start <- input$date_range[1]
    end   <- input$date_range[2]
    validate(
      need(!is.na(start) && !is.na(end) && start <= end,
           "Invalid date range: start date must be before end date.")
    )

    sales_data %>%
      filter(
        date   >= start,
        date   <= end,
        region %in% input$region
      )
  })

  # ── Monthly aggregation (shared by trend charts) ──────────────────────────
  monthly_data <- reactive({
    filtered_data() %>%
      mutate(month = floor_date(date, unit = "month")) %>%
      group_by(month) %>%
      summarise(total_revenue = sum(revenue), .groups = "drop")
  })

  monthly_by_region <- reactive({
    filtered_data() %>%
      mutate(month = floor_date(date, unit = "month")) %>%
      group_by(month, region) %>%
      summarise(total_revenue = sum(revenue), .groups = "drop")
  })

  # ── Sidebar summary outputs ───────────────────────────────────────────────
  output$row_count <- renderText({
    nrow(filtered_data())
  })

  output$date_span <- renderText({
    d <- filtered_data()
    if (nrow(d) == 0) return("N/A")
    paste(format(min(d$date), "%b %d, %Y"), "–", format(max(d$date), "%b %d, %Y"))
  })

  output$total_rev <- renderText({
    dollar(sum(filtered_data()$revenue))
  })

  # ── KPI cards ─────────────────────────────────────────────────────────────
  output$kpi_total_rev <- renderText({
    dollar(sum(filtered_data()$revenue))
  })

  output$kpi_avg_deal <- renderText({
    dollar(mean(filtered_data()$revenue))
  })

  output$kpi_count <- renderText({
    format(nrow(filtered_data()), big.mark = ",")
  })

  output$kpi_products <- renderText({
    d <- filtered_data()
    if (nrow(d) == 0) return("0")
    length(unique(d$product))
  })

  # ── Pre-computed product summary for overview ─────────────────────────────
  product_summary <- reactive({
    d <- filtered_data()
    if (nrow(d) == 0) return(data.frame())
    d %>%
      group_by(product) %>%
      summarise(
        total_revenue = sum(revenue),
        transactions  = n(),
        avg_deal      = mean(revenue),
        .groups       = "drop"
      ) %>%
      arrange(desc(total_revenue))
  })

  # ── Overview: Bar chart ───────────────────────────────────────────────────
  output$overview_bar_chart <- renderPlot({

    ps <- product_summary()
    validate(
      need(nrow(ps) > 0, "No data matches the current filters.")
    )

    ps <- ps %>%
      mutate(product = factor(product, levels = product))

    ggplot(ps, aes(x = product, y = total_revenue, fill = product)) +
      geom_col(
        width = 0.7,
        color = "#111111",
        linewidth = 1.5
      ) +
      geom_text(
        aes(label = dollar(total_revenue)),
        vjust = -0.6,
        color = "#f0f0f0",
        size = 4,
        family = "mono"
      ) +
      scale_fill_neobrutal() +
      scale_y_continuous(
        labels = dollar_format(),
        expand = expansion(mult = c(0, 0.15))
      ) +
      labs(
        title    = "Total Revenue by Product",
        subtitle = paste("Filtered period —", format(min(filtered_data()$date), "%b %d, %Y"),
                         "to", format(max(filtered_data()$date), "%b %d, %Y")),
        x        = NULL,
        y        = "Revenue (USD)",
        caption  = "Source: seeded sales dataset"
      ) +
      theme_neobrutal() +
      theme(
        axis.text.x = element_text(
          angle = 30, hjust = 1, color = "#cccccc", size = 10
        ),
        legend.position = "none"
      )
  })

  # ── Overview: Summary table ───────────────────────────────────────────────
  output$overview_summary_table <- renderTable({

    ps <- product_summary()
    validate(
      need(nrow(ps) > 0, "No data matches the current filters.")
    )

    ps %>%
      transmute(
        Product          = product,
        `Total Revenue`  = dollar(total_revenue),
        Transactions     = format(transactions, big.mark = ","),
        `Avg Deal`       = dollar(avg_deal)
      )

  }, spacing = "m", width = "100%", align = "lrrr",
     bordered = TRUE, striped = FALSE, hover = TRUE)

  # ── Trend: Line chart ─────────────────────────────────────────────────────
  output$trend_line_chart <- renderPlot({

    md <- monthly_data()
    validate(
      need(nrow(md) > 0, "No data matches the current filters.")
    )

    ggplot(md, aes(x = month, y = total_revenue)) +
      geom_line(
        color = "#0093a5",
        linewidth = 1.8
      ) +
      geom_point(
        color = "#0093a5",
        fill  = "#111111",
        size  = 3.5,
        stroke = 1.8,
        shape = 21
      ) +
      geom_smooth(
        method  = "loess",
        formula = y ~ x,
        se      = TRUE,
        color   = "#e05a33",
        fill    = "#e05a33",
        alpha   = 0.15,
        linewidth = 1.2
      ) +
      scale_y_continuous(
        labels = dollar_format(),
        expand = expansion(mult = c(0.05, 0.1))
      ) +
      scale_x_date(
        date_labels = "%b %Y",
        date_breaks = "2 months"
      ) +
      labs(
        title    = "Monthly Revenue Trend",
        subtitle = "Total revenue aggregated by month with LOESS smooth",
        x        = NULL,
        y        = "Total Revenue (USD)",
        caption  = "Source: seeded sales dataset"
      ) +
      theme_neobrutal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, color = "#cccccc", size = 9)
      )
  })

  # ── Trend: Region line chart ──────────────────────────────────────────────
  output$trend_region_chart <- renderPlot({

    mbr <- monthly_by_region()
    validate(
      need(nrow(mbr) > 0, "No data matches the current filters.")
    )

    ggplot(mbr, aes(x = month, y = total_revenue, color = region, group = region)) +
      geom_line(linewidth = 1.4) +
      geom_point(size = 2.5, shape = 21, fill = "#111111", stroke = 1.4) +
      scale_color_neobrutal() +
      scale_y_continuous(
        labels = dollar_format(),
        expand = expansion(mult = c(0.05, 0.1))
      ) +
      scale_x_date(
        date_labels = "%b %Y",
        date_breaks = "3 months"
      ) +
      labs(
        title    = "Revenue by Region Over Time",
        subtitle = "Monthly revenue broken down by region",
        x        = NULL,
        y        = "Revenue (USD)",
        color    = "Region",
        caption  = "Source: seeded sales dataset"
      ) +
      theme_neobrutal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, color = "#cccccc", size = 9),
        legend.position = "bottom"
      )
  })

  # ── Data Explorer: DT table ───────────────────────────────────────────────
  output$data_explorer_table <- renderDT({

    d <- filtered_data()

    display <- d %>%
      select(date, product, region, revenue) %>%
      arrange(desc(date))

    datatable(
      display,
      rownames = FALSE,
      filter   = "top",
      options  = list(
        pageLength = 15,
        lengthMenu = c(10, 15, 25, 50, 100),
        ordering   = TRUE,
        searching  = TRUE,
        autoWidth  = TRUE,
        columnDefs = list(
          list(className = "dt-right", targets = 3)
        ),
        language = list(
          search       = "Search:",
          lengthMenu   = "Show _MENU_ rows",
          info         = "Showing _START_ to _END_ of _TOTAL_ transactions",
          infoFiltered = "(filtered from _MAX_ total)"
        )
      ),
      class = "display compact stripe hover"
    ) %>%
      formatCurrency(columns = "revenue", currency = "$", digits = 2) %>%
      formatDate(columns = "date", method = "toLocaleDateString")
  })
}
