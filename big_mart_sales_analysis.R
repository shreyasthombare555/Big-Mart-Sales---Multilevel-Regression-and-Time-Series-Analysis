rm(list=ls())
#----------------importing data-----------------------------------------------------------
library(readxl)
master.dataset = read_excel("BigMartSales.xlsx")

#---------------Data Preprocessing -------------------------------------------------------

#converting columns names to lower case. 
colnames(master.dataset) = tolower(make.names(colnames(master.dataset)))
attach(master.dataset)
summary(master.dataset)
nrow(master.dataset)
ncol(master.dataset)

#Removing missing values
#replacing missing values with median for numerical variables (median for item_weight)
#and with mode for categorical variables. (mode for outlet_size)

colnames(master.dataset)[colSums(is.na(master.dataset)) > 0]
master.dataset$item_weight[is.na(master.dataset$item_weight)] <- median(master.dataset$item_weight, na.rm=TRUE)
colSums(is.na(master.dataset))

names(table(master.dataset$outlet_size))[table(master.dataset$outlet_size)==max(table(master.dataset$outlet_size))]
master.dataset$outlet_size[is.na(master.dataset$outlet_size)] <- 'Medium'
colSums(is.na(master.dataset))

#---------------------Feature Engineering---------------------------------------------------------

#renaming 'low fat' to Low Fat to make it consistent
master.dataset$item_fat_content[master.dataset$item_fat_content == "low fat" ] <- "Low Fat"
master.dataset$itemprice_perweight = master.dataset$item_mrp/master.dataset$item_weight
master.dataset$store_years_of_operation = 2013 - master.dataset$outlet_year

#converting categorical variables into factor
master.dataset$item_fat_content <- factor(master.dataset$item_fat_content)
levels(master.dataset$item_fat_content)
master.dataset$item_id <- factor(master.dataset$item_id)
levels(master.dataset$item_id)
master.dataset$item_type <- factor(master.dataset$item_type)
levels(master.dataset$item_type)
master.dataset$outlet_size <- factor(master.dataset$outlet_size)
levels(master.dataset$outlet_size)
master.dataset$city_type <- factor(master.dataset$city_type)
levels(master.dataset$city_type)
master.dataset$outlet_type <- factor(master.dataset$outlet_type)
levels(master.dataset$outlet_type)
master.dataset$outlet_id <- factor(master.dataset$outlet_id)
levels(master.dataset$outlet_id)

#-------------Exploratory Data Analysis------------------------------------------------------

library(lattice)
histogram(~item_sales, data=master.dataset)                        
densityplot(~item_sales | outlet_size, data=master.dataset)
densityplot(~item_sales | city_type, data=master.dataset)
densityplot(~item_sales | outlet_type, data=master.dataset)

bwplot(item_sales ~ city_type, data=master.dataset)

xyplot(item_sales ~ item_visibility | outlet_size, data=master.dataset)
xyplot(item_sales ~ item_visibility | outlet_type, data=master.dataset)
xyplot(item_sales ~ outlet_id, data=master.dataset)

#------------------------------Standarddizing independent variables----------------------------------
library(standardize)
master.dataset$itemprice_perweight <- scale(master.dataset$itemprice_perweight)[, 1]
master.dataset$item_visibility <- scale(master.dataset$item_visibility)[, 1]
master.dataset$item_mrp <- scale(master.dataset$item_mrp)[, 1]

#-----------------------------Model Building-------------------------------------------------------
#I have built 3 models for each question. 
#viewed coefficients and confidence interval for the best model only to decrease the length of the code.

#1) What type of outlet will return him the best sales: Grocery store or Supermarket Type 1, 2, or 3.

library(lme4) 
re1 <- lmer(item_sales~ (1 | outlet_type), data=master.dataset)
summary(re1)
AIC(re1)
fixef(re1)                                       
ranef(re1)                                       

re2 <- lmer(item_sales~item_visibility + itemprice_perweight + store_years_of_operation + (1 | outlet_type), data=master.dataset, REML=FALSE)
summary(re2)
fixef(re2)                                       
ranef(re2)                                       

re3 <- lmer(item_sales~ item_fat_content + item_visibility + itemprice_perweight + store_years_of_operation 
            + outlet_size +(1 | outlet_type), data=master.dataset, REML=FALSE)
summary(re3)
confint(re3)
AIC(re3)
fixef(re3)                                      
ranef(re3)                                       
coef(re3)  

library(stargazer)
stargazer(re1, re2, re3, type = "text")

#Considering Logic and Residual Variance in all 3 models, I believe model 3 worked best for me in this case.
#Hence I have mentioned its summary in the word document. 

#2)What type of city will return him the best sales: Tier 1, 2 or 3. 

ct1 <- lmer(item_sales~ 1 + (1 | city_type), data=master.dataset)
summary(ct1)
fixef(ct1)                                      
ranef(ct1)                                       
 
ct2 <- lmer(item_sales~item_visibility + itemprice_perweight + outlet_size + 
             (1 | city_type), data=master.dataset, REML=FALSE)
summary(ct2)
fixef(ct2)                                       
ranef(ct2)                                    

ct3 <- lmer(item_sales~ itemprice_perweight  + store_years_of_operation + item_type + outlet_size + 
            + item_visibility + (1 | city_type), data=master.dataset, REML=FALSE)
summary(ct3)
confint(ct3)
AIC(ct3)
fixef(ct3)                               
ranef(ct3)                                      
coef(ct3)  

stargazer(ct1, ct2, ct3, type = "text")

#Considering Logic and Residual Variance in all 3 models, I believe model 3 worked best for me in this case.
#Hence I have mentioned its summary in the word document. 

#3) What are the top 3 highest performing and lowest performing stores in the sample.

strel1 <- lmer(item_sales~ 1 + (1 | outlet_id), data=master.dataset)
summary(strel1)
fixef(strel1)                                 
ranef(strel1)                                    

strel2 <- lmer(item_sales~ item_visibility + outlet_type + store_years_of_operation  
               + itemprice_perweight + outlet_size + (1 | outlet_id), data=master.dataset, REML=FALSE)
summary(strel2)
fixef(strel2)                                       
ranef(strel2)                                      
 
strel3 <- lmer(item_sales~ itemprice_perweight + item_fat_content + item_visibility 
               + item_type + outlet_size + city_type + (1 | outlet_id), data=master.dataset, REML=FALSE)
summary(strel3)
confint(strel3)
AIC(strel3)
fixef(strel3)                                     
ranef(strel3)                                       
coef(strel3)  

stargazer(strel1, strel2, strel3, type = "text")

#Considering Logic and Residual Variance in all 3 models, I believe model 3 worked best for me in this case.
#Hence I have mentioned its summary in the word document. 

#stargazer output of 3 best models. 
stargazer(re2, ct3, strel3, type = "text")
 
