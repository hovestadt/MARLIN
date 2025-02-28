options(max.print = 1000)
options(stringsAsFactors = FALSE)
options(scipen = 999)

library(data.table)

args = commandArgs(trailingOnly=TRUE)  # CpG positions


## CpG annotations
# load
a <- fread(args[1], select = c("V1", "V2", "V4"))
names(a) <- c("chrom", "ref_position", "probe_id")
# a

# collapse by strand
a2 <- a[, list(chrom=unique(as.numeric(sub("chr", "", chrom))), chromStart=min(ref_position), chromEnd=max(ref_position)+1), by="probe_id"]
# a2


## methylation calls from modkit pileup (many files)
# list files
lf <- list.files(path=".", pattern = "pileup$")
# lf
message(length(lf), " pileup files found")

# read files
d <- rbindlist(lapply(lf, fread, select=c("V1", "V2", "V10", "V12")))  # rbind all the individual files, only read chr, pos, total coverage, and mod coverage
names(d) <- c("chrom", "ref_position", "cov_valid", "cov_mod")
# d


## merge with annotations
da <- merge(d, a, by=c("chrom", "ref_position"))  # add probe_id

da.merge <- da[, list(beta=sum(cov_mod)/sum(cov_valid)), by="probe_id"]  # calculate the beta value for each probe_id
# da.merge

da.merge.full <- merge(a2, da.merge, by="probe_id", all.x=TRUE)[order(chrom, chromStart), .(chrom, chromStart, chromEnd, beta, probe_id)]  # merge back with collapsed probe annotations to create final table
# da.merge.full


## write cumulative output bed file (overwrite previous file, these are large)
fwrite(da.merge.full, file="calls.bam.pileup.bed", sep="\t", quote=FALSE, row.names = FALSE, col.names = FALSE, na = "NA")  # output bed file: chr, start, end, beta, name/cg
