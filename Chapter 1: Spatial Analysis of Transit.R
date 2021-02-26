#https://urbanspatial.github.io/PublicPolicyAnalytics/TOD.html#developing-tod-indicators

library(tidyverse)
library(tidycensus)
library(sf)

census_api_key("d983e58ea97d7045590dc6d049f86874fe08cf3c")

options(scipen =999)
options(tigris_class = "sf")

palette5 <- c("#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac")

View(load_variables(2000, "sf3"))

test = get_acs(geography = "tract", table = "B25034_001", cache_table =  TRUE, state = "VA", county = "Montgomery", geometry = TRUE)
test1 = test %>% select(geometry, estimate)
plot(test1)

geo <- st_transform(test$geometry)