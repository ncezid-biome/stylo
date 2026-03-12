process DORADO_POLISH {
    tag "$meta.id"
    label 'process_high'

    container "docker://nanoporetech/dorado:shac8f356489fa8b44b31beba841b84d2879de2088e"

    input:
    tuple val(meta), path(reads), path(assembly)
    path model_dir

    output:
    tuple val(meta), path("*_polished.fasta.gz")    , emit: assembly
    tuple val(meta), path("*_model.log")                     , emit: model
    path "versions.yml"                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p $dorado_model_dir

    #https://software-docs.nanoporetech.com/dorado/latest/assembly/polish/
    # Align reads to a reference using dorado aligner, sort and index
    dorado aligner \\
        -t $task.cpus \\
        $args \\
        $assembly \\
        $reads \\
        > ${prefix}.bam

    if samtools view -H ${prefix}.bam | grep "^@RG" | grep -q "basecall_model="; then
        # sort and index bam
        samtools sort \\
            -@ $task.cpus \\
            $args2 \\
            ${prefix}.bam \\
            > ${prefix}_sorted.bam
        samtools index ${prefix}_sorted.bam

        # Call consensus
        dorado polish \\
            -t $task.cpus \\
            --models-directory $model_dir \\
            $args3 \\
            ${prefix}_sorted.bam \\
            $assembly \\
            > ${prefix}_polished.fasta \\
            2> ${prefix}.log
    else
        # add DS tagged RG so dorado polish runs
        samtools addreplacerg \\
            $args4 \\
            ${prefix}.bam | \\
            samtools sort \\
                -@ $task.cpus \\
                $args2 \\
            > ${prefix}_sorted.bam

        samtools index ${prefix}_sorted.bam

        # Call consensus
        dorado polish \\
            -t $task.cpus \\
            --models-directory $model_dir \\
            --RG basecaller \\
            $args3 \\
            ${prefix}_sorted.bam \\
            $assembly \\
            > ${prefix}_polished.fasta \\
            2> ${prefix}.log
    fi

    gzip -n ${prefix}_polished.fasta

    # write basecall and polishing model to model log
    echo basecall_model: $(samtools view -H GI-01_sup_5.0.0_small.bam | grep "^@RG" | tr ' ' '\n' | grep "basecall_model=" | cut -f 2 -d '=') > ${prefix}_model.log
    echo polishing_model: $(grep "Resolved model from input data: " ${prefix}.log | rev | cut -f 1 -d ' ' | rev) >> ${prefix}_model.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: \$( dorado --version )
        samtools: \$( samtools --version | head -n 1 | cut -f 2 -d ' ' )
    END_VERSIONS
    """
}
