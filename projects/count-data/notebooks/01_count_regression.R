# Package installation
{
packages <- c(
  "ggplot2", "sandwich", "msm", "pscl", "MASS",
  "car", "lmtest", "readr", "readxl"
)
for (i in seq_along(packages)) {
  if (require(packages[i], character.only = TRUE)) {
    cat(packages[i], "loaded successfully\n")
  } else {
    cat("Trying to install", packages[i], "\n")
    install.packages(packages[i])
    if (require(packages[i], character.only = TRUE)) {
      cat(packages[i], "loaded successfully\n")
    } else {
      stop("Could not install ", packages[i])
    }
  }
}
}

# Function definitions
{
results_table <- data.frame(
  Model = character(),
  Residual_SD = numeric(),
  LogLik_Model = numeric(),
  LogLik_Null = numeric(),
  LR_Statistic = numeric(),
  LR_df = numeric(),
  LR_pvalue = numeric(),
  AIC = numeric(),
  BIC = numeric(),
  Observed_Zeros = numeric(),
  Predicted_Zeros = numeric(),
  stringsAsFactors = FALSE
)

check_zero_excess_model <- function(original_data, model, response_variable,
                                    model_name, make_plots = TRUE) {
  # =========================
  # 1. Diagnostic plots
  # =========================
  if (make_plots) {
    par(mfrow = c(1, 2), oma = c(0, 0, 4, 0))

    # Observed vs fitted
    plot(
      model$model[[response_variable]],
      model$fitted.values,
      xlab = "Observed values",
      ylab = "Fitted values",
      main = "Observed vs Fitted"
    )
    abline(a = 0, b = 1, col = "red", lwd = 2)
    legend(
      "topleft",
      legend = c("Fitted values", "Line y = x"),
      col = c("black", "red"),
      lty = c(NA, 1),
      pch = c(1, NA),
      lwd = c(NA, 2),
      bty = "n"
    )

    # Observed vs residuals
    plot(
      model$model[[response_variable]],
      model$residuals,
      xlab = "Observed values",
      ylab = "Residuals",
      main = "Observed vs Residuals"
    )

    mtext(model_name, side = 3, outer = TRUE, line = 1, cex = 1.3)
  }

  # =========================
  # 2. Dispersion measure
  # =========================
  residual_sd <- sqrt(var(model$residuals))

  # =========================
  # 3. Null model
  # =========================
  null_model <- update(model, . ~ 1)

  # =========================
  # 4. Likelihood-ratio test
  # =========================
  lr_stat <- 2 * (logLik(model) - logLik(null_model))
  df_lr <- attr(logLik(model), "df") - attr(logLik(null_model), "df")
  lr_pvalue <- pchisq(lr_stat, df = df_lr, lower.tail = FALSE)

  # =========================
  # 5. Excess zeros
  # =========================
  observed_zeros <- sum(original_data[[response_variable]] == 0)
  predicted_zeros <- sum(round(model$fitted.values) == 0)

  # =========================
  # 6. AIC and BIC
  # =========================
  aic_value <- AIC(model)
  bic_value <- BIC(model)

  # =========================
  # 7. Results data.frame
  # =========================
  results_df <- data.frame(
    Model = model_name,
    Residual_SD = residual_sd,
    LogLik_Model = as.numeric(logLik(model)),
    LogLik_Null = as.numeric(logLik(null_model)),
    LR_Statistic = as.numeric(lr_stat),
    LR_df = df_lr,
    LR_pvalue = lr_pvalue,
    AIC = aic_value,
    BIC = bic_value,
    Observed_Zeros = observed_zeros,
    Predicted_Zeros = predicted_zeros
  )

  return(results_df)
}
}

# Data extraction and preprocessing
{
# Paths are relative to the project root. Run this script from that directory.
figures_dir <- file.path("reports", "figures")
tables_dir <- file.path("reports", "tables")
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

df <- read_excel(file.path("data", "raw", "AEM_02_Count_regression_and_GAM.xlsx"))
df <- within(df, {
  factor1 <- factor(factor1)
  factor2 <- factor(factor2)
  factor3 <- factor(factor3)
})
}

