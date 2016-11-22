library('RPostgreSQL')
library('data.table')
pg = dbDriver("PostgreSQL")
options(scipen=500)

#### Cleaning result data ####
#RPostgreSQL
pw = {'postgres'}
pg = dbDriver("PostgreSQL")
con = dbConnect(pg, user="postgres", password=pw, host="localhost", port=5432, dbname="msc")
rm(pw)
res = data.table(dbGetQuery(con, 'SELECT * FROM london_streetwidth.intersect_results'))
dbDisconnect(con)
dbUnloadDriver(pg)

# With doParallel
cleanData=function(res, num_cores=2){
  require(doParallel)

  iterate = function(i)
  {
    df_right = res[gid==i & side,] # Select right side
    if(nrow(df_right)==0){
      df_right=data.table(gid = i, w_avg_h = 0, iteration = 1000)}
    else{
      df_right = df_right[iteration == min(iteration),]}
    df_left = res[gid==i & !side,] # Select left side
    if(nrow(df_left)==0){
      df_left=data.table(gid = i, w_avg_h = 0, iteration = 1000)}
    else{
      df_left = df_left[iteration == max(iteration),]}

    return(c(i,
             df_right$w_avg_h,
             df_left$w_avg_h,
             df_right$iteration,
             df_left$iteration,
             df_right$iteration + abs(df_left$iteration)
    )
    )

  }
  registerDoParallel(cores=num_cores)
  t = foreach(i=unique(res$gid), .combine = 'rbind') %dopar% iterate(i)
  return(t)
}


df = data.table(cleanData(res, num_cores = 4))
df_bkcup = df # df = df_bkcup
names(df) = c('gid', 'w_avg_h_r', 'w_avg_h_l', 'width_r', 'width_l', 'width')
row.names(df) = NULL
df$width[df$width > 999] = 1000000000
df$c_ratio = ((df$w_avg_h_r + df$w_avg_h_l)/2)/df$width
write.csv(df,
          '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity/05_Data/london_streetwidth_width.csv',
          row.names = F)
