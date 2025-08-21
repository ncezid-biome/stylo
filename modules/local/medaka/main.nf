process MEDAKA {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka%3A2.1.0--py38ha0c3a46_0' :
        'biocontainers/medaka%3A2.1.0--py38ha0c3a46_0' }"

    input:
    tuple val(meta), path(reads), path(assembly)

    output:
    tuple val(meta), path("*.fa.gz")    , emit: assembly
    tuple val(meta), path("*_model.log"), emit: model
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    medaka_consensus \\
        -t $task.cpus \\
        $args \\
        -i $reads \\
        -d $assembly \\
        -o ./ > ${prefix}.log 2>&1

    mv consensus.fasta ${prefix}.fa

    gzip -n ${prefix}.fa

    grep "Using model" ${prefix}.log | sed "s/.*Using model: //g" > ${prefix}_model.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        medaka: \$( medaka --version 2>&1 | sed 's/medaka //g' )
    END_VERSIONS
    """
}
