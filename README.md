## MARLIN

**M**ethylation- and **A**I-guided **R**apid **L**eukemia Subtype **In**ference

MARLIN is a deep neural network model for DNA methylation-based Acute Leukemia classification from sparse DNA methylation profiles.

For more information please refer to our paper.

## Installation

Get the repository:

`git clone https://github.com/hovestadt/MARLIN`

Download [MARLIN](https://zenodo.org/records/15565404?token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImZhOGI3ZmNmLTdhN2UtNGUyMC1hODliLTFjNWJkYmQ3Njg4YiIsImRhdGEiOnt9LCJyYW5kb20iOiJkMjgzMTAxYzQ3NmNlZGZmNDIyOTAyMWUzNDU0NDA3MSJ9.wdFZUVpWxvIFmzETC3TeM10JyPslr7IZmQBYMmE3-cZVV7jtNuORqdMte2He-2376ro9n6_kZ3hAhJK-JCLGfw) (trained model)
and the human genome assembly [hg19](http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/)

Place them inside the folder [files](MARLIN_realtime/files)

hg38 and t2t human genome assemblies are now supported, please find probes coordinates in [files](MARLIN_realtime/files) and change the reference accordingly.

## Requirements

R (4.1.3)

R package dependencies:
keras (2.13.0)
data.table (1.14.2)
doParallel (1.0.17)
foreach (1.5.2)

Conda environment setup:

`conda create --name marlin -c conda-forge r-base=4.1.3`
`conda activate marlin`
`conda install -c conda-forge r-keras=2.13 r-tensorflow=2.13 tensorflow-gpu=2.13 python=3.10`

The official Oxford Nanopore Technologies tool to extract DNA modifications [modkit](https://github.com/nanoporetech/modkit)

## Real-time classification

MARLIN can be used to generate methylation class predictions in real-time during live basecalling. Real-time script waits for bam files and it processes them as they are produced. The files are expected to be from the same sample and they are processed cumulatively.

For details: [go to the real-time folder](MARLIN_realtime)

## shinyMARLIN (currently in beta version!)

The webapp shinyMARLIN allows users to upload genome-wide methylation calls to generate Acute Leukemia methylation class predictions.

Learn more about [shinyMARLIN](shinyMARLIN/README.md)

## Training

Usage (specific CUDA device 1): `CUDA_VISIBLE_DEVICES=1 Rscript MARLIN_training.R`

## Prediction

Usage (specific CUDA device 1): `CUDA_VISIBLE_DEVICES=1 Rscript MARLIN_prediction.R`

