README for Quality Control and Trimming Script
This script performs quality control and trimming on paired-end FASTQ files. It uses FastQC for initial quality assessment, Trimmomatic for trimming low-quality reads, and MultiQC for aggregating the results.

Dependencies
To run this script, you need to have the following tools installed:

FastQC: For quality control of FASTQ files.
Trimmomatic: For trimming low-quality reads.
MultiQC: For aggregating the results of FastQC and other tools.

You can install these tools via Conda or your system's package manager.

Installing Dependencies
1. FastQC
conda install -c bioconda fastqc

2. Trimmomatic
conda install -c bioconda trimmomatic

3. MultiQC
conda install -c bioconda multiqc

Script Overview
The script performs the following tasks:

Check Arguments and Paths:

Validates the input directory and checks for necessary tools.
Run FastQC:

Runs FastQC on all FASTQ files in the specified directory and saves the results in the fastqc_output directory.
Extract FastQC Reports:

Extracts summary files from FastQC ZIP outputs and stores them in the fastqc_extracted directory.
Identify Failed Samples:

Determines which samples did not pass the initial QC.
Run Trimmomatic (if needed):

Trims the FASTQ files that failed the initial QC using Trimmomatic.
Re-run FastQC on Trimmed Samples:

Reassesses the quality of the trimmed samples.
Generate MultiQC Report:

Aggregates all FastQC results into a single report using MultiQC.
Print Completion Message:

Displays a message indicating that processing is complete.
Running the Script
Save the Script:

Save the script to a file, e.g., ./preprocess.sh
Make the Script Executable:

chmod +x preprocess.sh
Run the Script:

Execute the script by providing the path to the directory containing the FASTQ files:

./preprocess.sh /path/to/your/directory

Example Usage
Assuming you have a directory /data/reads with FASTQ files, you would run:

./preprocess.sh /data/reads

The script will perform the quality control, trimming (if necessary), and generate reports as described.

Troubleshooting
"Command not found" errors: Ensure that FastQC, Trimmomatic, and MultiQC are installed and available in your PATH.
No summary files found: Verify that FastQC ran successfully and that ZIP files were correctly extracted.
Trimmomatic errors: Check if input FASTQ files are correctly named and present.
If you encounter issues or errors, review the log files (fastqc.log, trimmed_fastqc.log, multiqc.log) for more details.
