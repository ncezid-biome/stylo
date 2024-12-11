//
// Subworkflow with functionality specific to the narst/stylo pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { CIRCLATOR_FIXSTART } from '../../../modules/local/circlator/fixstart/main'
include { MEDAKA             } from '../../../modules/local/medaka/main'
include { SOCRU              } from '../../../modules/local/socru/main'
include { BUSCO              } from '../../../modules/nf-core/busco/main'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow POSTPROCESSING_QC {

    take:
    ch_assembly // meta, assembly
    ch_processed_reads // meta, processed_reads
    ch_genus_species // meta, genus, species
    
    main:

    ch_versions = Channel.empty()

    //
    // MODULE: circularize genome assemblies
    //
    CIRCLATOR_FIXSTART (
        ch_assembly
    )
    ch_versions = ch_versions.mix(CIRCLATOR_FIXSTART.out.versions)

    // TDOD: implement header extraction code

    //
    // MODULE: create consensus sequences
    //
    MEDAKA (
        ch_processed_reads,
        CIRCLATOR_FIXSTART.out.assembly,
        ch_medaka_model
    )
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    //
    // MODULE: identify the order and orientation of complete genomes
    //
    SOCRU (
        MEDAKA.out.assembly,
        ch_socru_species
    )
    ch_versions = ch_versions.mix(SOCRU.out.versions)

    //
    // MODULE: qc assembly
    //
    BUSCO (
        MEDAKA.out.assembly,
        params.busco_mode,
        params.lineage,
        [],
        []
    )
    ch_versions = ch_versions.mix(BUSCO.out.versions)

    emit:
    versions = ch_versions
}
