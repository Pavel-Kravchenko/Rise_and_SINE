#!/bin/sh

## SLURM Options
##
#SBATCH --ntasks=20
#SBATCH --job-name=fastq-dump
#SBATCH --mail-type=END --mail-user=Nemo

cust_func(){
  ./tools/sratoolkit.3.0.7-ubuntu64/bin/fastq-dump-orig.3.0.7 --split-files "$1"
}
 
while IFS= read -r url
do
        cust_func "$url" &
done < SRR_Acc_List.txt
 
wait
echo "All files are downloaded."
