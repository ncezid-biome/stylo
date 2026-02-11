# ncezid-biome/stylo: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyze before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 4 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

### Full samplesheet

There is a strict requirement for the first 4 columns of the samplesheet to match those defined in the table below. The 5th column is optional.

A few example samplesheets are provided below and included in [assets](../assets/).

```csv title="samplesheet_basic.csv"
sample,fastq,genus,species
sample1,/path/to/sample1.fastq.gz,Salmonella,enterica
sample2,/path/to/sample2.fastq.gz,Campylobacter,coli
sample3,/path/to/sample3.fastq.gz,Campylobacter,jejuni
sample4,/path/to/sample4.fastq.gz,Vibrio,-
sample5,/path/to/sample5.fastq.gz,Salmonella,enterica
```

```csv title="samplesheet_extra_genomes.csv"
sample,fastq,genus,species,genome_size
sample1,/path/to/sample1.fastq.gz,Salmonella,enterica,4.8m
sample2,/path/to/sample2.fastq.gz,Campylobacter,coli,-
sample3,/path/to/sample3.fastq.gz,Pseudomonas,aeruginosa,6.0m
sample3,/path/to/sample3.fastq.gz,Bacteroides,fragilis,5.2m
```


| Column    | Format | Description                                                                                                                                                                            |
| --------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sample`  | string | Custom sample name. This entry must be unique. |
| `fastq` | path | Full path to FastQ file for ONT longreads. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |
| `genus` | string | genus of the sample. This must be provided for the pipeline to run, otherwise the row will be skipped. |
| `species` | string OR `-` | species of the sample. If you don't know the species or would like to skip this part use `-` as seen in the example samplesheet. Note that this might affect some assemblies such as Vibrio where different species within the genus have different genome sizes |
| `genome_size` | float followed by valid unit prefix (i.e. `5.0m`, `425.0k`) OR `-` | genome size of the sample. If you would like to use a non-default genome_size, you can specify it here. You can find or define default organisms in the [lookup table](../README.md#editing-the-lookup-table). Additionally if you have a non-default organism you must specify a genome_size. |

An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline.

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run ncezid-biome/stylo -r v1.3.0 --input /path/to/samplesheet.csv --outdir ./results -profile singularity
```

This will launch the pipeline with the `singularity` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

Note: if you're on CDC servers the work dir will be in the scratch space

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

:::warning
Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).
:::

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run /path/to/stylo/main.nf -profile singularity -params-file params.yaml
```

with `params.yaml` containing:

```yaml
input: './samplesheet.csv'
outdir: './results/'
<...>
```

## Advanced Usage

### Editing the Lookup Table
If a genus is missing, then you'll need to add a row to the lookup table prior to running the pipeline. In order to add a row to the lookup table you'll need the following information:

1. genus (required)
2. species (optional, use `-` if you want the lookup table to accept all species within that genus)
3. genomes size (required, must follow the same format as the other rows in MBs)

### model parameter
If the model parameter is left blank, the pipeline will choose the bacterial methylation model `r1041_e82_400bps_bacterial_methylation`.
It's best to let the pipleine use the bacterial methylation model, but if you must specify the model parameter make sure to use one of the models from the following list

```
r103_sup_g507
r1041_e82_260bps_fast_g632
r1041_e82_260bps_hac_g632
r1041_e82_260bps_hac_v4.0.0
r1041_e82_260bps_hac_v4.1.0
r1041_e82_260bps_joint_apk_ulk_v5.0.0
r1041_e82_260bps_sup_g632
r1041_e82_260bps_sup_v4.0.0
r1041_e82_260bps_sup_v4.1.0
r1041_e82_400bps_bacterial_methylation
r1041_e82_400bps_fast_g615
r1041_e82_400bps_fast_g632
r1041_e82_400bps_hac_g615
r1041_e82_400bps_hac_g632
r1041_e82_400bps_hac_v4.0.0
r1041_e82_400bps_hac_v4.1.0
r1041_e82_400bps_hac_v4.2.0
r1041_e82_400bps_hac_v4.3.0
r1041_e82_400bps_hac_v5.0.0
r1041_e82_400bps_hac_v5.0.0_rl_lstm384_dwells
r1041_e82_400bps_hac_v5.0.0_rl_lstm384_no_dwells
r1041_e82_400bps_hac_v5.2.0
r1041_e82_400bps_hac_v5.2.0_rl_lstm384_dwells
r1041_e82_400bps_hac_v5.2.0_rl_lstm384_no_dwells
r1041_e82_400bps_sup_g615
r1041_e82_400bps_sup_v4.0.0
r1041_e82_400bps_sup_v4.1.0
r1041_e82_400bps_sup_v4.2.0
r1041_e82_400bps_sup_v4.3.0
r1041_e82_400bps_sup_v5.0.0
r1041_e82_400bps_sup_v5.0.0_rl_lstm384_dwells
r1041_e82_400bps_sup_v5.0.0_rl_lstm384_no_dwells
r1041_e82_400bps_sup_v5.2.0
r1041_e82_400bps_sup_v5.2.0_rl_lstm384_dwells
r1041_e82_400bps_sup_v5.2.0_rl_lstm384_no_dwells
r104_e81_fast_g5015
r104_e81_hac_g5015
r104_e81_sup_g5015
r104_e81_sup_g610
r941_e81_fast_g514
r941_e81_hac_g514
r941_e81_sup_g514
r941_min_fast_g507
r941_min_hac_g507
r941_min_sup_g507
r941_prom_fast_g507
r941_prom_hac_g507
r941_prom_sup_g507
```

for more details about model selection in medaka, see [medaka model documentation](https://github.com/nanoporetech/medaka/tree/366ff49ad9e2be6862e376630b51b3b3d28944c2#models)


## Core Nextflow arguments

:::note
These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen).
:::

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Two profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Singularity, Rosalind) - see below.

:::info
We highly recommend the use of Singularity containers for full pipeline reproducibility.
:::

Note that multiple profiles can be loaded, for example: `-profile test,singularity` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `rosalind`
  - A CDC server specific configuration profile for running jobs on the cluster using [Singularity](https://sylabs.io/docs/)

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customize the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher requests (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases you may wish to change which container or conda environment a step of the pipeline uses for a particular tool. By default nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customizing tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted by your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
