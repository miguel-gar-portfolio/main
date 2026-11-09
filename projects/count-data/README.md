# Count data

Zero-altered and zero-inflated models for a count response with excess zeros.

## Problem statement

The response is a count with far more zeros than a Poisson or negative binomial distribution would produce on its own. The task is to check data quality, compare zero-altered (hurdle) and zero-inflated specifications, and select a model with AIC and BIC. The instructor statement is [`AEM_02_Datos_conteo.pdf`](AEM_02_Datos_conteo.pdf) (a Word copy is [`AEM_02_Datos_conteo.docx`](AEM_02_Datos_conteo.docx)).

## Data

- **Source:** `AEM_02_Count_regression_and_GAM.xlsx`, placed locally in `data/raw/`.
- **Contents:** a count response `y`, numeric covariates, and three factors. The file has no missing values.
- See [`data/README.md`](data/README.md). The workbook is not committed.

## Approach

The script is [`notebooks/01_count_regression.R`](notebooks/01_count_regression.R). After an exploratory comparison of the empirical distribution with Poisson and negative binomial shapes, it fits zero-altered and zero-inflated Poisson and negative binomial models with `pscl` and `MASS`. Covariates are dropped when their coefficients are not significant. Candidates are compared with a likelihood-ratio test against the null, AIC, BIC, residual standard deviation, and how many of the observed zeros the fitted values recover.

## Results

The selected model is `zanbb_x12f3_x5`: a zero-altered hurdle model with a negative binomial count component. It has the lowest AIC and BIC. Residual standard deviation is about 5.78, and it predicts 66 of the 102 observed zeros. Zero-altered models beat the zero-inflated candidates, which predict no zeros. The comparison table is [`reports/tables/model_comparison.csv`](reports/tables/model_comparison.csv). Charts are in [`reports/figures/`](reports/figures/) and in [`reports/AEM_02_Count_data_report.pdf`](reports/AEM_02_Count_data_report.pdf).

## How to run

From this directory, with the workbook in `data/raw/` and the R packages `ggplot2`, `sandwich`, `msm`, `pscl`, `MASS`, `car`, `lmtest`, `readr`, and `readxl` installed:

```bash
Rscript notebooks/01_count_regression.R
uv sync
uv run pytest
```

The script rewrites the comparison table under `reports/tables/` and the figures under `reports/figures/`. `uv sync` and `uv run pytest` cover the placeholder Python package.
