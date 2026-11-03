# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

The series is not a local file. It ships with the R package `TSA`:

```r
library(TSA)
data(electricity)
```

`electricity` is monthly US electricity generation (million kWh) for coal, natural gas, nuclear, oil, and wind, from January 1973 through December 2005.

## raw/

Unused. [`notebooks/01_time_series_analysis.qmd`](../notebooks/01_time_series_analysis.qmd) loads `electricity` from `TSA` in memory.

## interim/

Unused. The estimation window (January 1973–December 1989) is taken in the notebook.

## processed/

Unused. Forecasts and error measures are computed in the notebook and written into [`reports/time_series_analysis.pdf`](../reports/time_series_analysis.pdf).
