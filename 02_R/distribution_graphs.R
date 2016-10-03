library(data.table)
source('/Users/duccioa/CLOUD/01_Cloud/01_Work/02_DataScience/02_Functions/R/FUN_add_alpha.R')
root_dir = '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity'

#### Blocks Data
blocks = fread(paste0(root_dir, '/05_Data/00_DbDump/block_h350.csv'), stringsAsFactors = F)
blocks$caz = gsub("t", "1", blocks$caz)
blocks$caz = gsub("f", "0", blocks$caz)
blocks$caz = as.logical(as.numeric(blocks$caz))

#### Blocks GSI distribution ####
hist_col = 'mediumslateblue'
hist_border = 'white'
cex_main = 2.2
cex_axis = 1.8
cex_lab = 2
hist_mar = c(6,6,6,2)
hist_ylim = c(0,5)
lwd_median = 2

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/dist_gsi_caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(blocks$gsi[blocks$caz== TRUE])
hist(blocks$gsi[blocks$caz== TRUE & blocks$gsi>quantile(blocks$gsi, 0.025)],
     breaks = 20,
     freq = F,
     ylim = hist_ylim,
     col = hist_col,
     border = hist_border,
     main = 'London within CAZ \nGSI Frequency Distribution',
     xlab = 'GSI',
     ylab = 'Occurrence'
     ) # CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 0.8, y = 3.5,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
     )
dev.off()

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/dist_gsi_no-caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(blocks$gsi[blocks$caz== FALSE])
hist(blocks$gsi[blocks$caz== FALSE & quantile(blocks$gsi, 0.025)],
     breaks = 20,
     freq = F,
     ylim = hist_ylim,
     col = hist_col,
     border = hist_border,
     main = 'London outside CAZ \nGSI Frequency Distribution',
     xlab = 'GSI',
     ylab = 'Occurence'
) # no CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 0.8, y = 3.5,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
     )
dev.off()

#### Blocks FAR distribution ####
hist_col = 'lightsalmon'
hist_border = 'white'
cex_main = 2.2
cex_axis = 1.8
cex_lab = 2
hist_mar = c(6,6,6,2)
hist_ylim = c(0,5)
hist_xlim1 = c(0,12)
hist_xlim2 = c(0,12)
lwd_median = 2

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/dist_far_h300_caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(blocks$fsi_h300[blocks$caz== TRUE])
hist(blocks$fsi_h300[blocks$caz== TRUE],
     breaks = 50,
     freq = F,
     #ylim = yhist_lim,
     xlim = hist_xlim1,
     col = hist_col,
     border = hist_border,
     main = 'London within CAZ \nFAR Frequency Distribution',
     xlab = 'FAR',
     ylab = 'Occurence'
) # CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 6, y = 0.18,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
)
dev.off()

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/dist_far_h300_no-caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(blocks$fsi_h300[blocks$caz== FALSE])
hist(blocks$fsi_h300[blocks$caz== FALSE],
     breaks = 50,
     freq = F,
     #ylim = yhist_lim,
     xlim = hist_xlim2,
     col = hist_col,
     border = hist_border,
     main = 'London outside CAZ \nFAR Frequency Distribution',
     xlab = 'FAR',
     ylab = 'Occurence'
) # no CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 6, y = 1,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
)
dev.off()


#### Blocks Correlation plots ####
lm1 = lm(fsi_h300 ~ gsi, blocks)
summary(lm1)
lm2 = lm(fsi_h300 ~ gsi, blocks[blocks$caz == T,])
summary(lm2)
lm3 = lm(fsi_h300 ~ gsi, blocks[blocks$caz == F,])
summary(lm3)
sample_index = sample(1:nrow(blocks), floor(nrow(blocks)/5))
block_sample = blocks[sample_index,]

scat_col = add.alpha('mediumslateblue', 0.4)
scat_pch = 19
scat_cex = 0.5
scat_xlim = c(0,1)
scat_ylim = c(0,5)
scat_mar = c(5,6,8,2)
cex_main = 2.2
cex_axis = 1.8
cex_lab = 2
cex_sum1 = 2
cex_sum2 = 2




png(paste0(root_dir, '/03_Figures/20160919_LondonDensity/gsi_far_h300_gl.png'), width = 1000, height = 1200)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab,
    mar = scat_mar
    )
