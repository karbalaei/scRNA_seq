
##10x Genomics scRNA-seq##

### Understanding the 10x Genomics Workflow and Data: From Cells to Matrix###

The core idea of 10x Genomics is to capture thousands of individual cells and perform the sequencing preparation inside tiny oil droplets called **GEMs** (Gel Beads in Emulsion) . This process uses a specialized piece of hardware and reagents.
The raw output from an Illumina sequencer is a set of **Binary Base Call (BCL) files**. The **Cell Ranger** software manages these BCL files through a critical initial step called **demultiplexing**. Here's how it works:

	1. From BCL to FASTQ
The BCL files are the dense, raw data, containing the base call and a quality score for every single cycle of the sequencing run. They aren't directly usable by most analysis tools:
'cellranger mkfastq': The Cell Ranger pipeline includes a function, cellranger mkfastq (which internally uses Illumina's bcl2fastq or BCL Convert software).

Demultiplexing: This step does two main things:

Converts: The BCL files are converted into FASTQ files. A FASTQ file is a text-based format that contains the sequence data (A, C, G, T) and their corresponding quality scores.


Splits (Demultiplexing): It uses the Sample Index sequences (which are different from the Cell Barcodes and are used to pool multiple samples onto one sequencer lane) to separate the mixed reads and create a distinct set of FASTQ files for each individual sample or library you ran.

2. From FASTQ to the Count Matrix
Once the FASTQ files are generated, the main analysis pipeline takes over:

cellranger count: This is the core Cell Ranger pipeline for single-cell gene expression. It takes the FASTQ files and the reference genome as input.


Processing: This pipeline then performs the sophisticated steps we just discussed in the previous lesson:

Extracts & Corrects: It finds and corrects the Cell Barcodes and UMIs within the FASTQ reads.

Aligns: It maps the reads to the reference transcriptome (aligns the RNA sequence to the known genes).

Counts: It uses the UMIs to count the original RNA molecules for each gene within each cell.

Output: The final result is the Gene-Barcode Matrix (the massive spreadsheet we talked about), which is the input for all your downstream analysis!

So, in short, Cell Ranger's first job is to run a "BCL to FASTQ" conversion and sample separation, and its second (and bigger) job is to process those FASTQ files into the count matrix.
The key to keeping track of which RNA molecule came from which cell are two special tags: **Barcodes** and **UMIs**.

#### 1. Cell Barcodes (CBs): 
Think of the **Barcode** as the mailing address for the cell. Every GEM contains a unique, pre-attached Gel Bead with millions of copies of the same short DNA sequence. This unique sequence is the **Cell Barcode**. As the cell's RNA is captured and prepared for sequencing inside the GEM, this barcode is added to every single RNA molecule from that cell. This tells you which cell the RNA came from.

#### 2. Unique Molecular Identifiers (UMIs): 
The **UMI** is like a serial number for a specific RNA molecule within a cell. It's a short, random sequence also added during the preparation. Why do we need it? When the RNA is amplified (copied many times) before sequencing, we need to know if we are seeing a measurement from the original RNA molecule or just a copy. By counting the unique **UMIs** associated with a gene in a cell, we get an accurate count of the *original RNA molecules*, preventing amplification biases from skewing the results.

After sequencing, the proprietary 10x software, **Cell Ranger**, takes the raw data, uses the **Barcodes** to group reads by cell and the UMIs to count the original molecules, and produces the final output: the Gene-Barcode Matrix. This is a massive spreadsheet where:

	*** Rows are the Genes (e.g., Sox2, CD14).

	*** Columns are the Cells (identified by their Barcodes).

	*** The Values in the matrix are the UMI Counts (how many molecules of that gene were detected in that cell).

Let`s` go dipper to the process!  tart with the 
This matrix is the starting point for almost all downstream scRNA-seq analysis!


### Initial Quality Control (QC) and Filtering: Learning how to clean up the data.

Data Normalization and Scaling: Making sure your cell-to-cell comparisons are fair.

Dimensionality Reduction: Making the complex data manageable and visual.

Cell Clustering and Visualization: Grouping cells to find different types.

Identifying Marker Genes and Cell Type Annotation: Putting names to the cell groups you found.