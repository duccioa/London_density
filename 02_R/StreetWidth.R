library('RPostgreSQL')
library('data.table')
pg = dbDriver("PostgreSQL")
options(scipen=500)
pw = {'postgres'}
pg = dbDriver("PostgreSQL")
con = dbConnect(pg, user="postgres", password=pw, host="localhost", port=5432, dbname="msc")
rm(pw)
res = data.table(dbGetQuery(con, 'SELECT * FROM london_streetwidth.test_lines'))
dbDisconnect(con)
dbUnloadDriver(pg)

# Analyse resutls
summary(as.factor(df$width))
hist(df[width < 1000, width],
     xlab = 'metres',
     main = 'Frequency of street width  \nLondon CAZ',
     xlim = c(0, 30),
     breaks = 20)
summary(df$c_ratio)
hist(df[c_ratio < quantile(c_ratio, .99), c_ratio],
     breaks = 50,
     xlab = 'H/W ratio',
     main = 'Canyon ratio by segment of road \nLondon CAZ')
abline(v = median(df$c_ratio), col = 'red')

