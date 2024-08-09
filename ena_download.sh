#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/accession_list.txt /path/to/output_directory"
    exit 1
fi

# Get the input arguments
ACCESSION_LIST="$1"
OUTPUT_DIR="$2"

# Check if the accession list file exists
if [ ! -f "$ACCESSION_LIST" ]; then
    echo "Error: Accession list file $ACCESSION_LIST does not exist."
    exit 1
fi

# Create the output directory if it does not exist
mkdir -p "$OUTPUT_DIR"

# Change to the output directory
cd "$OUTPUT_DIR"

# Download data for each accession number
while IFS= read -r accession; do
    echo "Processing Accession Number: $accession"

    # Construct the URL for downloading FASTQ files
    URL="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${accession:0:6}/${accession}/${accession}_1.fastq.gz"
    URL2="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${accession:0:6}/${accession}/${accession}_2.fastq.gz"

    # Download the FASTQ files
    wget "$URL"
    wget "$URL2"

done < "$ACCESSION_LIST"

echo "Download complete."
