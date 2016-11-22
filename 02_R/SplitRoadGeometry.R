library('rgdal')
library('RPostgreSQL')
library('rpostgis')
library('sptools')
library('data.table')
pg = dbDriver("PostgreSQL")
#### Split geometry ####
# RpostGIS
# Fetch regular geometry
con = dbConnect(pg, user="postgres", password="postgres", host="localhost", port=5432, dbname="msc")
road_geom = pgGetGeom(con, name = c('london_streetwidth', 'caz_roads'), geom = 'geom', gid = 'edge_id')
dbDisconnect(con)
# Split geometry and write the shp file
road_geom_split = SplitLines(road_geom, 10, return.dataframe =  F, plot.results =  F)
road_geom_split_df = SplitLines(road_geom, 10, return.dataframe =  T, plot.results =  F)
proj4string(road_geom_split) = CRS("+init=epsg:27700")
SLDF = SpatialLinesDataFrame(road_geom_split,
                             data.frame(id=road_geom_split_df$id, row.names = road_geom_split_df$id))
writeOGR(SLDF,
         dsn = '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity/05_Data/StreetWidth',
         layer = 'caz_road_geom_split',
         overwrite_layer = T,
         driver="ESRI Shapefile")
