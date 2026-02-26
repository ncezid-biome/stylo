//
// Subworkflow with functionality specific to the ncezid-biome/stylo pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { DNAAPLER           } from '../../../modules/local/dnaapler/main'
include { MEDAKA             } from '../../../modules/nf-core/medaka/main'
include { QUAST              } from '../../../modules/nf-core/quast/main'

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
    ch_multiqc_files = Channel.empty()

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
        ch_processed_reads.combine(DNAAPLER.out.assembly, by:0),
        params.model_dir
    )
    ch_versions = ch_versions.mix(MEDAKA.out.versions)
    

    //
    // MODULE: qc assembly
    //
    QUAST (
        MEDAKA.out.assembly,
        [[],[]],
        [[],[]],
    )
    ch_versions = ch_versions.mix(QUAST.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(QUAST.out.results.map{ meta, results -> tuple (results) } )

    emit:
    versions = ch_versions
    multiqc_files = ch_multiqc_files
}
