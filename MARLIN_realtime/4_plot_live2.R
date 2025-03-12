options(max.print = 1000)
options(stringsAsFactors = FALSE)
options(scipen = 999)

library(data.table)
library(openxlsx)

args = commandArgs(trailingOnly=TRUE)  # bam file name, class annotations


## load class annotations
class_anno <- read.xlsx(args[2])
rownames(class_anno) <- gsub(" ", ".", gsub(":", ".", gsub("-", ".", gsub("&", ".", gsub("/", ".", class_anno$class_name_current)))))


## load predictions
lf <- list.files(pattern = ".pred.txt$")
lf

# sort by time
d <- rbindlist(lapply(lf, fread))
d$time <- as.POSIXct(d$time)
d <- d[order(d$time)]

# last time point
dd <- unlist(d[nrow(d), .SD, .SDcols=rownames(class_anno)])


## plot
pdf(paste0(args[1], ".pred.pdf"), width = 12, height = 16)
par(mfrow=c(4, 2))
par(oma=c(8, 2, 4, 2))
par(mar=c(4, 4, 4, 4))

# coverage
plot(d$time, d$cov_cpgs, ylim=c(0, max(d$cov_cpgs)), type="b", pch=16, col="darkgrey", main="Coverage", xlab="Time", ylab="Number of CpGs")
plot(d$time, d$cov_cpgs/357340, ylim=c(0, 1), type="b", pch=16, col="darkgrey", xlab=NA, ylab="Fraction of CpGs")


# lineage
a.lin <- split(rownames(class_anno), class_anno$lineage)[unique(class_anno$lineage)]
a.lin.col <- sapply(split(class_anno$color_lineage, class_anno$lineage), unique)

plot(d$time, rep(NA, nrow(d)), ylim=c(0, 1), main="Lineage", xlab=NA, ylab="Prediction score")
for(i in names(a.lin)) {
  y <- rowSums(d[, .SD, .SDcols=a.lin[[i]]])
  lines(d$time, y, type="b", pch=16, col=a.lin.col[i])
  if(any(y>=0.8)) text(d$time[min(which(y>=0.8))], y[min(which(y>=0.8))], labels = i, col=a.lin.col[i], pos=2)
}
abline(h=0.8, col="grey", lty=2)

barplot(sapply(a.lin, function(i) sum(dd[i])), ylim=c(0, 1), col=a.lin.col[names(a.lin)], las=2, ylab="Prediction score", xlim=c(0.2, 50.4))
abline(h=0.8, col="grey", lty=2)


# methylation family
a.fam <- split(rownames(class_anno), class_anno$mcf)[unique(class_anno$mcf)]
a.fam.col <- sapply(split(class_anno$color_mcf, class_anno$mcf), unique)

plot(d$time, rep(NA, nrow(d)), ylim=c(0, 1), main="Methylation family", xlab=NA, ylab="Prediction score")
for(i in names(a.fam)) {
  y <- rowSums(d[, .SD, .SDcols=a.fam[[i]]])
  lines(d$time, y, type="b", pch=16, col=a.fam.col[i])
  if(any(y>=0.8)) text(d$time[min(which(y>=0.8))], y[min(which(y>=0.8))], labels = i, col=a.fam.col[i], pos=2)
}
abline(h=0.8, col="grey", lty=2)

barplot(sapply(a.fam, function(i) sum(dd[i])), ylim=c(0, 1), col=a.fam.col[names(a.fam)], las=2, ylab="Prediction score", xlim=c(0.2, 50.4))
abline(h=0.8, col="grey", lty=2)


# methylation class
a.cla <- split(rownames(class_anno), class_anno$class_name_current)[unique(class_anno$class_name_current)]
a.cla.col <- sapply(split(class_anno$color_mc, class_anno$class_name_current), unique)

plot(d$time, rep(NA, nrow(d)), ylim=c(0, 1), main="Methylation class", xlab=NA, ylab="Prediction score")
for(i in names(a.cla)) {
  y <- rowSums(d[, .SD, .SDcols=a.cla[[i]]])
  lines(d$time, y, type="b", pch=16, col=a.cla.col[i])
  if(any(y>=0.8)) text(d$time[min(which(y>=0.8))], y[min(which(y>=0.8))], labels = i, col=a.cla.col[i], pos=2)
}
abline(h=0.8, col="grey", lty=2)

barplot(sapply(a.cla, function(i) sum(dd[i])), ylim=c(0, 1), col=a.cla.col[names(a.cla)], las=2, ylab="Prediction score", xlim=c(0.2, 50.4))
abline(h=0.8, col="grey", lty=2)

dev.off()

