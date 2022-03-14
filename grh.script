#!/bin/bash

#SBATCH --job-name="roll hill"
#SBATCH --output=job_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=powersj@msoe.edu
#SBATCH --partition=teaching
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4gb

## SCRIPT START

cd \$HOME/NATURE_MI2020/
julia worker_roll_hill.jl ${SLURM_ARRAY_TASK_ID}

## SCRIPT END