#!/bin/bash

# Directory to start searching for files
ROOT_DIR="/home/racheal/mercy/python_reads/processed_data"

# Path to SPAdes executable
SPADES="/home/racheal/miniconda3/envs/spades_env/bin/spades.py" # Path to the spades.py executable

# Function to process each set of files
process_files() {
    local read1="$1"
    local read2="$2"
    local dir="$(dirname "$read1")"
    local base="$(basename "$read1" | sed 's/_1_trimmed.fastq.gz//')"

    echo "Processing files: $read1 and $read2"

    # Create a directory for SPAdes output
    local spades_dir="${dir}/spades_output_${base}"
    mkdir -p "$spades_dir"

    # Run SPAdes
    $SPADES -1 "$read1" -2 "$read2" -o "$spades_dir"

    echo "Finished processing files: $read1 and $read2"
}

# Export the function to be used by find
export -f process_files
export SPADES

# Find all paired-end files and process them
find "$ROOT_DIR" -type f -name "*_trimmed.fastq.gz" | while read -r file; do
    # Assuming paired-end files with "_1_trimmed.fastq.gz" and "_2_trimmed.fastq.gz"
    if [[ "$file" =~ _1_trimmed.fastq.gz$ ]]; then
        base="${file%_1_trimmed.fastq.gz}"
        pair="${base}_2_trimmed.fastq.gz"
        if [[ -f "$pair" ]]; then
            process_files "$file" "$pair"
        else
            echo "Pair not found for $file"
        fi
    fi
done

echo "All files processed."
