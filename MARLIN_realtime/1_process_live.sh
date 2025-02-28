#!/bin/bash

# First arg is the bam file to process

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")

if samtools quickcheck $1; then
	echo "$(date) Found new file, Index"
	samtools index -@ 4 $1
	echo "$(date) Pileup"
	modkit pileup --ref $SCRIPT_DIR/files/hg19.fa --include-bed $SCRIPT_DIR/files/reference_probes_hg19.bed -t 10 --combine-mods --only-tabs $1 $1.pileup
	echo "$(date) Merge"
	Rscript --vanilla $SCRIPT_DIR/2_process_pileup.R $SCRIPT_DIR/files/reference_probes_hg19.bed
	echo "$(date) Predict"
	Rscript --vanilla $SCRIPT_DIR/3_marlin_predictions_live.R $1 $SCRIPT_DIR/files/marlin_v1.features.RData $SCRIPT_DIR/files/marlin_v1.model.hdf5 $SCRIPT_DIR/files/Methylation_classes_annotation.xlsx
	echo "$(date) Plot"
	Rscript --vanilla $SCRIPT_DIR/4_plot_live2.R $1 $SCRIPT_DIR $SCRIPT_DIR/files/Methylation_classes_annotation.xlsx
	echo "$(date) Finish!"
fi
