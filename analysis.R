# -----------------------------------------------------------------------
# Packages
# -----------------------------------------------------------------------

library(knitr)
library(kableExtra)
library(openxlsx)
library(ggplot2)
library(readr)
library(dplyr)
library(outliers)
library(corrplot)
library(Hmisc)
library(scales)
library(tidyr)
library(car)

# -----------------------------------------------------------------------
# Data Preparation
# -----------------------------------------------------------------------

housing <- read_csv("housing.csv")

housing <- dplyr::mutate_if(housing, is.character, as.factor)

summary(housing$Utilities)
summary(housing$Neighborhood)
summary(housing$SaleCondition)
summary(housing$PoolQC)

housing = housing |> dplyr::select(SalePrice, LotArea, YearBuilt, YrSold, GrLivArea, TotalBsmtSF, GarageArea, EnclosedPorch, Neighborhood)

variable_description <- tibble(
  Variable = c(
    "SalePrice", "LotArea", "GrLivArea", "TotalBsmtSF",
    "GarageArea", "OpenPorchSF", "EnclosedPorch",
    "YearBuilt", "YrSold", "Neighborhood"
  ),
  Description = c(
    "Final sale price of the house",
    "Lot size in square feet",
    "Above-ground living area in square feet",
    "Total basement area in square feet",
    "Garage area in square feet",
    "Open porch area in square feet",
    "Enclosed porch area in square feet",
    "Original construction year",
    "Year in which the house was sold",
    "Physical location within Ames, Iowa"
  ),
  Role = c(
    "Dependent variable",
    rep("Explanatory variable", 8),
    "Categorical variable for EDA"
  )
)


variable_description |>
  kable(
    caption = "Table 1. Description of selected variables",
    booktabs = TRUE
  ) |>
  kable_classic(full_width = FALSE)

# -----------------------------------------------------------------------
# Exploratory Data Analysis
# -----------------------------------------------------------------------

#Missing values

housing |>
  summarise(across(everything(), ~ sum(is.na(.)))) |>
  pivot_longer(
    cols = everything(),
    names_to = "Variable",
    values_to = "Missing values"
  ) |>
  kable(
    caption = "Table 2. Missing values in selected variables",
    booktabs = TRUE
  ) |>
  kable_classic(full_width = FALSE)

#Summary statistics for the selected numeric variables

housing |>
  dplyr::select(-Neighborhood) |>
  summarise(
    across(
      everything(),
      list(
        mean = ~ mean(.x, na.rm = TRUE),
        median = ~ median(.x, na.rm = TRUE),
        sd = ~ sd(.x, na.rm = TRUE),
        min = ~ min(.x, na.rm = TRUE),
        max = ~ max(.x, na.rm = TRUE)
      )
    )
  ) |>
  pivot_longer(
    cols = everything(),
    names_to = c("Variable", ".value"),
    names_sep = "_"
  ) |>
  kable(
    caption = "Table 3. Summary statistics for selected numeric variables",
    digits = 2,
    booktabs = TRUE
  ) |>
  kable_classic(full_width = FALSE)

# Boxplot of house sale prices based on the original data

boxplot(housing$SalePrice, ylab = 'Sale Price, $', col = 'thistle2')

#Sale price distribution histogram

ggplot(housing, aes(x = housing$SalePrice)) + 
  geom_histogram(
    aes(y = ..density..),
    color = "black",
    fill = 'thistle2'
  ) + 
  geom_line(
    aes(
      x = housing$SalePrice,
      y = dnorm(
        housing$SalePrice,
        mean = mean(housing$SalePrice),
        sd = sd(housing$SalePrice)
      )
    ),
    lwd = 1,
    col = "orchid4"
  ) +
  ylab("Density") +
  xlab("Sale Price, $"
) +
  theme_minimal()

#Distribution of Log-Transformed Sale Prices

ggplot(
  housing,
  aes(x = log(SalePrice))
) +
  geom_histogram(
    bins = 30,
    fill = "thistle2",
    color = "black"
  ) +
  ylab("Distribution of Log-Transformed Sale Prices") +
  xlab("log(SalePrice)"
  ) +
  theme_minimal()

paste('Skewness coefficient: As = ', round(DescTools::Skew(housing$SalePrice), 3))
paste('Kurtosis coefficient: Ek = ', round(DescTools::Kurt(housing$SalePrice), 3))

paste('Interquartile range: IQR = Q3 - Q1 = ', IQR(housing$SalePrice))

out_of_1.5IQR <- boxplot.stats(housing$SalePrice)$out
out_of_1.5IQR

#Boxplot of house sale prices after cleaning

options(scipen = 999)
housing1 <- housing |> filter(housing$SalePrice < min(out_of_1.5IQR))
boxplot(housing1$SalePrice, ylab = 'Sale Price, $', col = 'thistle2')

#Number of observations by neighborhood

housing |>
  count(Neighborhood, sort = TRUE) |>
  kable(
    caption = "Table 4. Number of observations by neighborhood",
    booktabs = TRUE
  ) |>
  kable_classic(full_width = FALSE)

#Sale Price Distribution by Neighborhood

ggplot(housing1, aes(x = reorder(Neighborhood, SalePrice, median), y = SalePrice)) +
  geom_boxplot() +
  coord_flip() +
  scale_y_continuous(labels = dollar) +
    xlab("Neighborhood") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Average Sale Price by Construction Year

