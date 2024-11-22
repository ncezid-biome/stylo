#!/bin/bash

module load nf-core/2.14.1
module load nextflow/24.04.2
module load singularity/3.8.7
module load Python/3.11.1

# remove annoying ^H on backspace after nextflow calls
nextflow_path=$(which nextflow)
nextflow () {
    $nextflow_path $@
    stty erase ^H
}
