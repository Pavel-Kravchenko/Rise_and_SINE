#!/bin/sh

# Please change according to your needs
# ------------------------------------
#
# Date:
# Name:
# Project/Experiment: RNA-Seq reanalysis
# ...
#
# ------------------------------------

BASIC_DIR="[full path]"
SEQS_DIR="[full path]/conc.fastq"

# please provide fastq.gz files in conc.fastq folder (gzip *.fastq)

# cleaning to avoid pottential collisions
rm ${BASIC_DIR}/scripts/kallisto_cmd1.sh
rm ${BASIC_DIR}/scripts/kallisto_cmd2.sh

# setting up environment
mkdir ../log
mkdir ../TrimGalire
mkdir ../Kallisto

 # ------------------------------------
 # Using TrimGalore to trim sequencing adaptors
 
printf '%s\0' "$SEQS_DIR/"*.fastq.gz | sort -zV | xargs -0 -n2 sh -c 'echo [path to TrimGalore]/TrimGalore-0.6.10/trim_galore --quality 20 --gzip --fastqc --core 5 --trim-n --paired "$1" "$2" -o '${BASIC_DIR}'/TrimGalore' sh > ${BASIC_DIR}/scripts/kallisto_cmd1.sh

sbatch common_script_transcriptome_kallisto1.sh

while [[ `squeue -u [your id] | wc -l` != 2 ]]
do
  sleep 20
  echo `squeue -u [your id] | wc -l`
done


# ------------------------------------
# Running kallisto

printf '%s\0' "$BASIC_DIR/TrimGalore/"*val*.fq.gz | sort -zV | xargs -0 -n2 sh -c 'a=${1#'$BASIC_DIR'/TrimGalore/}; echo "kallisto quant -b 100 -i [path to index]/mus_musculus/transcriptome.idx -o '${BASIC_DIR}'/Kallisto/${a%_R1_val_1.fq.gz} "$1" "$2""' sh > ${BASIC_DIR}/scripts/kallisto_cmd2.sh

sbatch common_script_transcriptome_kallisto2.sh

while [[ `squeue -u [your id] | wc -l` != 2 ]]
do
  sleep 20
  echo `squeue -u [your id] | wc -l`
done

# done
# ------------------------------------
