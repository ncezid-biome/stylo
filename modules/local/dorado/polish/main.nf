process DORADO_POLISH {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://nanoporetech/dorado:shaf2aed69855de85e60b363c9be39558ef469ec365' : '' }"

    input:
    tuple val(meta), path(reads), path(assembly)
    path dorado_model_dir

    output:
    tuple val(meta), path("*_polished_assembly.fasta.gz")    , emit: assembly
    tuple val(meta), path("*_model.log")                     , emit: model
    path "versions.yml"                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p $dorado_model_dir

    #https://software-docs.nanoporetech.com/dorado/latest/assembly/polish/
    # Align reads to a reference using dorado aligner, sort and index
    dorado aligner \\
        -t $task.cpus \\
        $assembly \\
        $reads \\
        | samtools sort \\
        --threads $task.cpus \\
        > ${prefix}_aligned_reads_sorted.bam

    samtools index \\
        --threads $task.cpus \\
        ${prefix}_aligned_reads_sorted.bam

    # Call consensus
    dorado polish \\
        ${prefix}_aligned_reads_sorted.bam \\
        $assembly \\
        $args > ${prefix}_polished_assembly.fasta 2> ${prefix}.log

    gzip -n ${prefix}_polished_assembly.fasta

    grep "Parsing the model config" ${prefix}.log | rev | cut -f 1 -d ' ' | rev > ${prefix}_model.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: \$( dorado --version )
        samtools: \$( samtools --version | head -n 1 | cut -f 2 -d ' ' )
    END_VERSIONS
    """
}
