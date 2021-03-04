#https://urbanspatial.github.io/PublicPolicyAnalytics/TOD.html#developing-tod-indicators

library(tidyverse)
library(tidycensus)
library(sf)

census_api_key("d983e58ea97d7045590dc6d049f86874fe08cf3c")

options(scipen =999)
options(tigris_class = "sf")

palette5 <- c("#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac")

vars19 <- c("B25026_001","B02001_002","B15001_050","B15001_009","B19013_001","B25058_001","B06012_002") # Variables for 2019 5yr ACS data
vars00 <- c("P001001","P006002","PCT025050","PCT025009","P053001","H056001","P092001") # Variables for 2000 decennial data

vars00_1 <- c("P006002","PCT025050","PCT025009","P053001","H056001","P092001")# Excludes the first variable for the loop I need to run later

View(load_variables(2000, "sf3", cache = TRUE))

# Get data from 2019

norfolk_tracts19 = get_acs(geography = "tract", variables = vars19, cache_table =  TRUE, state = "VA", county = "Norfolk", geometry = TRUE, output = "wide")
vb_tracts19 = get_acs(geography = "tract", variables = vars19, cache_table =  TRUE, state = "VA", county = "Virginia Beach", geometry = TRUE, output = "wide")

tracts19 = rbind(norfolk_tracts19,vb_tracts19) 
tracts19 = st_transform(tracts19, crs = st_crs(tracts19)) %>%  rename(TotalPop = B25026_001E, Whites = B02001_002E,
                                                                                                              FemaleBachelors = B15001_050E, MaleBachelors = B15001_009E,
                                                                                                              MedHHInc = B19013_001E, MedRent = B25058_001E,
                                                                                                              TotalPoverty = B06012_002E) %>% mutate(pctWhite = ifelse(TotalPop > 0, Whites / TotalPop,0),
           pctBachelors = ifelse(TotalPop > 0, ((FemaleBachelors + MaleBachelors) / TotalPop),0),
           pctPoverty = ifelse(TotalPop > 0, TotalPoverty / TotalPop, 0),
           year = "2019")

# Get data from 2000
sf3 <- load_variables(2000, "sf3", cache = T)
norfolk_tracts00 = get_decennial(geography = 'tract',cache_table =  T, variables = "P001001", year = 2000, sumfile = "SF3", state = "VA", county =  "Norfolk", geometry = TRUE, output = 'wide',keep_geo_vars =T) 

# For the life of me I can't get the 'get_decennial' to handle more than two variables at one time so I'll just run it once to initialize the dataframe then add the others in a loop
for (var in vars00_1){
  norfolk_00_var = get_decennial(geography = 'tract',cache_table =  T, variables = var, year = 2000, sumfile = "SF3", state = "VA", county =  "Norfolk", geometry = TRUE, output = 'wide', keep_geo_vars = T) 
  norfolk_tracts00[[var]] = norfolk_00_var[[var]]
}

vb_tracts00  = get_decennial(geography = 'tract',sumfile = "sf3",variables = "P001001", year = 2000, state = "VA", county =  "Virginia Beach", geometry = TRUE, output = 'wide', keep_geo_vars = T) 
# Do the same loop as above
for (var in vars00_1){
  vb_00_var = get_decennial(geography = 'tract',cache_table =  T, variables = var, year = 2000, sumfile = "SF3", state = "VA", county =  "Virginia Beach", geometry = TRUE, output = 'wide', keep_geo_vars = T) 
  vb_tracts00[[var]] = vb_00_var[[var]]
}



tracts00 = rbind(norfolk_tracts00,vb_tracts00)
tracts00 = st_transform(tracts00,crs = st_crs(tracts00))  %>%  rename(TotalPop = P001001, Whites = P006002,
                                                                      FemaleBachelors = PCT025050, MaleBachelors = PCT025009,
                                                                      MedHHInc = P053001, MedRent = H056001,
                                                                      TotalPoverty = P092001) %>% mutate(pctWhite = ifelse(TotalPop > 0, Whites / TotalPop,0),
                                                                                                             pctBachelors = ifelse(TotalPop > 0, ((FemaleBachelors + MaleBachelors) / TotalPop),0),
                                                                                                             pctPoverty = ifelse(TotalPop > 0, TotalPoverty / TotalPop, 0),
                                                                                                             year = "2000")
# Select only needed data
tracts00 <- select(tracts00, c("GEOID","NAME.y","Whites","FemaleBachelors","MaleBachelors","MedHHInc","MedRent","TotalPoverty","pctWhite","pctBachelors","pctPoverty","year")) %>% rename(NAME = NAME.y)
tracts19 <- select(tracts19, c("GEOID","NAME","Whites","FemaleBachelors","MaleBachelors","MedHHInc","MedRent","TotalPoverty","pctWhite","pctBachelors","pctPoverty","year"))
# Create a full dataframe of all both tract data
alltracts = rbind(tracts00,tracts19)
