# Paired-end Genome Assembly with SPAdes (Installation and Usage Guide)

## Overview

This guide covers the installation of SPAdes (St. Petersburg genome assembler) and provides instructions for executing a bash script to perform genome assembly using SPAdes with paired-end reads.

## Prerequisites

- Linux-based system or compatible environment
- Python 3.6 or higher
- Conda (optional but recommended for environment management)

## Installation

### Using Conda (Recommended)

1. **Install Miniconda or Anaconda** (if not already installed):
   - [Miniconda Installation](https://docs.conda.io/en/latest/miniconda.html)
   - [Anaconda Installation](https://www.anaconda.com/products/distribution)

2. **Create a Conda Environment for SPAdes**:
   ```bash
   conda create -n spades_env python=3.8
   
3. **Activate the Conda Environment:**:
   conda activate spades_env

4. **Install SPAdes Using Conda:**
   conda install -c bioconda spades



## Configuration
      verify installation
      spades.py --version

## Running SPAdes with a Bash Script
   This section describes how to run SPAdes using a custom bash script for paired-end reads.

Download the bash script: spades_assembly.sh
A sample bash script to automate the SPAdes assembly for paired-end reads. Make sure to customize the paths and file extensions to fit your specific data and setup.

#### Script Usage
Customize Paths:

ROOT_DIR: Update the path to the directory where your FASTQ files are located.

SPADES: Update the path to the spades.py executable according to your installation. use command "whereis spades.py" to get the full path to the spades.py executable.

File Extensions: File Naming Conventions: The script assumes paired-end files follow the naming convention _1_trimmed.fastq.gz and _2_trimmed.fastq.gz. Adjust the file extensions and naming patterns if your files use different conventions.

Make the Script Executable:
chmod +x run_spades.sh

Run the Script:
./run_spades.sh

## Additional Resources
https://github.com/ablab/spades

