#####
# Script for training of the MARLIN classifier,
# as in Steinicke, Benfatto, et al., manuscript in preparation
#
# The neural-network architecture is composed of three fully connected layers:
# the input layer has input size 357,340, equal to the number of high-quality CpGs sites of the reference cohort.
# the first two layers have 256 and 128 nodes, respectively, with sigmoid activation.
# the final layer is composed of 42 nodes, representing the 42 methylation class, with softmax activation.
# During the training phases a dropout rate of 0.99 was applied to the input layer within each epoch.
# Categorical cross-entropy was used as a multiclass-classification loss function.
# Beta-values of the methylation array cohort were binarized to -1 and +1 with a beta-value cut-off of 0.5.
# The model was trained using 50 randomly selected samples per methylation class (with replacement) for 3,000 epochs
# with a batch size of 32, a learning rate of 10^-5 and Adam optimizer.
#
# Salvatore Benfatto (salvatore_benfatto@dfci.harvard.edu)
# Hovestadt lab, Dana-Farber Cancer Institute
# 4 Nov 2024
#
#
# Usage (specific CUDA device 1): CUDA_VISIBLE_DEVICES=1 Rscript MARLIN_training.R

options(max.print = 1000)
options(stringsAsFactors = FALSE)
options(scipen = 999)

library(data.table)
library(keras)


## load reference
load("betas.RData")  # beta values matrix
load("y.RData")      # class labels
samples_anno <- fread("training_samples.txt")  # sample annotations

dim(betas)  # 2356 samples x 357340 features
table(y)    # 42 classes

# merge peripheral blood controls
y <- as.character(y)
y <- ifelse(grepl("^PB", y) == TRUE, "PB controls", y)
y <- as.factor(y)

# transform beta-values to 1 -1 
betas_sub <- ifelse(betas >=0.5, 1, -1) # binarization

# add column for class
betas_sub <- cbind(betas_sub, y)
colnames(betas_sub)[ncol(betas_sub)] <- "class"

# annotation
betas_anno_sub <- unique(data.table(id = as.numeric(y), class=y))[order(id)]

rm(betas)  # not needed anymore
gc()

betas_sub <- data.table(betas_sub)
head(colnames(betas_sub))
tail(colnames(betas_sub))

# function to flip x% of the elements in a vector
flip_x_percent <- function(x, x_percent) {
  # Check that x_percent is between 0 and 1
  if (x_percent <= 0 | x_percent > 1) {
    stop("x_percent must be between 0 and 1")
  }
  
  # Select x_percent of indices randomly
  sample_indices <- sample(1:length(x), x_percent * length(x))
  
  # Flip the corresponding elements
  x[sample_indices] <- -x[sample_indices]
  
  return(x)
}


## prepare dataset
# upsample for equal number of samples per class
set.seed(100)
betas_sub_up <- betas_sub[,.SD[sample(.N, 50, replace = TRUE)], by = class]  # 50 random samples for each class
setcolorder(betas_sub_up, colnames(betas_sub))

betas_sub_up <- as.matrix(betas_sub_up)
table(betas_sub_up[,ncol(betas_sub_up)]) # 50 samples for each class

# flip 10% of cpgs
set.seed(100)
betas_sub_up[,-ncol(betas_sub_up)] <- t(apply(betas_sub_up[,-ncol(betas_sub_up)],1, flip_x_percent, x_percent = 0.1))

# 0-based classes
betas_sub_up[,ncol(betas_sub_up)] <- betas_sub_up[,ncol(betas_sub_up)]-1

# create training matrix
x_train <- betas_sub_up[,1:(ncol(betas_sub_up)-1)]
y_train <- to_categorical(betas_sub_up[,ncol(betas_sub_up)]) # class vector to binary class matrix

dim(x_train)  # 2100 samples x 357340 features
table(y_train)


## train neural network
message("Training")
# creating the model
model <- keras_model_sequential()
model %>%
  layer_dropout(rate = 0.99, input_shape = ncol(x_train)) %>% # input layer - 357340 nodes
  layer_dense(units = 256, activation = "sigmoid") %>% # hidden layer
  layer_dense(units = 128, activation = "sigmoid") %>% # hidden layer
  layer_dense(units = 42, #number of classes
              activation = "softmax") # output layer
summary(model)

# compiling the model
model %>% compile(loss = loss_categorical_crossentropy(),
                  optimizer = optimizer_adam(learning_rate = 0.00001),
                  metrics = list(metric_precision(), metric_recall()))

message(paste("Start training ", Sys.time()))

# train
history <- model %>% 
  fit(x_train,
      y_train,
      epoch = 3000,
      batch_size = 32,
      shuffle = TRUE
  )

# save model and training history
save_model_hdf5(model, file=file.path("nn.model.hdf5"))
save(history, file=file.path("nn.model.history.RData"))

