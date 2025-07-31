#####
# Script for predicting methylation classes using MARLIN
# as in Steinicke, Benfatto, et al., manuscript in preparation
#
# The script takes in input multiple files (one for each sample) containing the
# methylation calls of CpGs restricted to positions of probes in our reference.
# Values are binarized and missing values are set to zero.
# The output is a matrix with the prediction scores:
# N rows (samples) x 42 columns (methylation classes)
# 
# Salvatore Benfatto (salvatore_benfatto@dfci.harvard.edu)
# Hovestadt lab, Dana-Farber Cancer Institute
# 4 Nov 2024
#
# Usage (specific CUDA device 1): CUDA_VISIBLE_DEVICES=1 Rscript MARLIN_prediction.R

options(max.print = 1000)
options(stringsAsFactors = FALSE)
options(scipen = 999)

library(doParallel)
library(foreach)
library(data.table)
library(openxlsx)
library(keras)

# load Illumina array probes names
load("betas_names.RData")

# list files with the methylation calls
dir <- list.files("/", pattern="*.bed", recursive=TRUE, full.names = TRUE)

# read files in parallel
detectCores()
registerDoParallel(24) # adjust 

ONT_sample_for_pred.list <- foreach(i=dir, .final = function(x) setNames(x, dir)) %dopar% {
  
  # read file with methylation calls
  ONT_sample_pileup <- fread(i)
  
  # check probes order
  ONT_sample_for_pred <- ONT_sample_pileup$V4[match(betas_sub_names, ONT_sample_pileup$V5)]
  
  # transform 1/-1
  ONT_sample_for_pred <- ifelse(ONT_sample_for_pred >= 0.5, 1, -1) # binarization
  
  # NA to 0, not covered CpGs
  ONT_sample_for_pred[is.na(ONT_sample_for_pred)] <- 0
  
  return(ONT_sample_for_pred)
  
}

stopImplicitCluster()


# load MARLIN model
model <- load_model_hdf5("marlin_v1.model.hdf5")

# convert to matrix
ONT_sample_for_pred.mtx <- do.call(rbind, ONT_sample_for_pred.list)

# predict samples
pred <- model %>% predict(ONT_sample_for_pred.mtx)

# load annotation
class_anno <- read.xlsx("Methylation_classes_annotation.xlsx")
class_anno <- class_anno[order(class_anno$model_id), ]
                                    
# set rownames and colnames
rownames(pred) <- names(ONT_sample_for_pred.list)
colnames(pred) <- class_anno$Methylation.class

# save predictions
save(pred,  file = "predictions.RData")

