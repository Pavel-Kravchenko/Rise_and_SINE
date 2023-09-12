#!/bin/sh

#SBATCH --array=1-200%20
#SBATCH --mail-type=END --mail-user=[your email]
#SBATCH --time=4:00:00
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5GB
#SBATCH --cpus-per-task=1

#SBATCH --job-name=kallisto
#SBATCH --chdir=[full path]
#SBATCH --error=[full path]/log/kallisto%A.%a.err
#SBATCH --output=[full path]/log/kallisto%A.%a.out

##def section
##paths
BASIC_DIR="[full path]"
SEQS_DIR="[full path]/conc.fastq"


## Submit array jobs https://hpc-unibe-ch.github.io/slurm/array-jobs.html
step=0;
while [[ $step -lt $SLURM_ARRAY_TASK_STEP ]]
do
    index=$(($SLURM_ARRAY_TASK_ID+$step))
    max_id=$(($SLURM_ARRAY_TASK_ID+$SLURM_ARRAY_TASK_STEP-1))
    if [[ $index -le $max_id ]];
    then
        echo $SLURM_ARRAY_TASK_MAX
        echo $(sed -n ${index}p ${BASIC_DIR}/scripts/kallisto_cmd2.sh)
        eval $(sed -n ${index}p ${BASIC_DIR}/scripts/kallisto_cmd2.sh) || exit 100
    fi
    step=$(($step+1))
done

##multiqc after TrimGalore and umi_tools and kallisto
##multiqc $BASIC_DIR

