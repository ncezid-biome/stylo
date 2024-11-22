process CIRCLATOR_FIXSTART {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/circlator%3A1.5.5--py_3' :
        'biocontainers/circlator:1.5.5--py_3' }"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("*.fasta"), emit: assembly
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    circlator fixstart \\
        $args \\
        $assembly \\
        $prefix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        circlator: \$( circlator version )
    END_VERSIONS
    """
}
