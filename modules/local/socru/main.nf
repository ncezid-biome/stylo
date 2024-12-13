process SOCRU {
    tag "$meta.id"
    label 'process_high'

    // biocontainer missing so defaulting to singularity
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/socru%3A2.2.4--py_1':
        'https://depot.galaxyproject.org/singularity/socru%3A2.2.4--py_1'}"

    input:
    tuple val(meta), path(assembly)
    tuple val(meta), val(socru_species) // post lookup table

    output:
    tuple val(meta), path("*_output.tsv"), emit: output
    tuple val(meta), path("*_blast.txt"), emit: blast_output
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    socru \\
        ${socru_species} \\
        ${assembly} \\
        $args \\
        -t $task.cpus \\
        -o "${prefix}_output.tsv" \\
        -b "${prefix}_blast.txt"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        socru: \$( socru --version )
    END_VERSIONS
    """
}
