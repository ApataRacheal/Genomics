#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Get the directory path from the argument
INPUT_DIRECTORY="$1"
FASTQC_OUTPUT_DIRECTORY="${INPUT_DIRECTORY}/fastqc_output"
TRIMMED_OUTPUT_DIRECTORY="${INPUT_DIRECTORY}/trimmed_samples"
EXTRACTED_FASTQC_DIRECTORY="${INPUT_DIRECTORY}/fastqc_extracted"

# Check if the provided path is a valid directory
if [ ! -d "$INPUT_DIRECTORY" ]; then
    echo "Error: $INPUT_DIRECTORY is not a valid directory."
    exit 1
fi

# Define paths for FastQC, MultiQC, and Trimmomatic
FASTQC_COMMAND="fastqc"
MULTIQC_COMMAND="multiqc"
TRIMMOMATIC_COMMAND="trimmomatic"

# Check if FastQC, MultiQC, and Trimmomatic are installed
if ! command -v $FASTQC_COMMAND &> /dev/null; then
    echo "Error: $FASTQC_COMMAND is not installed. Please install FastQC."
    exit 1
fi

if ! command -v $MULTIQC_COMMAND &> /dev/null; then
    echo "Error: $MULTIQC_COMMAND is not installed. Please install MultiQC."
    exit 1
fi

if ! command -v $TRIMMOMATIC_COMMAND &> /dev/null; then
    echo "Error: $TRIMMOMATIC_COMMAND is not installed. Please install Trimmomatic."
    exit 1
fi

# Create necessary directories if they do not exist
mkdir -p "$FASTQC_OUTPUT_DIRECTORY"
mkdir -p "$TRIMMED_OUTPUT_DIRECTORY"
mkdir -p "$EXTRACTED_FASTQC_DIRECTORY"

# Navigate to the specified directory
cd "$INPUT_DIRECTORY"

# Run FastQC on all FASTQ files and direct output to the FastQC output directory
echo "Running FastQC on all FASTQ files in $INPUT_DIRECTORY..."
fastqc *.fastq.gz -o "$FASTQC_OUTPUT_DIRECTORY" 2>&1 | tee fastqc.log

# Check if FastQC completed successfully
if [ $? -ne 0 ]; then
    echo "Error: FastQC encountered an issue."
    exit 1
fi


# Extract all FastQC ZIP files
echo "Extracting FastQC ZIP files..."
for zipfile in "$FASTQC_OUTPUT_DIRECTORY"/*.zip; do
    unzip "$zipfile" -d "$EXTRACTED_FASTQC_DIRECTORY"
done

# Check for extracted summary files
if [ ! "$(find "$EXTRACTED_FASTQC_DIRECTORY" -type f -name "summary.txt")" ]; then
    echo "No FastQC summary files found in $EXTRACTED_FASTQC_DIRECTORY. Ensure FastQC completed successfully."
    exit 1
fi


# Determine which samples did not pass QC
# Ensure that the grep command produces output before processing
SUMMARY_FILES=$(grep -l "PASS" "$EXTRACTED_FASTQC_DIRECTORY"/*_fastqc/summary.txt)
if [ -z "$SUMMARY_FILES" ]; then
    echo "No samples failed QC."
    FAILED_SAMPLES=""
else
    #FAILED_SAMPLES=$(echo "$SUMMARY_FILES" | xargs -n1 dirname | xargs -n1 basename | sed 's/_fastqc//')
    FAILED_SAMPLES=$(echo "$SUMMARY_FILES" | xargs -n1 dirname | xargs -n1 basename | sed 's/_fastqc//g' | sed 's/_1//g' | sed 's/_2//g' | sort | uniq)

fi

# Check if there are any failed samples
if [ -z "$FAILED_SAMPLES" ]; then
    echo "All samples passed QC. No trimming required."
else
    echo "Trimming samples that failed QC..."

    # Run Trimmomatic on the failed samples (paired-end reads)
    for SAMPLE in $FAILED_SAMPLES; do
        INPUT_FILE1="${SAMPLE}_1.fastq.gz"
        INPUT_FILE2="${SAMPLE}_2.fastq.gz"
        TRIMMED_FILE1="${TRIMMED_OUTPUT_DIRECTORY}/${SAMPLE}_1_trimmed.fastq.gz"
        TRIMMED_FILE2="${TRIMMED_OUTPUT_DIRECTORY}/${SAMPLE}_2_trimmed.fastq.gz"
        
        # Check if both input files exist
        if [ ! -f "$INPUT_FILE1" ] || [ ! -f "$INPUT_FILE2" ]; then
            echo "Error: One or both of the input files for $SAMPLE are missing."
            exit 1
        fi
        
        # Adjust Trimmomatic command according to paired-end reads
        trimmomatic PE -phred33 "$INPUT_FILE1" "$INPUT_FILE2" \
            "$TRIMMED_FILE1" "$TRIMMED_OUTPUT_DIRECTORY/${SAMPLE}_1_unpaired.fastq.gz" \
            "$TRIMMED_FILE2" "$TRIMMED_OUTPUT_DIRECTORY/${SAMPLE}_2_unpaired.fastq.gz" \
            LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 2>&1 | tee "${TRIMMED_OUTPUT_DIRECTORY}/${SAMPLE}_trimmomatic.log"
        
        if [ $? -ne 0 ]; then
            echo "Error: Trimmomatic encountered an issue with $SAMPLE."
            exit 1
        fi
    done

    # Re-run FastQC on trimmed samples
    echo "Re-running FastQC on trimmed samples..."
    fastqc "$TRIMMED_OUTPUT_DIRECTORY"/*_trimmed.fastq.gz -o "$FASTQC_OUTPUT_DIRECTORY" 2>&1 | tee trimmed_fastqc.log

    if [ $? -ne 0 ]; then
        echo "Error: FastQC encountered an issue with trimmed samples."
        exit 1
    fi
fi

# Run MultiQC to aggregate all FastQC reports including those from trimmed samples
echo "Running MultiQC to generate a combined report..."
multiqc "$FASTQC_OUTPUT_DIRECTORY" -o multiqc_report 2>&1 | tee multiqc.log

# Check if MultiQC completed successfully
if [ $? -ne 0 ]; then
    echo "Error: MultiQC encountered an issue."
    exit 1
fi

# Print completion message
echo "Processing complete. MultiQC report generated in the 'multiqc_report' directory."

