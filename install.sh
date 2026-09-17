#!/usr/bin/env bash
set -euo pipefail

echo "=== Sales Analytics Dashboard: Install ==="

# Install system build dependencies for R package compilation
if command -v apt-get &>/dev/null; then
  echo "Installing system build dependencies..."
  apt-get update -qq 2>/dev/null || true
  apt-get install -y -qq \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev \
    libpng-dev libtiff5-dev libjpeg-dev \
    libuv1-dev \
    2>/dev/null || true

  # Update binutils for GCC 15 compatibility (fixes .base64 assembler error)
  apt-get install -y -qq binutils 2>/dev/null || true

  # Try to install IBM Plex fonts (non-fatal if unavailable)
  apt-get install -y -qq fonts-ibm-plex 2>/dev/null || echo "IBM Plex system fonts not available; CSS fallbacks apply."
fi

echo "Installing R packages from CRAN..."
Rscript -e '
  pkgs <- c("shiny", "dplyr", "ggplot2", "lubridate", "DT", "scales")
  installed <- installed.packages()[,"Package"]
  needed <- setdiff(pkgs, installed)
  if (length(needed) > 0) {
    cat("Installing:", paste(needed, collapse=", "), "\n")
    for (p in needed) {
      cat("  ->", p, "\n")
      install.packages(p, repos = "https://cloud.r-project.org", quiet = FALSE)
    }
  } else {
    cat("All required R packages already installed.\n")
  }
  # Verify key packages
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) stop("Package ", p, " failed to install")
    cat("OK: ", p, " v", as.character(packageVersion(p)), "\n", sep = "")
  }
'

echo ""
echo "=== Install complete ==="
echo "Run the app with: Rscript app.R"
