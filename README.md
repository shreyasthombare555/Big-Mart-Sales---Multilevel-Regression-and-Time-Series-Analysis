# Big Mart Sales Multilevel Regression Analysis

**Business Value:** Accomplished Multilevel Regression analysis of Big Mart Sales dataset which aimed at forecasting sales, seasonality metrics, and recommending strategies to the business retailers by identifying top price elastic products and best performing outlet types.

# Project Overview

**i) Data Description**

Big Mart Sales dataset - Contained data pertaining to the 10 different stores and 1559 products in multiple cities. 

Retail Chain - This file contains real sales and promotions data from a large retail chain (of 79 stores) on 58 products belong to four product categories (bagged snacks, cold cereal, frozen pizza, and oral hygiene products) from multiple manufacturers like Frito Lay, Kellogg, and General Mills, over a period of 156 weeks. The data comes from three database tables: stores, products, and transactions, as shown in different tabs in the spreadsheet. It has over 500,000 transactions. 

**ii) Action Plan**

**Level 1 **

Preprocessed data by executing Non-linear Transformations, data standardization, feature engineering, and accomplished Multi-level regression analysis with a goal of recommending business entrepreneurs/retailers considering franchising one or more stores of this retail chain.  

**1) What type of outlet will return him the best sales: Grocery store or Supermarket Type 1, 2, or 3?

Looking at the random effect coefficients we can infer that Supermarket Type 3 outlet type has 1755.6492 more sales
than the mean. Hence Supermarket Type 3 is the best performing outlet type in the data.

On the other hand Grocery store has 1717.9362 less sales than the mean which is least among all outlet types hence
Grocery store is least performing outlet type among all other outlet types.

**2) What type of city will return him the best sales: Tier 1, 2 or 3?**

Looking at the random effect coefficients we can infer that City Type Tier 2 has highest item sales of approximately 323.05 higher than the mean.

On the other hand City Type Tier 1 has lowest item sales of approximately 289.75 lower than the mean.

**3) What are the top 3 highest performing and lowest performing stores in the sample?****

Looking at the random effect coefficients we can infer that Outlets OUT027, OUT046, OUT035 are top 3 performing outlets with sales 1775.68, 691.34 and 374.06 more than the mean of the random effect variable.

Outlets OUTO10, OUT019, OUTO45 are least performing outlets with sales 1700.83, 1065.414 and 275.4 less than the mean of the random effect variable.

**Level 2 **

The transaction table has weekly information on price and promotions of products. I scrutinized the effects of these pricing and promotion strategies on total spend for that product, number of households who purchased that product, and the number of store visits.

My analysis aimed at answering the following questions - (_Please refer the report for the recommendations and interpretations_)

**1) What is the effect of promotions, displays, or being featured in the circular on product sales (spend), unit sales, and number of household purchasers?**

**2) How do the above effects vary by product categories (cold cereals, frozen pizza, bag snacks) and store segments (mainstream, upscale, value)?**

**3) What are the five most price elastic and five least price elastic products? Price elasticity is the change in sales for unit change in product price?**

**4) As the retailer, which products would you lower the price to maximize (a) product sales and (b) unit sales, and why?**






