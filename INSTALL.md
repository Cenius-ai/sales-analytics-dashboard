# Installation

## 1. Prerequisites

- **R**: A working R installation is required. No specific version is enforced; use a recent release.

## 2. Clone the Repository

Clone this repository to your local machine.

## 3. Install R Packages

Run the provided installation script to install all required packages:

```bash
bash install.sh
```

This script installs the tidyverse packages (including dplyr and ggplot2) and Shiny, then exits.

## 4. (Optional) Custom Styling

The file `www/custom.css` can be edited to adjust the app's appearance.

## 5. Run the App

Start the Shiny application from the command line:

```bash
Rscript app.R
```

The app will bind to host `0.0.0.0` on a fixed port and display a URL (typically `http://localhost:<port>`).

## 6. Troubleshooting

- If package installation fails, ensure R and system dependencies (e.g., `libcurl`, `libxml2` on Linux) are installed. Then re-run `install.sh`.
- If the app does not start, verify that `app.R` is in the working directory and that the Shiny package is installed.