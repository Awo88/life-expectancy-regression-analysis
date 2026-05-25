# ─────────────────────────────────────────────────────────────────────────────
# WHO Life Expectancy — Multiple Linear Regression Analysis
# Author: Adebola Awokoya
# Course Project — Applied Regression Analysis
#
# Uses the WHO Global Health Observatory dataset to model life expectancy
# as a function of GDP, schooling, HIV/AIDS burden, and adult mortality.
# Analysis is restricted to the year 2015 (153 complete observations).
#
# Data: Life Expectancy Data.csv (WHO Global Health Observatory)
# Install: install.packages(c("ggplot2","dplyr","GGally","car","lmtest"))
# ─────────────────────────────────────────────────────────────────────────────

library(ggplot2)
library(dplyr)
library(GGally)
library(car)
library(lmtest)

# ── 1. DATA LOADING & CLEANING ────────────────────────────────────────────────

df_raw <- read.csv("Life Expectancy Data.csv", stringsAsFactors = FALSE)

# Filter to 2015; keep only variables of interest
df <- df_raw %>%
  filter(Year == 2015) %>%
  select(
    Life.expectancy,
    GDP,
    Schooling,
    HIV.AIDS,
    Adult.Mortality
  ) %>%
  na.omit()

cat(sprintf("Observations after cleaning: %d\n\n", nrow(df)))

# ── 2. EXPLORATORY DATA ANALYSIS ─────────────────────────────────────────────

# Summary statistics
cat("── Summary Statistics ──────────────────────────────────────────────────\n\n")
print(summary(df))

# Correlation matrix
cat("\n── Correlation Matrix ──────────────────────────────────────────────────\n\n")
print(round(cor(df), 3))

# ── EDA Plots ─────────────────────────────────────────────────────────────────

# Histogram of response
p_hist <- ggplot(df, aes(x = Life.expectancy)) +
  geom_histogram(bins = 20, fill = "#0F3460", color = "white", alpha = 0.85) +
  labs(title = "Distribution of Life Expectancy (2015)",
       x = "Life Expectancy (years)", y = "Frequency") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave("01_histogram_life_expectancy.png", p_hist, width = 6, height = 4, dpi = 150)

# Scatterplots: each predictor vs Life Expectancy
predictors <- c("GDP", "Schooling", "HIV.AIDS", "Adult.Mortality")
pred_labels <- c("GDP per Capita (USD)", "Mean Years of Schooling",
                 "HIV/AIDS Deaths per 1,000", "Adult Mortality per 1,000")

scatter_plots <- lapply(seq_along(predictors), function(i) {
  ggplot(df, aes_string(x = predictors[i], y = "Life.expectancy")) +
    geom_point(color = "#0F3460", alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", color = "#E94560", se = TRUE, linewidth = 0.9) +
    labs(title = paste("Life Expectancy vs", pred_labels[i]),
         x = pred_labels[i], y = "Life Expectancy (years)") +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(face = "bold"))
})

for (i in seq_along(scatter_plots)) {
  fname <- sprintf("02_scatter_%s.png", tolower(predictors[i]))
  ggsave(fname, scatter_plots[[i]], width = 5, height = 4, dpi = 150)
}
cat("EDA plots saved.\n")

# Pairs plot
png("03_pairs_plot.png", width = 900, height = 900, res = 120)
ggpairs(df,
        lower  = list(continuous = wrap("points", alpha = 0.4, size = 0.8, color = "#0F3460")),
        diag   = list(continuous = wrap("densityDiag", fill = "#E94560", alpha = 0.5)),
        upper  = list(continuous = wrap("cor", size = 3.5)),
        title  = "Pairs Plot — WHO Life Expectancy Dataset (2015)")
dev.off()
cat("Pairs plot saved.\n\n")

# ── 3. MULTIPLE LINEAR REGRESSION ────────────────────────────────────────────

model <- lm(Life.expectancy ~ GDP + Schooling + HIV.AIDS + Adult.Mortality, data = df)

cat("── Model Summary ───────────────────────────────────────────────────────\n\n")
print(summary(model))

# Confidence intervals for coefficients
cat("\n── 95% Confidence Intervals ────────────────────────────────────────────\n\n")
print(confint(model))

# ── 4. REGRESSION DIAGNOSTICS ────────────────────────────────────────────────

cat("\n── Variance Inflation Factors (Multicollinearity) ──────────────────────\n\n")
print(vif(model))

# Breusch-Pagan test for heteroscedasticity
cat("\n── Breusch-Pagan Test (Homoscedasticity) ───────────────────────────────\n\n")
print(bptest(model))

# Diagnostic plots
png("04_diagnostics.png", width = 1000, height = 900, res = 120)
par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
plot(model, which = 1, main = "Residuals vs Fitted",   col = "#0F3460", pch = 16, cex = 0.7)
plot(model, which = 2, main = "Normal Q-Q",            col = "#0F3460", pch = 16, cex = 0.7)
plot(model, which = 3, main = "Scale-Location",        col = "#0F3460", pch = 16, cex = 0.7)
plot(model, which = 5, main = "Residuals vs Leverage", col = "#0F3460", pch = 16, cex = 0.7)
par(mfrow = c(1, 1))
dev.off()
cat("Diagnostic plots saved.\n")

# ── 5. COEFFICIENT PLOT ───────────────────────────────────────────────────────

coef_df <- as.data.frame(confint(model))
coef_df$Estimate <- coef(model)
coef_df$Term     <- rownames(coef_df)
colnames(coef_df)[1:2] <- c("Lower", "Upper")
coef_df <- coef_df[coef_df$Term != "(Intercept)", ]

p_coef <- ggplot(coef_df, aes(x = Estimate, y = reorder(Term, Estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = Lower, xmax = Upper),
                 height = 0.25, color = "#0F3460", linewidth = 0.8) +
  geom_point(size = 4, color = "#E94560") +
  labs(title = "Regression Coefficients with 95% Confidence Intervals",
       subtitle = "Response: Life Expectancy (years)",
       x = "Coefficient Estimate", y = "") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave("05_coefficient_plot.png", p_coef, width = 7, height = 4, dpi = 150)
cat("Coefficient plot saved.\n")

# ── 6. ACTUAL vs PREDICTED ────────────────────────────────────────────────────

df$Fitted    <- fitted(model)
df$Residuals <- residuals(model)

p_fit <- ggplot(df, aes(x = Fitted, y = Life.expectancy)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(color = "#0F3460", alpha = 0.65, size = 2) +
  labs(title = "Actual vs Fitted Life Expectancy",
       subtitle = sprintf("R² = %.3f", summary(model)$r.squared),
       x = "Fitted Values (years)", y = "Actual Life Expectancy (years)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave("06_actual_vs_fitted.png", p_fit, width = 6, height = 5, dpi = 150)
cat("Actual vs fitted plot saved.\n\n")

# ── 7. KEY RESULTS SUMMARY ───────────────────────────────────────────────────

s <- summary(model)
cat("── Key Results ─────────────────────────────────────────────────────────\n\n")
cat(sprintf("R-squared:          %.4f\n", s$r.squared))
cat(sprintf("Adjusted R-squared: %.4f\n", s$adj.r.squared))
cat(sprintf("F-statistic:        %.2f  (p < 0.001)\n", s$fstatistic[1]))
cat(sprintf("Residual Std Error: %.3f years\n", s$sigma))
cat(sprintf("Observations:       %d\n", nrow(df)))
cat("\nDone. All plots saved to working directory.\n")
