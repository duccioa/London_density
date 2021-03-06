library(sp)
        Sl = SpatialLines(list(Lines(list(Line(cbind(c(1,2,3, 4),c(3,2,2,4)))), ID="a")))
        plot(Sl)
        SplitLines(Sl, 0.1, F, T)
coordinates(Sl)


Sl = SpatialLines(list(Lines(list(Line(cbind(c(1,2,3),c(3,2,2)))),
                             ID="a")))
cSl <- coordinates(Sl)
cSl
in_nrows <- lapply(cSl, function(x) sapply(x, nrow))
outn <- sapply(in_nrows, function(y) sum(y-1))
res <- vector(mode="list", length=outn)
i <- 1
for (j in seq(along=cSl)) {
  for (k in seq(along=cSl[[j]])) {
    for (l in 1:(nrow(cSl[[j]][[k]])-1)) {
      res[[i]] <- cSl[[j]][[k]][l:(l+1),]
      i <- i + 1
    }
  }
}
res1 <- vector(mode="list", length=outn)
for (i in seq(along=res))
  res1[[i]] <- Lines(list(Line(res[[i]])), as.character(i))
outSL <- SpatialLines(res1)

library(rgeos)
coordinates(gLineMerge(outSL))
plot(outSL)
