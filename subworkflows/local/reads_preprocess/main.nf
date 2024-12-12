//
// Subworkflow with functionality specific to the narst/stylo pipeline
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

    //
    // MODULE: readfiltering ONT longreads
    //
    NANOQ (
        ch_samplesheet.map { meta, reads, genus, species, genome_size, socru_species -> tuple (meta, reads) },
        params.nanoq_format
    )
    ch_versions = ch_versions.mix(NANOQ.out.versions)

    //
    // MODULE: downsampling to specific coverage
    //
    ch_genome_size = ch_samplesheet.map { meta, reads, genus, species, genome_size, socru_species -> tuple (meta, genome_size) }
    ch_rasusa_in = NANOQ.out.reads.combine( ch_genome_size, by: 0 )

    RASUSA (
        ch_rasusa_in,
        params.coverage
    )
    ch_versions = ch_versions.mix(RASUSA.out.versions)

    emit:
    reads = RASUSA.out.reads
    versions = ch_versions
}
