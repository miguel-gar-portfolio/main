# Dungeons

Predict the difficulty of an RPG dungeon from the positions and combat power of its enemies.

## Problem statement

The ordinal target `RANGO` is the difficulty of a dungeon-crawler level. A later section builds a binary label `DIFICIL` for ranks above Platino. The instructor statement is [`Trabajo ML1_ML2_Enunciado.pdf`](Trabajo%20ML1_ML2_Enunciado.pdf).

## Data

- **Source:** `dungeons.csv`, placed locally in `data/raw/`.
- **Contents:** an identifier, a constant enemy count, the 3D position and combat power of five enemies, and the ordinal rank `RANGO`.
- See [`data/README.md`](data/README.md). The CSV is not committed.

## Approach

The report is [`notebooks/01_dungeons.qmd`](notebooks/01_dungeons.qmd). Shared metric and plotting helpers live in [`R/helpers.R`](R/helpers.R).

`ID` is dropped. `N_ENEMIES` is constant and is kept out of the predictors, then detected formally later. A 75/25 split uses seed `1234`, and predictors are scaled on the training fold only. Multiclass models are a pruned CART tree, a Random Forest, and a single-hidden-layer neural net. PCA describes the predictors. A genetic algorithm selects features using macro F1. `DIFICIL` is classified with a radial SVM. After an imbalance check, ROSE rebalances the binary sample and the SVM and a perceptron are refit.

## Results

Charts, confusion matrices, and the tuned hyperparameters are in [`reports/dungeons.pdf`](reports/dungeons.pdf). On the balanced binary task, both the SVM and the perceptron mispredict dungeon ID 40. [`reports/figures/`](reports/figures/) has no separate image files.

## How to run

From this directory, with `dungeons.csv` in `data/raw/` and Quarto plus the R packages used in the report (`tidyverse`, `caret`, `rpart`, `rpart.plot`, `randomForest`, `nnet`, `factoextra`, `GA`, `e1071`, `pROC`, `ROSE`, `knitr`, `yardstick`) installed:

```bash
quarto render notebooks/01_dungeons.qmd --to pdf
uv sync
uv run pytest
```

`quarto render` writes the PDF under `reports/` (see [`_quarto.yml`](_quarto.yml)). `uv sync` and `uv run pytest` cover the placeholder Python package.
