options(max.print = 1000)
options(stringsAsFactors = FALSE)
options(scipen = 999)

library(data.table)
library(keras)
library(openxlsx)

args = commandArgs(trailingOnly=TRUE)  # bam file name, CpG names, MARLIN model, class annotations


# load CpG names, ordered
load(args[2])

# load MARLIN model
model <- load_model_hdf5(args[3])

# read merged pileup file
bed_file <- "calls.bam.pileup.bed"
ONT_sample_pileup <- fread(bed_file)
  
# order
ONT_sample_for_pred <- ONT_sample_pileup$V4[match(betas_sub_names, ONT_sample_pileup$V5)]
  
# transform 1/-1
ONT_sample_for_pred <- ifelse(ONT_sample_for_pred >= 0.5, 1, -1)

# NA to 0, not covered CpGs
ONT_sample_for_pred[is.na(ONT_sample_for_pred)] <- 0

# predict
pred <- model %>% predict(t(matrix(ONT_sample_for_pred)))

# load annotation
class_anno <- read.xlsx(args[4])
class_anno <- class_anno[order(class_anno$model_id), ]

colnames(pred) <- class_anno$class_name_current

# write output files
save(pred, file = paste0(args[1], ".pred.RData"))

write.table(data.frame(pred, cov_cpgs=sum(ONT_sample_for_pred != 0), time=Sys.time()),
            file = paste0(args[1], ".pred.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
