# global.R — Shared libraries and demo data generation
# Sourced once at app startup

library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(DT)
library(scales)

# ── Demo data generation ──────────────────────────────────────────────────────
generate_sales_data <- function(n_rows = 600, seed = 2024) {
  set.seed(seed)

  products <- c(
    "Enterprise Suite",
    "Analytics Pro",
    "Cloud Storage",
    "API Gateway",
    "Support Plus",
    "Security Shield"
  )

  regions <- c(
    "North America",
    "Europe",
    "Asia Pacific",
    "Latin America",
    "Middle East & Africa"
  )

  # Revenue base per product (annual run-rate shape)
  product_base <- c(
    `Enterprise Suite`       = 45000,
    `Analytics Pro`          = 32000,
    `Cloud Storage`          = 28000,
    `API Gateway`            = 22000,
    `Support Plus`           = 18000,
    `Security Shield`        = 15000
  )

  # Regional multipliers
  region_mult <- c(
    `North America`          = 1.4,
    `Europe`                 = 1.1,
    `Asia Pacific`           = 0.9,
    `Latin America`          = 0.6,
    `Middle East & Africa`   = 0.5
  )

  # Generate dates across roughly 2 years
  start_date <- as.Date("2023-01-01")
  end_date   <- as.Date("2024-12-15")

  dates <- sample(seq(start_date, end_date, by = "day"), n_rows, replace = TRUE)
  prod  <- sample(products, n_rows, replace = TRUE)
  reg   <- sample(regions, n_rows, replace = TRUE)

  # Revenue: base * regional multiplier * seasonal factor * noise
  seasonal <- 1 + 0.15 * sin(2 * pi * (as.numeric(format(dates, "%m")) - 1) / 12)
  noise    <- runif(n_rows, 0.7, 1.3)

  revenue <- round(
    product_base[prod] * region_mult[reg] * seasonal * noise / 250,
    2
  )

  df <- data.frame(
    date    = dates,
    product = factor(prod, levels = products),
    region  = factor(reg, levels = regions),
    revenue = revenue,
    stringsAsFactors = FALSE
  )

  df[order(df$date), ]
}

# Create the dataset once at startup
sales_data <- generate_sales_data()

# ── Shared ggplot2 theme (neobrutalist) ───────────────────────────────────────
theme_neobrutal <- function(base_size = 13) {
  theme_minimal(base_size = base_size) %+replace%
    theme(
      # Dark background
      plot.background  = element_rect(fill = "#111111", color = NA),
      panel.background = element_rect(fill = "#1a1a1a", color = NA),
      panel.grid.major = element_line(color = "#2a2a2a", linewidth = 0.5),
      panel.grid.minor = element_blank(),
      # Hard borders
      panel.border     = element_rect(fill = NA, color = "#0093a5", linewidth = 2),
      # Text
      plot.title       = element_text(
        family = "sans", face = "bold", color = "#f0f0f0", size = rel(1.3)
      ),
      plot.subtitle    = element_text(
        family = "sans", color = "#aaaaaa", size = rel(0.95)
      ),
      plot.caption     = element_text(
        family = "mono", color = "#666666", size = rel(0.8)
      ),
      axis.title       = element_text(
        family = "sans", color = "#cccccc", size = rel(0.9)
      ),
      axis.text        = element_text(
        family = "mono", color = "#999999", size = rel(0.8)
      ),
      legend.background = element_rect(fill = "#1a1a1a", color = "#0093a5", linewidth = 1.5),
      legend.text       = element_text(
        family = "mono", color = "#cccccc", size = rel(0.8)
      ),
      legend.title      = element_text(
        family = "sans", face = "bold", color = "#f0f0f0", size = rel(0.85)
      ),
      legend.key        = element_rect(fill = "#1a1a1a", color = NA),
      strip.background  = element_rect(fill = "#0093a5", color = NA),
      strip.text        = element_text(
        family = "sans", face = "bold", color = "#111111", size = rel(0.9)
      ),
      plot.margin       = margin(16, 16, 12, 12)
    )
}

# Accent palette for ggplot2
accent_colors <- c(
  "#0093a5",  # primary accent  (teal-cyan)
  "#e05a33",  # warm contrast
  "#f0c040",  # gold
  "#6ecf8a",  # green
  "#c47be0",  # purple
  "#5b9bd5"   # blue
)

scale_fill_neobrutal <- function(...) {
  scale_fill_manual(values = accent_colors, ...)
}

scale_color_neobrutal <- function(...) {
  scale_color_manual(values = accent_colors, ...)
}
