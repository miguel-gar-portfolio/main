# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

Place the UCI Auto MPG file here:

```text
data/raw/auto-mpg.data
```

The file is the space-separated Auto MPG table from the UCI Machine Learning Repository (dataset id 9, `auto-mpg.data`): miles per gallon, cylinders, displacement, horsepower, weight, acceleration, model year, origin, and car name. Horsepower uses `?` for missing values. [`notebooks/01_kernel_regression.qmd`](../notebooks/01_kernel_regression.qmd) reads it with `read.table("data/raw/auto-mpg.data")` from the project directory.

## interim/

Unused. The horsepower missing-value mask stays in memory.

## processed/

Unused. Density and regression curves are drawn in [`reports/kernel_regression.pdf`](../reports/kernel_regression.pdf).
