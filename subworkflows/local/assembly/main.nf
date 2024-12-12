//
// Subworkflow with functionality specific to the narst/stylo pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//TODO: delete nf-core version of flye
include { FLYE } from '../../../modules/local/flye/main'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow ASSEMBLY {

    take:
    ch_reads // meta, rasusa reads
    ch_genome_size // meta, genome_size

    main:

    ch_versions = Channel.empty()

    //
    // MODULE: assembly ONT longreads
    //
    FLYE (
        ch_reads.combine(ch_genome_size, by:0).view(),
        params.flye_mode
    )
    ch_versions = ch_versions.mix(FLYE.out.versions)


    emit:
    assembly = FLYE.out.fasta
    versions = ch_versions
}
