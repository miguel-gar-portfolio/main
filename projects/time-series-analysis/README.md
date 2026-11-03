# Time series analysis

Unobserved-components, Holt–Winters, and Box–Jenkins forecasts of monthly US electricity generation.

## Problem statement

Three exercises analyze the same series and forecast through the end of the year after the estimation sample. Exercise 1 uses the classical unobserved-components method, Exercise 2 uses Holt–Winters exponential smoothing, and Exercise 3 uses Box–Jenkins (seasonal ARIMA). The estimation window is January 1973 through December 1989. Forecasts cover January–December 1990 and are compared with the actual 1990 values. The instructor statement is [`enunciado.pdf`](enunciado.pdf).

## Data

- **Source:** `electricity` in the R package `TSA` (`library(TSA); data(electricity)`).
- **Series:** monthly US electricity generation, all types (coal, natural gas, nuclear, oil, and wind), in millions of kilowatt-hours, January 1973–December 2005.
- **Size:** 396 monthly observations. The models use the 204 months from 1973 through 1989, and 1990 (12 months) is held out for comparison.
- See [`data/README.md`](data/README.md). No local data files are required.

## Approach

The report is [`notebooks/01_time_series_analysis.qmd`](notebooks/01_time_series_analysis.qmd).

Exercise 1 decomposes the series with a multiplicative `decompose()`, fits the extracted trend with a cubic polynomial, and forecasts 1990 from that trend and the seasonal indices. Exercise 2 fits a Holt–Winters exponential-smoothing model and checks residuals. Exercise 3 follows Box–Jenkins: a Box–Cox transform to stabilise variance, regular and seasonal differences for stationarity, then a seasonal ARIMA identified from the ACF/PACF and checked against residual white noise. The R packages used are `TSA`, `forecast`, `tseries`, and `Metrics`.

## Results

On the actual 1990 values, unobserved components has the lowest RMSE and MAE. Box–Jenkins is close. Holt–Winters is the weakest of the three. The comparison plot and the error table are in [`reports/time_series_analysis.pdf`](reports/time_series_analysis.pdf). Charts are embedded in that PDF. [`reports/figures/`](reports/figures/) has no separate image files.

## How to run

From this directory, with Quarto and the R packages `TSA`, `forecast`, `tseries`, and `Metrics` installed:

```bash
quarto render notebooks/01_time_series_analysis.qmd --to pdf
uv sync
uv run pytest
```

`quarto render` writes the PDF under `reports/` (see [`_quarto.yml`](_quarto.yml)). `uv sync` and `uv run pytest` cover the placeholder Python package.
