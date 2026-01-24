process MEDAKA {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka%3A2.1.1--py312ha65e1bd_0' :
        'biocontainers/medaka%3A2.1.1--py312ha65e1bd_0' }"

    input:
    tuple val(meta), path(reads), path(assembly)
    path medaka_model_dir

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
    ls -l $medaka_model_dir
    USER_PATH=\$(getconf PATH)
    printenv > ${prefix}_3.log 2>&1
    set +u; env - PATH="\$PATH" \${TMP:+SINGULARITYENV_TMP="\$TMP"} \${TMPDIR:+SINGULARITYENV_TMPDIR="\$TMPDIR"} \${NXF_TASK_WORKDIR:+SINGULARITYENV_NXF_TASK_WORKDIR="\$NXF_TASK_WORKDIR"} SINGULARITYENV_NXF_DEBUG="\${NXF_DEBUG:=0}" printenv > ${prefix}_4.log 2>&1
    medaka tools resolve_model --model \$(echo $args | cut -f 2 -d ' ') # > ${prefix}_2.log 2>&1
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
