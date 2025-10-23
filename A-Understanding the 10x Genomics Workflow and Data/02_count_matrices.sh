#!/bin/bash
# Script: 02_count_matrices.sh

# --- Configuration ---
# Path to the 10x Genomics Reference Transcriptome
REFERENCE="/path/to/10x/refdata/human/GRCh38-2020-A"

# The directory containing the FASTQ files (output from mkfastq)
FASTQ_DIR="fastqs_output"

# List of your 10 Sample IDs
SAMPLES=(S1 S2 S3 S4 S5 S6 S7 S8 S9 S10)
# ---------------------

for SAMPLE_ID in "${SAMPLES[@]}"
do
	echo "Starting cellranger count for sample: $SAMPLE_ID"
	
	cellranger count \
		--id="${SAMPLE_ID}_analysis" \
		--transcriptome=$REFERENCE \
		--fastqs=$FASTQ_DIR \
		--sample=$SAMPLE_ID \
		--localcores=8 \
		--localmem=64
		
	echo "Count completed for $SAMPLE_ID"
	echo "Output matrix is in ${SAMPLE_ID}_analysis/outs/filtered_feature_bc_matrix.h5"
done

echo "All 10 samples have been processed!"