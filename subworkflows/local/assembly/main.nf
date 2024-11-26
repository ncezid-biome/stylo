//
// Subworkflow with functionality specific to the narst/stylo pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FLYE } from '../../../modules/local/flye/main'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow ASSEMBLY {

    take:
    ch_reads // meta, rasusa reads

    main:

    ch_versions = Channel.empty()

    //
    // MODULE: assembly ONT longreads
    //
    FLYE (
        ch_reads,
        params.flye_mode
    )
    ch_versions = ch_versions.mix(NANOQ.out.versions)


    emit:
    assembly = FLYE.out.fasta
    versions = ch_versions
}