# EDA
{
sum(is.na(df))

mean(df$y)
var(df$y)

max_y <- max(df$y)

# Empirical distribution
df1 <- data.frame(table(df$y))
names(df1) <- c("n_y", "Freq")
df1$n_y <- as.numeric(as.character(df1$n_y))
df1$Freq <- df1$Freq / sum(df1$Freq)
df1$Type <- "Empirical"

# Theoretical Poisson (MLE on positive counts for lambda)
lambda_hat <- mean(df$y[df$y != 0])

df2 <- data.frame(
  n_y = 0:max_y,
  Freq = dpois(0:max_y, lambda = lambda_hat),
  Type = "Poisson"
)

# Theoretical negative binomial (MLE on positive counts)
nb_fit <- fitdistr(df$y[df$y != 0], densfun = "negative binomial")

size_hat <- nb_fit$estimate["size"]
mu_hat <- nb_fit$estimate["mu"]

df3 <- data.frame(
  n_y = 0:max_y,
  Freq = dnbinom(0:max_y, size = size_hat, mu = mu_hat),
  Type = "Negative Binomial"
)

# Combine
df_final <- rbind(df1, df2, df3)
df_final

eda_plot <- ggplot(data = df_final, aes(x = n_y, y = Freq, fill = Type)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(
    title = "Empirical vs theoretical count distributions",
    x = "Count value",
    y = "Relative frequency",
    fill = "Distribution"
  ) +
  theme_minimal()

print(eda_plot)
ggsave(
  filename = file.path(figures_dir, "eda_count_distribution.png"),
  plot = eda_plot,
  width = 8,
  height = 5,
  dpi = 300
)
# Negative binomial appears to be the best option; it fits the empirical distribution well.
}

# Naming structure for models
# ZA/ZI + count dist + zero dist + _ + count covariates + _ + zero covariates
# Example: zap_x12f23_x1f3 uses x1, x2, f2, f3 in the count part and x1, f3 in the zero part

# ZA models
{
summary(zanbp_all <- hurdle(y ~ . | ., dist = "negbin", zero.dist = "poisson", data = df))

summary(zanbp_x12f3_x1235f2 <- hurdle(
  y ~ x1 + x2 + factor3 | x1 + x2 + x3 + x5 + factor2,
  dist = "negbin", zero.dist = "poisson", data = df
))

summary(zanbb_all <- hurdle(y ~ . | ., dist = "negbin", zero.dist = "binomial", data = df))
summary(zanbb_x12f3_x5 <- hurdle(
  y ~ x1 + x2 + factor3 | x5,
  dist = "negbin", zero.dist = "binomial", data = df
))

summary(zapp_all <- hurdle(y ~ . | ., dist = "poisson", zero.dist = "poisson", data = df))
summary(zapp_x123f3_x1235f2 <- hurdle(
  y ~ x1 + x2 + x3 + factor3 | x1 + x2 + x3 + x5 + factor2,
  dist = "poisson", zero.dist = "poisson", data = df
))

summary(zapb_all <- hurdle(y ~ . | ., dist = "poisson", zero.dist = "binomial", data = df))
summary(zapb_x123f3_x5 <- hurdle(
  y ~ x1 + x2 + x3 + factor3 | x5,
  dist = "poisson", zero.dist = "binomial", data = df
))
}

# ZI models
{
summary(zinb_x12f3_0f1 <- zeroinfl(
  y ~ x1 + x2 + factor3 | factor1 + -1,
  dist = "negbin", data = df
))
summary(zip_x132f3_0f1 <- zeroinfl(
  y ~ x1 + x2 + x3 + factor3 | factor1 - 1,
  dist = "poisson", data = df
))
summary(zinb_x12f3_1 <- zeroinfl(
  y ~ x1 + x2 + factor3 | 1,
  dist = "negbin", data = df
))
}

# Comparison table for all shortlisted models + diagnostics for best by AIC
{
shortlisted <- c(
  "zanbp_x12f3_x1235f2",
  "zanbb_x12f3_x5",
  "zapp_x123f3_x1235f2",
  "zapb_x123f3_x5",
  "zinb_x12f3_0f1",
  "zip_x132f3_0f1",
  "zinb_x12f3_1"
)

results_table <- results_table[0, , drop = FALSE]
for (mdl_name in shortlisted) {
  results_df <- check_zero_excess_model(
    df, get(mdl_name), "y", mdl_name, make_plots = FALSE
  )
  results_table <- rbind(results_table, results_df)
}

results_table <- results_table[order(results_table$AIC), , drop = FALSE]
rownames(results_table) <- NULL
print(results_table)

write.csv(
  results_table,
  file = file.path(tables_dir, "model_comparison.csv"),
  row.names = FALSE
)

# booktabs fragment for the LaTeX report
tex_lines <- c(
  "\\begin{tabular}{lrrrrr}",
  "\\toprule",
  "Model & Residual SD & AIC & BIC & Obs.\\ zeros & Pred.\\ zeros \\\\",
  "\\midrule"
)
for (i in seq_len(nrow(results_table))) {
  tex_lines <- c(
    tex_lines,
    sprintf(
      "\\texttt{%s} & %.2f & %.1f & %.1f & %.0f & %.0f \\\\",
      gsub("_", "\\_", results_table$Model[i], fixed = TRUE),
      results_table$Residual_SD[i],
      results_table$AIC[i],
      results_table$BIC[i],
      results_table$Observed_Zeros[i],
      results_table$Predicted_Zeros[i]
    )
  )
}
tex_lines <- c(tex_lines, "\\bottomrule", "\\end{tabular}")
writeLines(tex_lines, file.path(tables_dir, "model_comparison.tex"))

best_model_name <- results_table$Model[1]
png(
  filename = file.path(figures_dir, "diagnostics_zanbb_x12f3_x5.png"),
  width = 1200, height = 600, res = 150
)
invisible(check_zero_excess_model(
  df, get(best_model_name), "y", best_model_name, make_plots = TRUE
))
dev.off()

cat("Best model by AIC:", best_model_name, "\n")
results_table
}
