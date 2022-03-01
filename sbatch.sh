#!/bin/bash
#SBATCH -o std_%J.out
#SBATCH -e std_%J.err
#SBATCH --time=00:10:00
#SBATCH --mem=4GB
#SBATCH --cpus-per-task=1
#SBATCH --partition=test
#SBATCH --account=project_2002552
#SBATCH --mail-type=END
#SBATCH --mail-user=eva.domenechmoreno@helsinki.fi

export TMPDIR=$PWD
export SINGULARITY_TMPDIR=$PWD
export SINGULARITY_CACHEDIR=$PWD
unset XDG_RUNTIME_DIR

# Activate  Nextflow on Puhti
module load bioconda
source activate nextflow

# Nextflow command here
nextflow run tellervo.nf -resume -profile slurm
