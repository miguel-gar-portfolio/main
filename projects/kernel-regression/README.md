# Kernel regression

Kernel density estimates and local-linear kernel regression for the Auto MPG sample, compared with ordinary least squares.

## Problem statement

Estimate the density of miles per gallon, horsepower, and weight with a Gaussian kernel, using cross-validation and plug-in bandwidths. Then estimate the regression of miles per gallon on horsepower and on weight with local-linear kernel smoothers, and compare those curves with a straight line. The exercises are written in [`notebooks/01_kernel_regression.qmd`](notebooks/01_kernel_regression.qmd).

## Data

- **Source:** the UCI Auto MPG file `auto-mpg.data`, placed locally in `data/raw/`.
- **Columns used:** `mpg` (response), `horsepower`, and `weight`. Horsepower is stored as text and has missing values; those rows are dropped before the horsepower analyses.
- See [`data/README.md`](data/README.md). The data file is not committed.

## Approach

The Quarto report is [`notebooks/01_kernel_regression.qmd`](notebooks/01_kernel_regression.qmd). The same analysis as an R Markdown file is [`notebooks/kernel_regression.Rmd`](notebooks/kernel_regression.Rmd).

Density bandwidths use `bw.ucv` (cross-validation) and `bw.SJ` (plug-in). A two-dimensional density of horsepower and weight uses `ks`. Local-linear regression uses `KernSmooth::locpoly` and `KernSmooth::dpill`, with cross-validated bandwidths from `np::npregbw`. Each kernel curve is plotted against an `lm` fit.

## Results

Cross-validation and plug-in density estimates of `mpg` are close to each other and follow the histogram. For miles per gallon on horsepower, the plug-in smoother is smoother than the cross-validated one. The ordinary least squares fits stated in the report are `mpg = 39.9359 - 0.1578 * horsepower` and `mpg = 46.317364 - 0.007677 * weight`. On weight, the two kernel bandwidths nearly agree. Charts are in [`reports/kernel_regression.pdf`](reports/kernel_regression.pdf). [`reports/figures/`](reports/figures/) has no separate image files.

## How to run

From this directory, with `auto-mpg.data` in `data/raw/` and Quarto plus the R packages `ks`, `KernSmooth`, and `np` installed:

```bash
quarto render notebooks/01_kernel_regression.qmd --to pdf
uv sync
uv run pytest
```

`quarto render` writes the PDF under `reports/` (see [`_quarto.yml`](_quarto.yml)). `uv sync` and `uv run pytest` cover the placeholder Python package.
