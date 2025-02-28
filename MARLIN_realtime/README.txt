####
# Instructions for MARLIN real-time prediction
# as in Steinicke, Benfatto, et al., manuscript in preparation
#
# Salvatore Benfatto (salvatore_benfatto@dfci.harvard.edu)
# Hovestadt lab, Dana-Farber Cancer Institute
# 28 Feb 2025


This script checks for a new bam file every 5 seconds. If present, it (1) generates a new methylation pileup file, (2) all the pileup files to that point are merged, and (3) the cumulative methylation information is used as input to generate a MARLIN prediction.

For each new bam file, the script produces a txt file (with number of covered CpGs, timestamp, and methylation class scores) and a pdf where predictions are visualized as a barplot (each bar corresponding to a methylation class).


Before running MARLIN:
- install MinKNOW
- install modkit
- install samtools
- install R and packages keras/tensorflow, data.table, openxlsx
- download hg19 reference genome from UCSC, rename hg19.fa, place in MARLIN_realtime/files directory
- download MARLIN model from Dropbox, place in MARLIN_realtime/files directory

Start nanopore sequencing run:
- turn on basecalling in MinKNOW, using hg19 as a reference genome
- turn on modified bases in the basecalling options

Start MARLIN real-time script:
- open a terminal, change to directory where new bam files are produced
- run the following command: bash path_to_script/0_real_time_prediction_main.sh
- observe progress, end script when done (Ctrl-c)
