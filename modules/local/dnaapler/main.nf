process DNAAPLER {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/dnaapler%3A1.2.0--pyhdfd78af_0' :
        'community.wave.seqera.io/library/dnaapler:1.2.0--d4882d19d1c147a7' }"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("*all_reorientation_summary.tsv"), emit: reorientation_summary
    tuple val(meta), path("*MMseqs2_output.txt")           , emit: MMseqs
    tuple val(meta), path("*reoriented.fasta")             , emit: assembly
    tuple val(meta), path("${meta.id}_dnaapler.log")       , emit: log
    path "versions.yml"                                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gunzip -c $assembly > ${meta.id}_flye.fasta

    dnaapler all \\
        $args \\
        -p $prefix \\
        -o ${meta.id}/ \\
        -t $task.cpus \\
        -i ${meta.id}_flye.fasta

    mv ${meta.id}/* ./
    mv dnaapler*.log ${meta.id}_dnaapler.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dnaapler: \$( dnaapler --version | cut -f 3 -d ' ' )
    END_VERSIONS
    """
}
