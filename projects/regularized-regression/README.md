# Regularized regression

Elastic-net regression after a linear model fails because of extreme multicollinearity.

## Problem statement

Fit `Y` on the remaining covariates, diagnose the linear model, then regularize. Six columns are removed according to digits of the student ID before fitting. The instructor statement is [`AEM_03_Enunciado_evaluacion.pdf`](AEM_03_Enunciado_evaluacion.pdf).

## Data

- **Source:** `AEM_03_Regularization_data.RData`, placed locally in `data/raw/`.
- **Contents:** a data frame `datos` whose first column is `Y` and whose remaining columns are covariates. The script drops six of those covariates.
- See [`data/README.md`](data/README.md). The `.RData` file is not committed.

## Approach

The report is [`notebooks/01_regularized_regression.Rmd`](notebooks/01_regularized_regression.Rmd). The same analysis as a script is [`notebooks/regularized_regression.R`](notebooks/regularized_regression.R).

An ordinary least squares fit (`lm`) is checked with residual plots, VIFs from `car`, and the determinant of the coefficient covariance matrix. Elastic net is then fit with `glmnet` over alpha values `0, 0.05, ..., 0.95, 1`. For each alpha, `cv.glmnet` chooses `lambda.1se`. The alpha with the smallest cross-validated mean squared error is kept. The seed is `123`.

## Results

The linear model has a low overall p-value and residuals that look roughly normal, but the VIFs are far above 5 and the covariance determinant is tiny, so the fit is not usable. Cross-validated error is similar across alpha. The 1-SE rule selects alpha `0.45`. At `lambda.1se` (about `0.029`) the model keeps 34 variables. The report notes that a larger lambda (about `0.073`) still has an R-squared near 93% with 27 variables. Charts are in [`reports/regularized_regression.pdf`](reports/regularized_regression.pdf). [`reports/figures/`](reports/figures/) has no separate image files.

## How to run

From this directory, with the `.RData` file in `data/raw/` and the R packages `glmnet`, `Matrix`, `car`, and `rmarkdown` installed:

```r
rmarkdown::render(
  "notebooks/01_regularized_regression.Rmd",
  output_format = "pdf_document",
  output_file = "regularized_regression.pdf",
  output_dir = "reports"
)
```

```bash
uv sync
uv run pytest
```

Run `notebooks/regularized_regression.R` from this directory so `load("data/raw/AEM_03_Regularization_data.RData")` resolves. `uv sync` and `uv run pytest` cover the placeholder Python package.
