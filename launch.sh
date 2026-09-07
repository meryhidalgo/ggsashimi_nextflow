#!/usr/bin/env bash

#SBATCH --time=20:00:00
#SBATCH --mem=8G

module load Nextflow Apptainer

# limit the resources of the JVM
export NXF_OPTS="-Xms500M -Xmx8G"

# launch the main process
cd ggsashimi_nextflow {dir}
nextflow run main.nf -resume -profile local_apptainer -params-file input_params.yaml

#nextflow run main.nf -resume -profile cluster -params-file input_params.yaml # for ATLAS CLUSTER
#nextflow run main.nf -resume -profile cluster_apptainer -params-file input_params.yaml # for HYPERION
#nextflow run main.nf -resume -profile local_apptainer -params-file input_params.yaml # for HYPERION WHEN LAUNCHING IT INSIDE A NODE