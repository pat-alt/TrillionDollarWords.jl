
#!/bin/bash

#SBATCH --job-name="FOMC-RoBERTa"
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=general
#SBATCH --mem-per-cpu=8GB
#SBATCH --mail-type=END     # Set mail type to 'END' to receive a mail when the job finishes. 

set -x                                                  # keep log of executed commands
export SRUN_CPUS_PER_TASK="$SLURM_CPUS_PER_TASK"        # assign extra environment variable to be safe 
export OPENBLAS_NUM_THREADS=1                           # avoid that OpenBLAS calls too many threads