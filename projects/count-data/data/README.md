# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

Place the instructor workbook here:

```text
data/raw/AEM_02_Count_regression_and_GAM.xlsx
```

[`notebooks/01_count_regression.R`](../notebooks/01_count_regression.R) reads it with `readxl` from the project directory. The sheet holds the count response `y`, numeric covariates, and factors `factor1`, `factor2`, and `factor3`.

## interim/

Unused. Factor coding stays in memory in the script.

## processed/

Unused. The comparison table is written to [`reports/tables/`](../reports/tables/), and the charts to [`reports/figures/`](../reports/figures/).
