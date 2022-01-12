#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --partition=small
#SBATCH --account=project_2002552
#SBATCH --gres=nvme:200

export SINGULARITY_TMPDIR=$LOCAL_SCRATCH
export SINGULARITY_CACHEDIR=$LOCAL_SCRATCH
unset XDG_RUNTIME_DIR

cd $LOCAL_SCRATCH

singularity pull --name yolov5.simg  docker://ultralytics/yolov5:v6.0
mv yolov5.simg  /scratch/project_2002552/nextflow/tellervo/data/