layout(matrix(c(1,1,2,2), 2, 2, byrow = T), heights = c(5,1))
with(blocks[gsi > quantile(blocks$gsi, 0.025)],
plot(gsi, fsi_h300,
     pch = scat_pch,
     col = scat_col,
     cex = scat_cex,
     ylim = scat_ylim,
     xlim = scat_xlim,
     main = 'Greater London \nGSI v. FAR \navg floor to floor height 300 cm',
     xlab = 'GSI',
     ylab = 'FAR',
     frame.plot = F
     )
)
text(x = 0.8, y = 4, labels = paste0('Corr. \n', round(cor(blocks$gsi, blocks$fsi_h300),2)), col = 'red', cex = 2.5)
par(mar = c(0.2,6,0.2,2))
plot(x = c(0,1), y = c(0,1/5), type = 'n', axes = F, xlab="", ylab="")
text(x = 0.5, y = 0.15, labels = 'Summary FAR', cex = cex_sum1)
scat_text = summary(blocks$fsi_h300)
scat_text_x1 = c(0, 1/5, 2/5, 3/5, 4/5, 1)
scat_text_y1 = 0.09
text(x = scat_text_x1, y = scat_text_y1, labels = names(scat_text), cex = cex_sum2)
scat_text_y2 = 0.06
text(x = scat_text_x1, y = scat_text_y2, labels = round(scat_text, 2), cex = cex_sum2)
dev.off()




png(paste0(root_dir, '/03_Figures/20160919_LondonDensity/gsi_far_h300_caz.png'), width = 1000, height = 1200)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab,
    mar = scat_mar
)
layout(matrix(c(1,1,2,2), 2, 2, byrow = T), heights = c(5,1))
with(blocks[gsi > quantile(blocks$gsi, 0.025) & caz == T],
     plot(gsi, fsi_h300,
          pch = scat_pch,
          col = scat_col,
          cex = scat_cex,
          ylim = scat_ylim,
          xlim = scat_xlim,
          main = 'London within CAZ\nGSI v. FAR \navg floor to floor height 300 cm',
          xlab = 'GSI',
          ylab = 'FAR',
          frame.plot = F
     )
)
text(x = 0.8, y = 4, labels = paste0('Corr. \n', round(cor(blocks[caz==T]$gsi, blocks[caz==T]$fsi_h300),2)), col = 'red', cex = 2.5)
par(mar = c(0.2,6,0.2,2))
plot(x = c(0,1), y = c(0,1/5), type = 'n', axes = F, xlab="", ylab="")
text(x = 0.5, y = 0.15, labels = 'Summary FAR', cex = cex_sum1)
scat_text = summary(blocks[caz==T]$fsi_h300)
scat_text_x1 = c(0, 1/5, 2/5, 3/5, 4/5, 1)
scat_text_y1 = 0.09
text(x = scat_text_x1, y = scat_text_y1, labels = names(scat_text), cex = cex_sum2)
scat_text_y2 = 0.06
text(x = scat_text_x1, y = scat_text_y2, labels = round(scat_text, 2), cex = cex_sum2)
dev.off()


png(paste0(root_dir, '/03_Figures/20160919_LondonDensity/gsi_far_h300_no-caz.png'), width = 1000, height = 1200)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab,
    mar = scat_mar
)
layout(matrix(c(1,1,2,2), 2, 2, byrow = T), heights = c(5,1))
with(blocks[gsi > quantile(blocks$gsi, 0.025) & caz == F],
     plot(gsi, fsi_h300,
          pch = scat_pch,
          col = scat_col,
          cex = scat_cex,
          ylim = scat_ylim,
          xlim = scat_xlim,
          main = 'London outside CAZ \nGSI v. FAR \navg floor to floor height 300 cm',
          xlab = 'GSI',
          ylab = 'FAR',
          frame.plot = F
     )
)
text(x = 0.8, y = 4, labels = paste0('Corr. \n', round(cor(blocks[caz==F]$gsi, blocks[caz==F]$fsi_h300),2)), col = 'red', cex = 2.5)
par(mar = c(0.2,6,0.2,2))
plot(x = c(0,1), y = c(0,1/5), type = 'n', axes = F, xlab="", ylab="")
text(x = 0.5, y = 0.15, labels = 'Summary FAR', cex = cex_sum1)
scat_text = summary(blocks[caz==F]$fsi_h300)
scat_text_x1 = c(0, 1/5, 2/5, 3/5, 4/5, 1)
scat_text_y1 = 0.09
text(x = scat_text_x1, y = scat_text_y1, labels = names(scat_text), cex = cex_sum2)
scat_text_y2 = 0.06
text(x = scat_text_x1, y = scat_text_y2, labels = round(scat_text, 2), cex = cex_sum2)
dev.off()


