import os
import sys
from ftplib import FTP

def download_file(ftp, url_path, output_dir):
    local_filename = os.path.join(output_dir, os.path.basename(url_path))
    with open(local_filename, 'wb') as f:
        ftp.retrbinary(f"RETR {url_path}", f.write)
    print(f"Downloaded: {local_filename}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py /path/to/accession_list.txt /path/to/output_directory")
        sys.exit(1)

    accession_list = sys.argv[1]
    output_dir = sys.argv[2]

    if not os.path.isfile(accession_list):
        print(f"Error: Accession list file {accession_list} does not exist.")
        sys.exit(1)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    ftp_server = 'ftp.sra.ebi.ac.uk'
    ftp = FTP(ftp_server)
    ftp.login()  # Anonymous login

    with open(accession_list, 'r') as file:
        for line in file:
            accession = line.strip()
            if accession:
                print(f"Processing Accession Number: {accession}")

                # Construct paths for downloading FASTQ files
                path1 = f"/vol1/fastq/{accession[:6]}/{accession}/{accession}_1.fastq.gz"
                path2 = f"/vol1/fastq/{accession[:6]}/{accession}/{accession}_2.fastq.gz"

                # Download the FASTQ files
                try:
                    download_file(ftp, path1, output_dir)
                    download_file(ftp, path2, output_dir)
                except Exception as e:
                    print(f"Failed to download {accession}: {e}")

    ftp.quit()
    print("Download complete.")

if __name__ == "__main__":
    main()
