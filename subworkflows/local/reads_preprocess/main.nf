//
// Subworkflow with functionality specific to the ncezid-biome/stylo pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { NANOQ  } from '../../../modules/nf-core/nanoq/main'
include { RASUSA } from '../../../modules/nf-core/rasusa/main'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow READS_PREPROCESSING {

    take:
    ch_samplesheet // includes genomes size mixed in

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    //
    // MODULE: readfiltering ONT longreads
    //
    NANOQ (
        ch_samplesheet.map { meta, reads, genus, species, genome_size -> tuple (meta, reads) },
        params.nanoq_format
    )
    ch_versions = ch_versions.mix(NANOQ.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(NANOQ.out.stats.map{ meta, stats -> tuple (stats) })

    //
    // MODULE: downsampling to specific coverage
    //
    ch_genome_size = ch_samplesheet.map { meta, reads, genus, species, genome_size -> tuple (meta, genome_size) }
    ch_rasusa_in = NANOQ.out.reads.combine( ch_genome_size, by: 0 )

    RASUSA (
        ch_rasusa_in,
        params.coverage
    )
    ch_versions = ch_versions.mix(RASUSA.out.versions)

    emit:
    reads = RASUSA.out.reads
    versions = ch_versions
    multiqc_files = ch_multiqc_files
}
