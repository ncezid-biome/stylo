process DORADO_POLISH {
    tag "$meta.id"
    label 'process_high'

    container "docker://nanoporetech/dorado:sha38b4ce849afa13eac8075f0b41cecd30799f169b"

    input:
    tuple val(meta), path(reads), path(assembly)
    path model_dir
    val model

    output:
    tuple val(meta), path("*_polished.fasta.gz")    , emit: assembly
    tuple val(meta), path("*_model.log")            , emit: model
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def args4 = task.ext.args4 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p \$(readlink $model_dir)

    #https://software-docs.nanoporetech.com/dorado/latest/assembly/polish/
    # Align reads to a reference using dorado aligner, sort and index
    dorado aligner \\
        -t $task.cpus \\
        $args \\
        $assembly \\
        $reads \\
        > ${prefix}.bam

    # sort and index bam
    samtools sort \\
        -@ $task.cpus \\
        $args2 \\
        ${prefix}.bam \\
        > ${prefix}_sorted.bam
    samtools index ${prefix}_sorted.bam

    if samtools view -H ${prefix}.bam | grep "^@RG" | grep -q "basecall_model="; then
        # write basecalling model to model log
        echo "basecall_model: \$(samtools view -H ${prefix}_sorted.bam | grep "^@RG" | tr ' ' '\\n' | grep "basecall_model=" | cut -f 2 -d '=')" >> ${prefix}_model.log
        
        # Call consensus
        dorado polish \\
            -t $task.cpus \\
            --models-directory $model_dir \\
            $args3 \\
            ${prefix}_sorted.bam \\
            $assembly \\
            > ${prefix}_polished.fasta \\
            2> >(tee ${prefix}.log >&2)
    else
        # write basecalling model to model log
        echo "WARNING: basecalling model not in header, using user defined polishing model" >> ${prefix}_model.log

        # download model if it isn't in the model_dir
        if [ ! -d $model_dir/$model/ ]; then
            dorado download \\
                --model $model \\
                --models-directory $model_dir \\
                $args4
        fi
        
        # Call consensus
        dorado polish \\
            -t $task.cpus \\
            --models-directory $model_dir \\
            --model-override $model_dir/$model/ \\
            $args3 \\
            ${prefix}_sorted.bam \\
            $assembly \\
            > ${prefix}_polished.fasta \\
            2> >(tee ${prefix}.log >&2)
    fi

    bgzip ${prefix}_polished.fasta

    # write polishing model to model log
    echo "polishing_model: \$(grep "Resolved model from" ${prefix}.log | rev | cut -f 1 -d ' ' | rev)" >> ${prefix}_model.log

    # docker file does not support heredocs
    echo "${task.process}:" > versions.yml
    echo "    dorado: \$( dorado --version )" >> versions.yml
    echo "    samtools: \$( samtools --version | head -n 1 | cut -f 2 -d ' ' )" >> versions.yml
    """
}
