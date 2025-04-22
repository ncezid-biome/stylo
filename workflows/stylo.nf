/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { READS_PREPROCESSING    } from '../subworkflows/local/reads_preprocess'
include { ASSEMBLY               } from '../subworkflows/local/assembly'
include { POSTPROCESSING_QC      } from '../subworkflows/local/postprocessing_qc'
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

    ch_lookup_table = Channel.fromPath( "$baseDir/conf/lookup_table.tsv" )
        .splitCsv( sep: "\t" ) 
        .map { row -> [[ row[0], row[1], row[2] ]] } // genus, species, genome_size

    // code for sanity checking spelling of genus in samplesheet
    ch_samplesheet_genus_list = ch_samplesheet
        .map { row -> row[2]}
        .flatten()
        .unique()
        .map { genus -> [genus, "s"]}
    ch_lookup_table_genus_list = ch_lookup_table
        .map { row -> row[0][0]}
        .flatten()
        .unique()
        .map { genus -> [genus, "l"]}
    ch_samplesheet_genus_list.concat(ch_lookup_table_genus_list)
        .groupTuple(by:0)
        .filter{ row -> row[1] == ["s"]}
        .subscribe { row -> log.warn "${row[0]} wasn't found in the lookup table, this could be a mispelling" }

    // code for adding genome_size to the samplesheet CORRECTLY
    ch_samplesheet_reordered = ch_samplesheet.map { meta, fastq, genus, species -> [[genus, species, meta, fastq]] }
    ch_samplesheet_plus_gs = ch_samplesheet_reordered.combine(ch_lookup_table)
        .filter( row -> row[0][0] == row[1][0] ) // samplesheet genus matches lookup genus
        .filter( row -> row[0][1] == row[1][1] ) // samplesheet species matches lookup species
    ch_samplesheet_plus_g = ch_samplesheet_reordered.combine(ch_lookup_table)
        .filter( row -> row[0][0] == row[1][0] ) // samplesheet genus matches lookup genus
        .filter( row -> row[1][1] == '-' ) // samplesheet species doesn't match lookup species
    ch_samplesheet_plus = ch_samplesheet_plus_gs
        // combine both conditional samplesheets in order
        .concat(ch_samplesheet_plus_g)
        // remap to remove extra []
        // meta, genus, species, fasta, genome_size
        .map {
            row -> [row[0][2], row[0][0], row[0][1], row[0][3], row[1][2]]
        }
        // group by meta id
        .groupTuple(by:0)
        // take first element of each group
        // meta, fasta, genus, species, genome_size
        .map {
            row -> [ row[0], row[3][0], row[1][0], row[2][0], row[4][0] ]
        }
    
    ch_samplesheet_plus

    //
    // SUBWORKFLOW: readfiltering and downsampling reads
    //
    READS_PREPROCESSING (
        ch_samplesheet_plus
    )
    ch_versions = ch_versions.mix(READS_PREPROCESSING.out.versions)

    //
    // SUBWORKFLOW: assemble reads
    //
    ASSEMBLY (
        READS_PREPROCESSING.out.reads,
        ch_samplesheet_plus.map { meta, fasta, genus, species, genome_size -> [meta, genome_size] }
    )
    ch_versions = ch_versions.mix(ASSEMBLY.out.versions)

    //
    // SUBWORKFLOW: postprocess and qc assembly
    //
    // takes reads from preprocessing not original reads READS_PREPROCESSING.out.reads

    POSTPROCESSING_QC (
        ASSEMBLY.out.assembly,
        READS_PREPROCESSING.out.reads,
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
    
    emit:
    // multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