#### Plots Data ####
plots = fread(paste0(root_dir, '/05_Data/00_DbDump/plot_cluster_labels.csv'), stringsAsFactors = F)
plots[, geom_plot := NULL]
plots$caz = gsub("t", "1", plots$caz)
plots$caz = gsub("f", "0", plots$caz)
plots[, cax := as.logical(as.numeric(caz))]
plots[, label := as.factor(label)]

#### Plots GSI distribution ####
hist_col = 'mediumslateblue'
hist_border = 'white'
cex_main = 2.2
cex_axis = 1.8
cex_lab = 2
hist_mar = c(6,6,6,2)
hist_ylim = c(0,3.5)
lwd_median = 2

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/plots_dist_gsi_caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(plots$gsi[plots$caz== TRUE])
hist(plots$gsi[plots$caz== TRUE & plots$gsi>quantile(plots$gsi, 0.01)],
     breaks = 20,
     freq = F,
     ylim = hist_ylim,
     col = add.alpha(hist_col, 0.7),
     border = hist_border,
     main = 'London parcels within CAZ \nGSI Frequency Distribution',
     xlab = 'GSI',
     ylab = 'Occurrence'
) # CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 0.6, y = 2.5,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
)
dev.off()

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/plots_dist_gsi_no-caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(plots$gsi[plots$caz== FALSE])
hist(plots$gsi[plots$caz== FALSE & plots$gsi>quantile(plots$gsi, 0.01)],
     breaks = 20,
     freq = F,
     ylim = hist_ylim,
     col = add.alpha(hist_col, 0.7),
     border = hist_border,
     main = 'London parcels outside CAZ \nGSI Frequency Distribution',
     xlab = 'GSI',
     ylab = 'Occurrence'
) # no-CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 0.6, y = 2.5,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
)
dev.off()

#### Plots FAR distribution ####
hist_col = 'lightsalmon'
hist_border = 'white'
cex_main = 2.2
cex_axis = 1.8
cex_lab = 2
hist_mar = c(6,6,6,2)
hist_ylim = c(0,5)
hist_xlim1 = c(0,12)
hist_xlim2 = c(0,6)
lwd_median = 2

png(paste0(root_dir, '/03_Figures/160920_LondonDensity/plots_dist_far_caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(plots$fsi[plots$caz== TRUE])
hist(plots$fsi[plots$caz== TRUE],
     breaks = 50,
     freq = F,
     #ylim = yhist_lim,
     xlim = hist_xlim1,
     col = hist_col,
     border = hist_border,
     main = 'London parcles within CAZ \nFAR Frequency Distribution',
     xlab = 'FAR',
     ylab = 'Occurence'
) # CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 6, y = 0.18,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
)
dev.off()


png(paste0(root_dir, '/03_Figures/160920_LondonDensity/plots_dist_far_no-caz.png'), width = 1000, height = 1000)
par(cex.main = cex_main, cex.axis = cex_axis, cex.lab = cex_lab, mar = hist_mar)
m = median(plots$fsi[plots$caz== FALSE])
hist(plots$fsi[plots$caz== FALSE],
     breaks = 100,
     freq = F,
     #ylim = yhist_lim,
     xlim = hist_xlim2,
     col = hist_col,
     border = hist_border,
     main = 'London parcles outside CAZ \nFAR Frequency Distribution',
     xlab = 'FAR',
     ylab = 'Occurence'
) # NO-CAZ
abline(v = m, col = 'red', lwd = lwd_median)
text(x = 3, y = 0.3,
     labels = paste0( 'median = ', round(m, 2)),
     col = 'red',
     cex  = 2
)
dev.off()





