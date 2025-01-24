## Introduction

**narst/stylo** is a bioinformatics pipeline that can be used to filter, downsample, assmeble, and QC ['ONT'](https://nanoporetech.com/) longreads. It takes a samplesheet and FASTQ files as input, performs read filtering, downsampling to specified coverage, assembly, and Quality Control (QC).

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Filters low quality reads ([nanoq](https://github.com/esteinig/nanoq))
2. Downsamples reads to specific coverage ([rasusa](https://github.com/mbhall88/rasusa))
3. Assembles reads ([Flye](https://github.com/mikolmogorov/Flye))
4. Circularizes assembly ([Circlator](https://github.com/sanger-pathogens/circlator))
5. Error correction ([Medaka](https://github.com/nanoporetech/medaka))
<!-- TODO: SOCRU -->
7. QCs assembly ([busco](https://github.com/metashot/busco))

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow.

First, download this branch to your prefered directory
```bash
cd /path/to/dir/
git clone -b nf-core-dev git@github.com:ncezid-narst/stylo.git
```

Second, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

<!-- TODO: remove socru? -->
```csv
sample,fastq,genus,species
sample1,/path/to/sample1.fastq.gz,Salmonella,enterica
sample2,/path/to/sample2.fastq.gz,Campylobacter,coli
sample3,/path/to/sample3.fastq.gz,Campylobacter,jejuni
sample4,/path/to/sample4.fastq.gz,Vibrio,-
sample5,/path/to/sample5.fastq.gz,Salmonella,enterica
```

Each row represents a fastq file (single-end) with the known genus and species.

> [!NOTE]
> you can use `-` where the species is unknown

Third, look at the [lookup table](conf/lookup_table.tsv) to make sure all the genuses listed in your samplesheet are present. If you'd like to add a row or edit the lookup table see [Advanced Usage](#advanced-usage)


Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run /path/to/stylo/main.nf \
   -profile singularity
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

If you're on CDC servers use `-profile rosalind`


> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

For more details about generic usage see the [Usage Page](docs/usage.md)

## Advanced Usage

### Editting the Lookup Table
If a genus is missing, then you'll need to add a row to the lookup table prior to running the pipeline. In order to add a row to the lookup table you'll need the following information:

1. genus (required)
2. species (optional, use `-` if you want the lookup table to accept all species within that genus)
3. genomes size (required, must follow the same format as the other rows in MBs)
4. socru_species (optional, must be a valid socru_species database or `-` if you prefer not to run socru, see [here](#socru-species-database-lookup)) <!-- TODO: remove socru? -->

<!-- TODO: remove socru? -->

### Socru Species Database Lookup
> [!NOTE] 
> You'll need to be able to run [Singularity](https://docs.sylabs.io/guides/latest/user-guide/) for this part

In order to get the socru_species list run the following

```bash
wget https://depot.galaxyproject.org/singularity/socru%3A2.2.4--py_1
singularity run socru%3A2.2.4--py_1 socru_species
```

If you cannot find your species in this list, then look for the genus with the ending `_sp.`. If `socru_species` doesn't contain your genus then you'll need to skip socru by using `-` in the lookup table.

<!-- TODO: remove socru? -->

## Credits

narst/stylo was originally written by Arzoo Patel, Mohit Thakur.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use narst/stylo for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
