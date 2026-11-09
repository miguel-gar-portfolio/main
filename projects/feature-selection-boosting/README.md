# Feature selection and boosting

LDA on two feature subsets, then gradient boosting and XGBoost, on the same two-class clothing sample used in the ML1 assignment.

## Problem statement

Split the 1,000-row sample into train and test, select features with CFS and a genetic algorithm, and compare Fisher's linear discriminant analysis with gradient boosting and XGBoost. The instructor statement is [`ML2_Enunciado_RPM_2026.pdf`](ML2_Enunciado_RPM_2026.pdf).

## Data

- **Source:** `datos.RData`, placed locally in `data/raw/`. [`data/GenerarDatos.R`](data/GenerarDatos.R) samples it with seed `29509`.
- **Sample:** two clothing classes (Pullover and Ankle boot), 10 of 784 pixel variables, and 1,000 rows. The 75/25 split uses seed `12345`, matching the ML1 partition.
- See [`data/README.md`](data/README.md). The `.RData` file is not committed.

## Approach

The report is [`notebooks/01_feature_selection_boosting.Rmd`](notebooks/01_feature_selection_boosting.Rmd).

CFS (`FSelector::cfs`) and a genetic algorithm (`caret::gafs`, random-forest fitness, 4-fold CV) propose feature subsets. Each subset is classified with `MASS::lda`. Gradient boosting is tuned with `caret` over trees, interaction depth, shrinkage, and minimum node size. XGBoost is a short `xgboost` run (`binary:logistic`, `max_depth = 4`, `learning_rate = 0.1`, 10 rounds). ROC curves use `ROCR`.

## Results

Both LDA models exceed 0.88 accuracy. The five-predictor model beats the single-predictor model, which misclassifies 26 Pullover cases. Gradient boosting (`n.trees = 250`, `interaction.depth = 7`, `shrinkage = 0.1`, `n.minobsinnode = 25`) beats LDA. The short XGBoost run is weaker than gradient boosting on every reported metric. Charts are in [`reports/feature_selection_boosting.pdf`](reports/feature_selection_boosting.pdf). [`reports/figures/`](reports/figures/) has no separate image files.

## How to run

From this directory, with `datos.RData` in `data/raw/` and the R packages `ggplot2`, `FSelector`, `ROCR`, `MASS`, `caret`, `xgboost`, `GA`, and `rmarkdown` installed:

```r
rmarkdown::render(
  "notebooks/01_feature_selection_boosting.Rmd",
  output_format = "pdf_document",
  output_file = "feature_selection_boosting.pdf",
  output_dir = "reports"
)
```

```bash
uv sync
uv run pytest
```

`uv sync` and `uv run pytest` cover the placeholder Python package.
