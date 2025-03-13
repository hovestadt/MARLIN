## MARLIN

**M**ethylation- and **A**I-guided **R**apid **L**eukemia Subtype **In**ference

## Installation

Get the repository:

`git clone https://github.com/hovestadt/MARLIN`

Download [MARLIN](https://www.dropbox.com/scl/fi/d6ctg1fq5iadf6457vnx9/marlin_v1.model.hdf5?rlkey=xphliojewiip9jj3r5nybhg4q&st=3yyspo14&dl=0) (trained model) and place it inside the folder [files](MARLIN_realtime/files)

## Requirements

R (4.1.3)

R package dependencies:
keras (2.13.0)
data.table (1.14.2)
doParallel (1.0.17)
foreach (1.5.2)

Install the official Oxford Nanopore Technologies tool to extract modifications [modkit](https://github.com/nanoporetech/modkit)

## Real-time classification

MARLIN can be used to generate methylation class predictions in real-time during live basecalling. Real-time script waits for bam files and it processes them as they are produced. The files are expected to be from the same sample and they are processed cumulatively.

For details: [go to real-time folder](MARLIN_realtime)

## Training

Usage (specific CUDA device 1): `CUDA_VISIBLE_DEVICES=1 Rscript MARLIN_training.R`

## Prediction

Usage (specific CUDA device 1): `CUDA_VISIBLE_DEVICES=1 Rscript MARLIN_prediction.R`

