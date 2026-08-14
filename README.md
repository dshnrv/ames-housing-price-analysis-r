## Overview

This project analyzes the relationship between housing characteristics and residential sale prices using the **Ames Housing Dataset**.

The main research question is:

> **Which housing characteristics have the strongest relationship with residential sale prices?**

The analysis was conducted in **R** and includes data preparation, exploratory data analysis (EDA), outlier analysis, correlation analysis, and multiple regression modeling.

## Dataset

The project uses the **Ames Housing Dataset**, which contains detailed information about residential properties in Ames, Iowa, including structural characteristics, location variables, sale conditions, and final sale prices.

The outcome variable used in the analysis is:

* `SalePrice` — final sale price of the house

The main explanatory variables include:

* `LotArea` — lot size
* `YearBuilt` — original construction year
* `GrLivArea` — above-ground living area
* `TotalBsmtSF` — total basement area
* `GarageArea` — garage area
* `YrSold` — year of sale
* `EnclosedPorch` — enclosed porch area
* `Neighborhood` — physical location within Ames, Iowa

## Analysis

### 1. Data Preparation

The dataset was inspected and prepared for analysis. Selected variables were checked for missing values, and no missing observations were found among the variables used in the analysis.

Several categorical variables were initially examined. `Neighborhood` was retained for exploratory analysis because location may capture differences in housing value across areas.

### 2. Exploratory Data Analysis

Exploratory data analysis was performed to examine the distribution of housing prices and relationships between property characteristics and `SalePrice`.

The analysis included:

* summary statistics;
* missing-value analysis;
* sale price distribution;
* outlier detection using the IQR method;
* log transformation of `SalePrice`;
* neighborhood comparison;
* visualization of relationships between housing characteristics and sale prices.

The original `SalePrice` distribution was strongly right-skewed and contained several high-value outliers. A logarithmic transformation produced a more symmetric distribution.

### 3. Correlation Analysis

Correlation analysis was used to evaluate the strength of linear relationships between housing characteristics and sale prices.

The strongest positive correlations with `SalePrice` were:

* `GrLivArea`: approximately **0.66**
* `GarageArea`: approximately **0.61**
* `YearBuilt`: approximately **0.56**
* `TotalBsmtSF`: approximately **0.54**

`LotArea` showed a weaker positive relationship, while `YrSold` had almost no correlation with housing prices. `EnclosedPorch` showed a weak negative relationship.

### 4. Regression Analysis

Multiple regression analysis was used to estimate the simultaneous relationship between housing characteristics and sale prices.

The initial model included all selected numeric explanatory variables. `YrSold` was statistically insignificant, while `EnclosedPorch` showed only weak significance, so they were excluded from the reduced model.

The reduced model included:

* `LotArea`
* `YearBuilt`
* `GrLivArea`
* `TotalBsmtSF`
* `GarageArea`

Both a **multiple linear regression model** and a **log-linear regression model** were estimated.

The log-linear specification provided the better overall fit.

## Key Findings

The analysis suggests that:

* **Above-ground living area (`GrLivArea`)** has the strongest positive relationship with sale prices.
* **Garage area (`GarageArea`)** is also strongly associated with higher housing prices.
* Newer houses generally have higher sale prices.
* Larger basement areas are associated with higher property values.
* Housing prices differ substantially across neighborhoods.
* The log-transformed specification provides a better representation of the relationship between housing characteristics and sale prices than the initial linear model.

## Tools & Libraries

The analysis was performed in **R** using packages including:

* `dplyr`
* `ggplot2`
* `tidyr`
* `corrplot`
* `Hmisc`
* `car`
* `scales`
* `readr`
* `knitr`
* `kableExtra`

## Skills Demonstrated

`R` · `Data Cleaning` · `Exploratory Data Analysis` · `Data Visualization` · `Statistical Analysis` · `Correlation Analysis` · `Multiple Regression` · `ggplot2` · `dplyr`
