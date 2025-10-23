#!/bin/bash
# Script: 01_mkfastq.sh

# --- Configuration ---
# Path to the Illumina BCL folder (the raw output from the sequencer)
BCL_DIRECTORY="/path/to/sequencer/run/Data/Intensities/BaseCalls"

# Name for the output directory
OUTPUT_FASTQS="fastqs_output"

# Path to your Sample Sheet CSV
SAMPLE_SHEET="ten_sample_sheet.csv"
# ---------------------

echo "Starting cellranger mkfastq..."

cellranger mkfastq \
	--run=$BCL_DIRECTORY \
	--output-dir=$OUTPUT_FASTQS \
	--csv=$SAMPLE_SHEET \
	--localcores=20 \
	--localmem=100

echo "mkfastq completed. FASTQ files for S1-S10 are now in the $OUTPUT_FASTQS folder."