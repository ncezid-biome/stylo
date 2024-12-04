/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// TODO: uncomment
// include { READS_PREPROCESSING    } from '../subworkflows/local/reads_preprocess'
// include { ASSEMBLY               } from '../subworkflows/local/assembly'
// include { POSTPROCESSING_QC      } from '../subworkflows/local/postprocessing_qc'
include { paramsSummaryMap       } from 'plugin/nf-validation'
// include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
// include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_stylo_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow STYLO {

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    ch_versions = Channel.empty()
    // ch_multiqc_files = Channel.empty()

    // ch_lookup_table = Channel.fromPath( "../conf/lookup_table.tsv" )
    ch_lookup_table = Channel.fromPath( "/scicomp/home-pure/pps0/1.projects/20240118_nf-core_conversion_Justin/1.stylo/1.nf-core_rebuild/stylo/conf/lookup_table.tsv" )
        .splitCsv( sep: "\t" ) 
        .map { row -> [ row[0], row[1], row[2], row[3] ] } // genus, species, genome_size, socru_species
    ch_lookup_table.view()
    println "1"

    // ERROR:  Invalid method invocation `call` with arguments: [[id:sample1], /scicomp/home-pure/pps0/1.projects/20240118_nf-core_conversion_Justin/1.stylo/9.test/20241204_nf_rebuild_lookup_test/sample1.fastq.gz, Salmonella, enterica] (java.util.ArrayList) on _closure5 type
    ch_samplesheet_plus = ch_samplesheet.map ( samplesheet_row -> lookup(samplesheet_row, ch_lookup_table) )
    
    ch_samplesheet_plus.view()

    // TODO:uncomment
    /*
    //
    // SUBWORKFLOW: readfiltering and downsampling reads
    //
    READS_PREPROCESSING (
        ch_samplesheet.combine( ch_genome_size, by: 0)
    )
    ch_versions = ch_versions.mix(READS_PREPROCESSING.out.versions)

    //
    // SUBWORKFLOW: assemble reads
    //
    ASSEMBLY (
        READS_PREPROCESSING.out.reads
    )
    ch_versions = ch_versions.mix(ASSEMBLY.out.versions)

    //
    // SUBWORKFLOW: postprocess and qc assembly
    //
    // takes reads from preprocessing not original reads READS_PREPROCESSING.out.reads
    ch_genus_species = ch_samplesheet.map { meta, reads, genus, species, genome_size -> tuple (meta, genus, species) }

    POSTPROCESSING_QC (
        ASSEMBLY.out.assembly,
        READS_PREPROCESSING.out.reads,
        ch_genus_species
    )
    ch_versions = ch_versions.mix(POSTPROCESSING_QC.out.versions)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_pipeline_software_mqc_versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    // ch_multiqc_config        = Channel.fromPath(
    //     "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    // ch_multiqc_custom_config = params.multiqc_config ?
    //     Channel.fromPath(params.multiqc_config, checkIfExists: true) :
    //     Channel.empty()
    // ch_multiqc_logo          = params.multiqc_logo ?
    //     Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
    //     Channel.empty()

    // summary_params      = paramsSummaryMap(
    //     workflow, parameters_schema: "nextflow_schema.json")
    // ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))

    // ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
    //     file(params.multiqc_methods_description, checkIfExists: true) :
    //     file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    // ch_methods_description                = Channel.value(
    //     methodsDescriptionText(ch_multiqc_custom_methods_description))

    // ch_multiqc_files = ch_multiqc_files.mix(
    //     ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    // ch_multiqc_files = ch_multiqc_files.mix(
    //     ch_methods_description.collectFile(
    //         name: 'methods_description_mqc.yaml',
    //         sort: true
    //     )
    // )

    // MULTIQC (
    //     ch_multiqc_files.collect(),
    //     ch_multiqc_config.toList(),
    //     ch_multiqc_custom_config.toList(),
    //     ch_multiqc_logo.toList()
    // )
    */

    emit:
    // multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    // TODO: include emitted channels from subworkflows
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}


// lookup function for each row of samplesheet
// input row from samplsheet
// output row + genome_size + ssocru species
def lookup(samplesheet_row, ch_lookup_table) {
    println "2"
    // assume genus and species
    // if empty search for genus -
    ch_filtered_lookup = ch_lookup_table.map { genus, species, genome_size, socru_species ->
        tuple( genus.filter( samplesheet_row[2] ), species.filter( samplesheet_row[3] ), genome_size, socru_species )
    }.ifEmpty (
        ch_lookup_table.map { genus, species, genome_size, socru_species ->
            tuple( genus.filter( samplesheet_row[2] ), species.filter( '-' ), genome_size, socru_species )
        }
    ).map { genus, species, genome_size, socru_species -> tuple( genome_size, socru_species ) }
    println "3"
    return samplesheet_row.concat( ch_filtered_lookup )
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
