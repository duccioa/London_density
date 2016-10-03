library(data.table)
library(dplyr)
root_dir = '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity'
bh_true = data.table(read.csv(paste0(root_dir, '/05_Data/BuildingHeight_error_estimation/BuildingHeight_check.csv'), stringsAsFactors = F))
bh_model = fread(paste0(root_dir, '/05_Data/BuildingHeight_error_estimation/buildings.csv'))
bh_model[ ,c('wkb_geometry', 'fid', 'geom_centroids') := NULL]
bh_test = inner_join(bh_model, bh_true)


attach(bh_test)
error_per300 = round(abs(n_floors-nfloors_real)/nfloors_real, 3)
error_per350 = round(abs(n_floors350-nfloors_real)/nfloors_real, 3)
detach(bh_test)
sd(error_per300)
sd(error_per350)
summary(error_per300)
summary(error_per350)
hist(error_per300, breaks = 30)
hist(error_per350, breaks = 30)
