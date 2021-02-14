
rm(list=ls())

#---------------- Importing the Libraries ---------------------------------------

library(lme4) 
library(lmtest)
library(lubridate)
library(readxl)
library(dplyr)
library(stargazer)
library(plyr)
library(tidyr)
library(MASS)
library(Car)
library(AER)

#---------------- Import Data ---------------------------------------------------
#---------------- Importing stores data into a dataframe -------------------------

df.products = read_excel("RetailChain.xlsx", sheet="products")
colnames(df.products) = tolower(make.names(colnames(df.products)))
attach(df.products)
summary(df.products)
nrow(df.products)
ncol(df.products)

#---------------- Importing stores data into a dataframe -------------------------

df.stores = read_excel("RetailChain.xlsx", sheet="stores")
colnames(df.stores) = tolower(make.names(colnames(df.stores)))
attach(df.stores)
summary(df.stores)
nrow(df.stores)
ncol(df.stores)

#---------------- Importing transactions data into a dataframe -------------------------

df.trans = read_excel("RetailChain.xlsx", sheet="transactions")
colnames(df.trans) = tolower(make.names(colnames(df.trans)))
attach(df.trans)
summary(df.trans)
nrow(df.trans)
ncol(df.trans)

#---------------------- Merging all 3 datasets --------------------------------

names(df.stores)[names(df.stores) == "store_id"] <- "store_num"

df.temp.merge = join(df.trans , df.products,  
                      type = "inner")   #inner join trans and products table using upc

master.dataset = join(df.temp.merge, df.stores,
                      type = "inner")     #inner products table using store_num
names(master.dataset)
nrow(master.dataset)
ncol(master.dataset)

#------------------ Checking if there are any blank values in the master data frame -------------------

colSums(is.na(master.dataset)) #checking if the columns has blank/missing values
master.dataset = master.dataset[!(is.na(master.dataset$price) | master.dataset$price==""), ] #dropping blank/missing values from price column
master.dataset = master.dataset[!(is.na(master.dataset$base_price) | master.dataset$base ==""), ] #dropping blank/missing values from base_price column
master.dataset$parking[is.na(master.dataset$parking)] = median(master.dataset$parking, na.rm=TRUE) #replacing missing values in parking column with median 
colSums(is.na(master.dataset)) #verifying if the missing values have been removed

df_filtered <- subset( master.dataset, category != "ORAL HYGIENE PRODUCTS")

#-------------------- Spliting date column into year, month and day ----------------------------------

df_filtered$year = year(ymd(df_filtered$week_end_date))
df_filtered$month = month(ymd(df_filtered$week_end_date)) 
df_filtered$day = day(ymd(df_filtered$week_end_date))
df_filtered$week = week(ymd(df_filtered$week_end_date))

#------------------------ Converting categorical variables into factor --------------------------------

df_filtered$store_num <- factor(df_filtered$store_num)
df_filtered$upc <- factor(df_filtered$upc)
df_filtered$feature <- factor(df_filtered$feature)
df_filtered$display <- factor(df_filtered$display)
df_filtered$tpr_only <- factor(df_filtered$tpr_only)
df_filtered$manufacturer <- factor(df_filtered$manufacturer)
df_filtered$category <- factor(df_filtered$category)
df_filtered$sub_category <- factor(df_filtered$sub_category)
df_filtered$segment <- factor(df_filtered$segment)
df_filtered$city <- factor(df_filtered$city)
df_filtered$week <- factor(df_filtered$week)
df_filtered$upc <- factor(df_filtered$upc)

#------------------------------------ Exploratory Data Analysis -------------------------------------

plot(spend ~ week, title="Spend vs Week", data=df_filtered)
plot(units ~ week, title="Units vs Week", data=df_filtered)
plot(hhs ~ week, title="HHS vs Week", data=df_filtered)
hist(log(units))
hist(log(hhs))

#--------Set of Models for infering effects of feature, display and tpr on spend by category and segment -----------------------------------------------------------------

#I have built this model to predict marginal effect of feature, display and hhs on spend

model_spend_1 <- lm(spend ~ feature + tpr_only + display + price + visits + hhs + units
                    + category*feature + category*display + category*tpr_only 
                    + segment*feature + segment*display + segment*tpr_only 
                    + price*upc, data=df_filtered)
summary(model_spend_1)


#I have built this model to infer products with highest and lowest spend. 

model_spend_2 <- lmer(spend ~ feature + tpr_only + display + price + visits + hhs + units
                    + category + segment
                    + (1 | upc) , data=df_filtered)
summary(model_spend_2)
AIC(model_spend_2)
fixef(model_spend_2)                                       # Magnitude of fixed effect
ranef(model_spend_2)                                       # Magnitude of random effect

#---------------------------- Set of Models for infering effects of feature, display and tpr on units ----------------
#I have built this model to note marginal of feature, display and TPR with product category and store segment on units sold 

qpoisson <- glm(units ~ feature + tpr_only + display + visits + log(hhs) + price
                  + category*feature + category*display + category*tpr_only 
                  + segment*feature + segment*display + segment*tpr_only, 
                  family=quasipoisson (link=log), data=df_filtered)
summary(qpoisson)

#checking for assumptions

dispersiontest(qpoisson)  
car::vif(qpoisson)

#I have built this model to infer products with highest and lowest units sold. 

model_units_2 <- lmer(units ~ feature + tpr_only + display + price + visits + hhs + price
                      + category + segment
                      + (1 | upc) , data=df_filtered)


summary(model_units_2)
AIC(model_units_2)
fixef(model_units_2)                                       # Magnitude of fixed effect
ranef(model_units_2)                                       # Magnitude of random effect

#---------------------------- Set of Models for infering effects of feature, display and tpr on hhs ----------------
##I have built this model to note marginal of feature, display and TPR with product category and store segment on household purchasers.  

qpoisson_hhs <- glm(hhs ~ feature + tpr_only + display + visits + spend
                + category*feature + category*display + category*tpr_only 
                + segment*feature + segment*display + segment*tpr_only, 
                family=quasipoisson (link=log), data=df_filtered)

summary(qpoisson_hhs)

#checking for assumptions
dispersiontest(qpoisson_hhs)  
car::vif(qpoisson_hhs)

#stargazer o/p
stargazer(model_spend_1, qpoisson, qpoisson_hhs, type="text", single.row = TRUE)
