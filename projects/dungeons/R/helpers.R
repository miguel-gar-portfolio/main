# =============================================================================
# helpers.R
# -----------------------------------------------------------------------------
# Reusable helper functions for the DUNGEONS Machine Learning report.
# Sourced once at the top of `dungeons_ml.qmd`. Keeping these functions in a
# separate file avoids code duplication and keeps the report readable: the
# report focuses on *methodology* and *interpretation*, while the mechanical
# work (package loading, metric extraction, plotting) lives here.
# =============================================================================

# -----------------------------------------------------------------------------
# install_and_load()
# -----------------------------------------------------------------------------
# Loads a vector of packages, installing any that are missing. We install on
# demand so the report is reproducible on a clean machine. `require()` returns
# FALSE (instead of erroring) when a package is absent, which lets us branch.
install_and_load <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      message("Installing missing package: ", pkg)
      install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
      if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
        stop("Could not install/load package: ", pkg)
      }
    }
  }
  invisible(TRUE)
}

# -----------------------------------------------------------------------------
# macro_average()
# -----------------------------------------------------------------------------
# Internal helper: given the `byClass` object of a caret::confusionMatrix,
# return the (unweighted) macro-average of a given metric column.
#
# `byClass` is a NAMED VECTOR when the problem is binary and a MATRIX
# (one row per class) when the problem is multiclass. We normalise both cases
# to a matrix so the rest of the code is uniform.
#
# We use MACRO averaging (simple mean across classes) rather than weighted /
# micro averaging because we care about performance on every difficulty rank
# equally -- including the rare ones. This matters a lot once class imbalance
# appears (Sections 5-8): a model that ignores a minority class should be
# penalised, and macro averaging does exactly that.
macro_average <- function(by_class, metric) {
  if (is.matrix(by_class)) {
    values <- by_class[, metric]
  } else {
    # Binary case: `by_class` is a named vector with a single value per metric.
    values <- by_class[[metric]]
  }
  values[is.na(values)]<- 0
  mean(values)
}

# -----------------------------------------------------------------------------
# multiclass_metrics()
# -----------------------------------------------------------------------------
# Extract a tidy one-row summary from a caret::confusionMatrix for a MULTICLASS
# problem. Returns Accuracy, Balanced Accuracy and macro-averaged
# Precision / Recall / F1. `model_name` is used as a label so results from
# several models can be row-bound into a comparison table.
multiclass_metrics <- function(cm, model_name = "model") {
  data.frame(
    Model             = model_name,
    Accuracy          = unname(cm$overall["Accuracy"]),
    Balanced_Accuracy = macro_average(cm$byClass, "Balanced Accuracy"),
    Precision         = macro_average(cm$byClass, "Precision"),
    Recall            = macro_average(cm$byClass, "Recall"),
    F1                = macro_average(cm$byClass, "F1"),
    stringsAsFactors  = FALSE
  )
}

# -----------------------------------------------------------------------------
# binary_metrics()
# -----------------------------------------------------------------------------
# Same idea for a BINARY problem. Here caret returns a single value per metric
# (relative to the `positive` class), so we read the named vector directly.
binary_metrics <- function(cm, model_name = "model") {
  data.frame(
    Model             = model_name,
    Accuracy          = unname(cm$overall["Accuracy"]),
    Balanced_Accuracy = unname(cm$byClass["Balanced Accuracy"]),
    Precision         = unname(cm$byClass["Precision"]),
    Recall            = unname(cm$byClass["Recall"]),
    F1                = unname(cm$byClass["F1"]),
    stringsAsFactors  = FALSE
  )
}

# -----------------------------------------------------------------------------
# plot_confusion()
# -----------------------------------------------------------------------------
# Publication-quality confusion-matrix heat map with ggplot2. Works for any
# number of classes. Counts are shown in each cell; colour encodes count.
# `cm` is a caret::confusionMatrix (we use its `$table`).
plot_confusion <- function(cm, title = "Confusion matrix") {
  cm_df <- as.data.frame(cm$table)  # columns: Prediction, Reference, Freq
  ggplot2::ggplot(cm_df,
                  ggplot2::aes(x = Reference, y = Prediction, fill = Freq)) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::geom_text(ggplot2::aes(label = Freq), size = 4) +
    ggplot2::scale_fill_gradient(low = "#F0F4FF", high = "#2C3E9E") +
    ggplot2::labs(title = title, x = "Actual class", y = "Predicted class",
                  fill = "Count") +
    theme_dungeons() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

# -----------------------------------------------------------------------------
# theme_dungeons()
# -----------------------------------------------------------------------------
# Shared ggplot2 theme so every figure in the report has a consistent,
# publication-quality look. Defined once, reused everywhere.
theme_dungeons <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position  = "right"
    )
}

# -----------------------------------------------------------------------------
# scale_with_reference()
# -----------------------------------------------------------------------------
# Apply an already-fitted caret::preProcess object to a new data frame and
# re-attach a target column. Centralises the "scale test/new data with training
# parameters" pattern used by the neural network and SVM sections, preventing
# data leakage (scaling parameters come only from the training set).
scale_with_reference <- function(pre_proc, new_data, predictors, target = NULL) {
  scaled <- predict(pre_proc, new_data[, predictors, drop = FALSE])
  if (!is.null(target)) {
    scaled[[target]] <- new_data[[target]]
  }
  scaled
}
