
# 10x Genomics scRNA-seq #

## Understanding the 10x Genomics Workflow and Data: From Cells to Matrix

The core idea of 10x Genomics is to capture thousands of individual cells and perform the sequencing preparation inside tiny oil droplets called **GEMs** (Gel Beads in Emulsion) . This process uses a specialized piece of hardware and reagents.
The raw output from an Illumina sequencer is a set of **Binary Base Call (BCL) files**. The **Cell Ranger** software manages these BCL files through a critical initial step called **demultiplexing**. Here's how it works:

### **1. From BCL to FASTQ (Demultiplexing)**:

The BCL files are the dense, raw data, containing the base call and a quality score for every single cycle of the sequencing run. They aren't directly usable by most analysis tools.  
To prepare them, two main things happen here:

1- *Converts* : The BCL files are converted into FASTQ files. A FASTQ file is a text-based format that contains the sequence data (A, C, G, T) and their corresponding quality scores.

2- *Splits (Demultiplexing)* : It uses the Sample Index sequences (which are different from the Cell Barcodes and are used to pool multiple samples onto one sequencer lane) to separate the mixed reads and create a distinct set of FASTQ files for each individual sample or library you ran.

The Cell Ranger pipeline includes a function, **cellranger mkfastq** (which internally uses Illumina's *bcl2fastq* or *BCL Convert software*)

### **2. From FASTQ to the Count Matrix**

Once the FASTQ files are generated, the main analysis pipeline takes over:

1- *Extracts & Corrects*: It finds and corrects the Cell Barcodes and UMIs within the FASTQ reads.

2- *Aligns* : It maps the reads to the reference transcriptome (aligns the RNA sequence to the known genes).

3- *Counts* : It uses the UMIs to count the original RNA molecules for each gene within each cell.

The final result is the Gene-Barcode Matrix (the massive spreadsheet we talked about), which is the input for all your downstream analysis!

**cellranger count** : This is the core Cell Ranger pipeline for single-cell gene expression. It takes the FASTQ files and the reference genome as input.

So, in short, Cell Ranger's first job is to run a "BCL to FASTQ" conversion and sample separation, and its second (and bigger) job is to process those FASTQ files into the count matrix.
The key to keeping track of which RNA molecule came from which cell are two special tags: **Barcodes** and **UMIs**.

1- **Cell Barcodes (CBs)**: 

Think of the **Barcode** as the mailing address for the cell. Every GEM contains a unique, pre-attached Gel Bead with millions of copies of the same short DNA sequence. This unique sequence is the **Cell Barcode**. As the cell's RNA is captured and prepared for sequencing inside the GEM, this barcode is added to every single RNA molecule from that cell. This tells you which cell the RNA came from.

2- **Unique Molecular Identifiers (UMIs**: 

The **UMI** is like a serial number for a specific RNA molecule within a cell. It's a short, random sequence also added during the preparation. Why do we need it? When the RNA is amplified (copied many times) before sequencing, we need to know if we are seeing a measurement from the original RNA molecule or just a copy. By counting the unique **UMIs** associated with a gene in a cell, we get an accurate count of the *original RNA molecules*, preventing amplification biases from skewing the results.

After sequencing, the proprietary 10x software, **Cell Ranger**, takes the raw data, uses the **Barcodes** to group reads by cell and the UMIs to count the original molecules, and produces the final output: the Gene-Barcode Matrix. This is a massive spreadsheet where:

A- *** Rows are the Genes (e.g., Sox2, CD14).
B- *** Columns are the Cells (identified by their Barcodes).
C- *** The Values in the matrix are the UMI Counts (how many molecules of that gene were detected in that cell).

This matrix is the starting point for almost all downstream scRNA-seq analysis!

### Important notes 
There are more details here which should consider during running softwares:

#### Important notes for BCL to FASTQ Conversion (Demultiplexing):

When using **cellranger mkfastq** (or the underlying Illumina software like bcl2fastq or BCL Convert), the most important consideration for 10x Genomics data isn't a single flag, but a critical omission and two key settings:

1- **The Critical Omission: Do NOT Trim Adapters!**

*The Rule*: Never use adapter trimming flags (like --trim-adapters) or settings that instruct the software to remove adapter sequences. 

*The Reason*: For 10x data, the crucial Cell Barcode and UMI sequences are often found within the read structure, sometimes near where a typical sequencing adapter might be. Trimming them off will destroy the information Cell Ranger needs to assign reads to cells and count transcripts, which will make your downstream analysis useless!

2- **Key Parameter: --barcode-mismatches (Index Mismatches)**

*What it does*: This flag (or the equivalent setting in your sample sheet) specifies the number of mismatches allowed when matching the Sample Index sequence (the index that separates your pooled libraries) to the expected sequences. *The Default* : The default is usually 1 mismatch allowed.*Why it matters*: Allowing 1 mismatch is standard and increases the number of reads that can be successfully assigned to a sample, correcting for sequencing errors in the index read. However, increasing this past 1 is generally not recommended as it increases the risk of mis-assignment (reads being incorrectly assigned to the wrong sample).

3- **The Sample Sheet: Your Real Command Center**

The most vital "flag" is actually the Sample Sheet (CSV file) you provide to mkfastq. This sheet is where you link the physical lane and sequencing index sequence to a Sample ID (e.g., "Patient_A" or "Treated_Sample"). This Sample ID is what Cell Ranger uses to name and organize your final files

#### Separating Cells vs. Separating Samples

The columns in the Gene-Barcode Matrix are Cell Barcodes, which are related to individual cells. However, they are NOT related to the Sample ID (e.g., Patient A vs. Patient B) unless you have multiplexed your samples. The distinction lies in the two types of indices:

**1- The Sample Index (External/Sequencing Index)**

*Purpose*: To separate physical libraries (samples) that were pooled and run together on the sequencer. 

*Where it's found*: This is one of the reads in the sequencing flow cell (often called Index 1/i7 and Index 2/i5).

*How it works*: This is handled by *cellranger mkfastq* (demultiplexing). Every read in the sequencer output is checked against the Sample Index.If a read matches the index for "Patient A", it is written to the FASTQ file for "Patient A."If it matches "Patient B", it goes to the FASTQ file for "Patient B."

*Result*: The final Gene-Barcode Matrix is generated by running *cellranger count* separately on the FASTQ files for each Sample ID (Patient A, Patient B, etc.).

**2- The Cell Barcode (Internal/10x Barcode)**

*Purpose*: To separate individual cells within a single sample/library. 

*Where it's found*: This sequence is integrated into Read 1 of the FASTQ files. 

*How it works*: This is handled by *cellranger count*. All the cells (columns in the matrix) in the final matrix come from the single sample (e.g., Patient A) whose FASTQ files were fed into that run of cellranger count.

|Index Type|Role|Software Step|Result in Matrix|
|---|---|---|---|
|Sample Index|Separates pooled libraries/samples.|cellranger mkfastq|"Determines which matrix file is created (e.g., Patient_A_matrix.h5)."|
|Cell Barcode|Separates cells within a library.|cellranger count|Forms the columns of the matrix (the individual cells).|

#### **Sample codes** 




##### **R**

##### **Python**

## Initial Quality Control (QC) and Filtering: Learning how to clean up the data.

Data Normalization and Scaling: Making sure your cell-to-cell comparisons are fair.

Dimensionality Reduction: Making the complex data manageable and visual.

Cell Clustering and Visualization: Grouping cells to find different types.

Identifying Marker Genes and Cell Type Annotation: Putting names to the cell groups you found.


