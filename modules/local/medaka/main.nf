process MEDAKA {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka%3A2.0.1--py310he807b20_0' :
        'biocontainers/medaka:2.0.1--py310he807b20_0' }"

    input:
    tuple val(meta), path(reads)
    tuple val(meta), path(assembly)
    tuple val(meta), val(model)

    output:
    tuple val(meta), path("*.fa.gz"), emit: assembly
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // def medaka_model = model == '' ? params.medaka_model : model
    if (model == "") {
        def medaka_model = params.medaka_model
    } else {
        def medaka_model = model
    }
    """
    medaka_consensus \\
        -t $task.cpus \\
        $args \\
        -i $reads \\
        -d $assembly \\
        -m $medaka_model \\
        -o ./

    mv consensus.fasta ${prefix}.fa

    gzip -n ${prefix}.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        medaka: \$( medaka --version 2>&1 | sed 's/medaka //g' )
    END_VERSIONS
    """
}
