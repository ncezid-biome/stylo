//
// Subworkflow with functionality specific to the ncezid-biome/stylo pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { DNAAPLER           } from '../../../modules/local/dnaapler/main'
include { MEDAKA             } from '../../../modules/local/medaka/main'
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
    
    main:

    ch_versions = Channel.empty()

    //
    // MODULE: fix starting position of genome assemblies
    //
    DNAAPLER (
        ch_assembly
    )
    ch_versions = ch_versions.mix(DNAAPLER.out.versions)

    //
    // MODULE: create consensus sequences
    //
    MEDAKA (
        ch_processed_reads.combine(DNAAPLER.out.assembly, by:0)
    )
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    //
    // MODULE: qc assembly
    //
    BUSCO_BUSCO (
        MEDAKA.out.assembly,
        params.busco_mode,
        params.lineage,
        [],
        []
    )
    ch_versions = ch_versions.mix(BUSCO_BUSCO.out.versions)

    emit:
    versions = ch_versions
}
