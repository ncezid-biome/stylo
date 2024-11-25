//
// Subworkflow with functionality specific to the ncezid-narst/ontmethylationfinder pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { NANOQ  } from '../../../modules/local/nanoq/main'
include { RASUSA } from '../../../modules/local/rasusa/main'

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
        ch_samplesheet.map { meta, reads, genus, species, genome_size -> tuple (meta, reads) },
        "fastq.gz"
    )
    ch_versions = ch_versions.mix(NANOQ.out.versions)

    //
    // MODULE: downsampling to specific coverage
    //
    // TODO: continue here
    // mix in genome size to NANOQ.out.fastq?
    RASUSA (
        NANOQ.out.fasta
    )
    ch_versions = ch_versions.mix(RASUSA.out.versions)

    emit:
    fasta = EDIT_CONTIGS.out.fasta
    bin = GENERATE_BINS.out.bin
    versions = ch_versions
}
