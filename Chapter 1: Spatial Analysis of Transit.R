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

# Get data from 2019

norfolk_tracts19 = get_acs(geography = "tract", variables = vars, cache_table =  TRUE, state = "VA", county = "Norfolk", geometry = TRUE, output = "wide")
vb_tracts19 = get_acs(geography = "tract", variables = vars, cache_table =  TRUE, state = "VA", county = "Virginia Beach", geometry = TRUE, output = "wide")

tracts19 = rbind(norfolk_tracts19,vb_tracts19) %>% st_transform(tracts19, crs = st_crs(tracts19)) %>%  rename(TotalPop = B01003_001E, HousingUnits = B25001_001E,'Median Housing Costs' = B25105_001E)

geo <- st_transform(tracts19$geometry, st_crs(tracts19$geometry))

# Get data from 2000
norfolk_tracts00 = get_decennial(geography = 'tract',variables = vars, year = 2000, state = "VA", county =  "Norfolk", geometry = TRUE, output = 'wide') 
vb_tracts00  
