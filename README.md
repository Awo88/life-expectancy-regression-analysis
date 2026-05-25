# WHO Life Expectancy — Multiple Linear Regression Analysis

Models life expectancy across countries using economic, educational, and health indicators from the WHO Global Health Observatory. Restricted to 2015 data for cross-sectional comparability.

-----

## Research Question

Which factors — economic development, education, or disease burden — best explain differences in life expectancy across countries?

-----

## Dataset

**Source:** WHO Global Health Observatory — [Life Expectancy Data](https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who)  
**Year:** 2015 only (most complete cross-section)  
**Observations:** 153 countries after removing missing values

|Variable         |Description                                    |
|-----------------|-----------------------------------------------|
|`Life.expectancy`|Life expectancy at birth (years) — **response**|
|`GDP`            |GDP per capita (USD)                           |
|`Schooling`      |Mean years of schooling                        |
|`HIV.AIDS`       |HIV/AIDS deaths per 1,000 population           |
|`Adult.Mortality`|Adult mortality rate per 1,000 (ages 15–60)    |

-----

## Model

**Multiple Linear Regression:**

$$\text{Life Expectancy} = \beta_0 + \beta_1(\text{GDP}) + \beta_2(\text{Schooling}) + \beta_3(\text{HIV.AIDS}) + \beta_4(\text{Adult Mortality}) + \varepsilon$$

### Results

|Predictor      |Estimate |p-value|Direction      |
|---------------|---------|-------|---------------|
|Intercept      |56.54    |< 0.001|Baseline       |
|GDP            |0.0000043|0.098  |Positive (weak)|
|Schooling      |1.524    |< 0.001|Strong positive|
|HIV/AIDS       |−0.903   |< 0.001|Negative       |
|Adult Mortality|−0.029   |< 0.001|Negative       |

- **R² ≈ 0.81** — the model explains ~81% of variation in life expectancy
- **Schooling** is the strongest positive predictor: each additional year of education is associated with ~1.5 more years of life expectancy
- **Adult mortality** and **HIV/AIDS burden** are both significantly negative
- **GDP** shows a positive effect but is not significant at the 5% level after controlling for other factors

-----

## Output Files

|File                              |Description                                       |
|----------------------------------|--------------------------------------------------|
|`01_histogram_life_expectancy.png`|Distribution of the response variable             |
|`02_scatter_*.png`                |Scatterplots for each predictor vs life expectancy|
|`03_pairs_plot.png`               |Full pairs plot with correlations                 |
|`04_diagnostics.png`              |Residuals vs Fitted, Q-Q, Scale-Location, Leverage|
|`05_coefficient_plot.png`         |Coefficient estimates with 95% CIs                |
|`06_actual_vs_fitted.png`         |Predicted vs actual values                        |

-----

## Installation & Usage

```r
install.packages(c("ggplot2", "dplyr", "GGally", "car", "lmtest"))
```

Place `Life Expectancy Data.csv` in the working directory, then:

```r
source("life_expectancy_regression.R")
```

Dataset available at: <https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who>

-----

## Limitations

- Cross-sectional (2015 only) — no time trends
- Observational study: results show association, not causation
- Missing variables: healthcare access, nutrition, political stability

-----

*Author: Adebola Awokoya — Applied Regression Analysis — Towson University, December 2025*
