library('RPostgreSQL')
library('rgdal')
library('rpostgis')
library('stplanr')
source('/Users/duccioa/CLOUD/01_Cloud/01_Work/02_DataScience/02_Functions/R/FUN_dbSafeNames.R')
source('/Users/duccioa/CLOUD/01_Cloud/01_Work/02_DataScience/02_Functions/R/FUN_SplitLines.R')
pg = dbDriver("PostgreSQL")

# Read table from database
con = dbConnect(pg, user="postgres", password="postgres", host="localhost", port=5432, dbname="msc")
dtab = dbGetQuery(con, "select geom from london_streetwidth.roads")
roads = dbReadTable(con, "london_streetwidth.roads")
dbDisconnect(con)
# RpostGIS
con = dbConnect(pg, user="postgres", password="postgres", host="localhost", port=5432, dbname="msc")
road_geom = pgGetGeom(con, name = c('london_streetwidth', 'roads'), geom = 'geom', gid = 'edge_id')
building_geom = pgGetGeom(con, name = c('london_streetwidth', 'buildings'), geom = 'wkb_geometry', gid = 'ogc_fid')
dbDisconnect(con)
plot(road_geom)
plot(building_geom)

##
SplitLines(road_geom)

## Check real geometry against lines2df
plot(road_geom)
for( i in 1:nrow(linedf)){
line_coords = cbind(as.numeric(linedf$fx[i]), as.numeric(linedf$fy[i]))
line_coords = rbind(line_coords, cbind(as.numeric(linedf$tx[i]), as.numeric(linedf$ty[i])))
line_test = Line(line_coords)
Ls1 = Lines(list(line_test), ID = "a")
SL1 = SpatialLines(list(Ls1))
#plot(road_geom)
plot(SL1, col='red', lwd = 2,add=T)
}
