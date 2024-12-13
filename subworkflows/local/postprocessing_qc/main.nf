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
include { BUSCO_BUSCO        } from '../../../modules/nf-core/busco/busco/main'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow POSTPROCESSING_QC {

    take:
    ch_assembly // meta, assembly
    ch_processed_reads // meta, processed_reads
    ch_socru_species // meta, socru_species
    
    main:

    ch_versions = Channel.empty()

    //
    // MODULE: circularize genome assemblies
    //
    CIRCLATOR_FIXSTART (
        ch_assembly
    )
    ch_versions = ch_versions.mix(CIRCLATOR_FIXSTART.out.versions)

    //
    // MODULE: create consensus sequences
    //
    MEDAKA (
        ch_processed_reads.combine(CIRCLATOR_FIXSTART.out.assembly, by:0)
    )
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    //
    // MODULE: identify the order and orientation of complete genomes
    //
    //TODO: figure out whats getting messed up before socru is run, might have to do with mutliple seperated channels being input
    SOCRU (
        MEDAKA.out.assembly,
        ch_socru_species
    )
    ch_versions = ch_versions.mix(SOCRU.out.versions)

    //
    // MODULE: qc assembly
    //
    BUSCO_BUSCO (
        MEDAKA.out.assembly,
        params.busco_mode,
        params.lineage, //TODO: double check that this works correctly (auto-prok)
        [],
        []
    )
    ch_versions = ch_versions.mix(BUSCO_BUSCO.out.versions)

    emit:
    versions = ch_versions
}