housing1 |>
  group_by(YearBuilt) |>
  summarise(
    mean_price = mean(SalePrice)
  ) |>
  ggplot(aes(x = YearBuilt, y = mean_price)) +
  geom_line(color = "orchid4", linewidth = 1) +
  scale_y_continuous(labels = scales::dollar) +
    xlab("Year Built") +
    ylab("Average Sale Price"
  ) +
  theme_minimal()

#Sale Price Distribution by Year of Sale

ggplot(
  housing1,
  aes(
    x = factor(YrSold),
    y = SalePrice
  )
) +
  geom_boxplot(fill = "thistle2") +
  scale_y_continuous(labels = scales::dollar) +
    xlab("Year of Sale") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Living Area Across Sale Price Quartiles

housing1 <- housing1 |>
  mutate(
    price_group = ntile(SalePrice, 4)
  )
ggplot(
  housing1,
  aes(
    x = factor(price_group),
    y = GrLivArea
  )
) +
  geom_boxplot(fill = "thistle2") +
    xlab("Sale Price Quartile") +
    ylab("Above-Ground Living Area"
  ) +
  theme_minimal()

#Basement Area, Garage Area, and Sale Price

ggplot(
  housing1 |> filter(TotalBsmtSF < 6000),
  aes(
    x = TotalBsmtSF,
    y = GarageArea,
    color = SalePrice
  )
) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(
    low = "thistle1",
    high = "orchid4",
    labels = scales::dollar
  ) +
  labs(
    x = "Total Basement Area",
    y = "Garage Area",
    color = "Sale Price"
  ) +
  theme_minimal()

#Sale Price and Above-Ground Living Area

ggplot(housing1, aes(x = GrLivArea, y = SalePrice)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, col = "orchid4") +
  scale_y_continuous(labels = dollar) +
    xlab("Above-Ground Living Area") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Sale Price and Basement Area

ggplot(housing1, aes(x = TotalBsmtSF, y = SalePrice)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, col = "orchid4") +
  scale_y_continuous(labels = dollar) +
    xlab("Total Basement Area") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Sale Price and Garage Area

ggplot(housing1, aes(x = GarageArea, y = SalePrice)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, col = "orchid4") +
  scale_y_continuous(labels = dollar) +
    xlab("Garage Area") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Sale Price and Lot Area

ggplot(housing1, aes(x = LotArea, y = SalePrice)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, col = "orchid4") +
  scale_y_continuous(labels = dollar) +
    xlab("Lot Area") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Sale Price and Enclosed Porch Area

ggplot(housing1, aes(x = EnclosedPorch, y = SalePrice)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, col = "orchid4") +
  scale_y_continuous(labels = dollar) +
    xlab("Enclosed Porch Area") +
    ylab("Sale Price"
  ) +
  theme_minimal()

#Sale Price and Year Built

ggplot(housing1, aes(x = YearBuilt, y = SalePrice)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, col = "orchid4") +
  scale_y_continuous(labels = dollar) +
    xlab("Year Built") +
    ylab("Sale Price"
  ) +
  theme_minimal()

# -----------------------------------------------------------------------
# Correlation Analysis
# -----------------------------------------------------------------------

#Correlation Matrix

h1 <- housing1[, 1:8]
res <- cor.mtest(h1, conf.level = 0.95)
corrplot(cor(h1), p.mat = res$p, sig.level = 0.05, tl.col = "black", col = COL2('PuOr', 10), tl.srt = 45, tl.cex = 0.5) 

cor_h1 <- cor(h1, method = "pearson")
kbl(caption = "Table 5. Matrix of pairwise correlation coefficients", cor_h1, booktabs = T) |> 
  kable_classic(html_font = "Cambria", font_size = 12, full_width = F)

# -----------------------------------------------------------------------
# Multiple Regression Analysis
# -----------------------------------------------------------------------

#The initial regression model includes all selected explanatory variables:

housing2 <- housing1[, 1:8]

lm1 <- lm(SalePrice ~ ., data = housing2)
summary(lm1)

#The reduced multiple regression model is therefore estimated using only statistically significant predictors:

options(scipen = 999)
lm2 <- lm(SalePrice ~ LotArea + YearBuilt + GrLivArea + TotalBsmtSF + GarageArea, housing2)
summary(lm2)

vif_model_lm2 <- lm2
vif(vif_model_lm2)

#Predicted and observed values for the reduced linear model are compared below:

pred <- predict(lm2)

ggplot(housing2, aes(x = pred, y = housing2$SalePrice)) + geom_point() + geom_abline(intercept = 0, slope = 1, color = "orchid4") + labs(x = 'Predicted Values', y = 'Observed Values')

lm3 <- lm(log(SalePrice) ~ LotArea + YearBuilt + GrLivArea + TotalBsmtSF + GarageArea, housing2)
pred3 <- predict(lm3)

summary(lm3)

vif_model_lm3 <- lm3
vif(vif_model_lm3)

#Predicted and Observed Values for the Linear Model

ggplot(housing2, aes(x = pred3, y = SalePrice)) + 
  geom_point() + 
  geom_smooth(method = "lm", formula = y ~ exp(x), color = "orchid") + labs(x = 'Predicted Values', y = 'Observed Values')