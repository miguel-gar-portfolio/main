# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

Place the dungeon table here:

```text
data/raw/dungeons.csv
```

[`notebooks/01_dungeons.qmd`](../notebooks/01_dungeons.qmd) reads it with `readr::read_csv("data/raw/dungeons.csv")` from the project directory. Columns include `ID`, `N_ENEMIES`, the position and combat power of five enemies, and the ordinal difficulty `RANGO`.

## interim/

Unused. The train/test split, scaling, and the binary `DIFICIL` label stay in memory.

## processed/

Unused. Metrics and charts are written into [`reports/dungeons.pdf`](../reports/dungeons.pdf).
