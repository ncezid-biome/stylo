## Introduction

**ncezid-biome/stylo** is a bioinformatics pipeline that can be used to filter, downsample, assemble, and QC [ONT](https://nanoporetech.com/) longreads. It takes a samplesheet and FASTQ files as input, performs read filtering, downsampling to specified coverage, assembly, and Quality Control (QC).

![Diagram of stylo steps](assets/stylo_tubemap.png)

1. Filters low quality reads ([nanoq](https://github.com/esteinig/nanoq))
2. Downsamples reads to specific coverage ([rasusa](https://github.com/mbhall88/rasusa))
3. Assembles reads ([Flye](https://github.com/mikolmogorov/Flye))
4. Reorients assembly ([Dnaapler](https://github.com/gbouras13/dnaapler))
5. Error correction ([Medaka](https://github.com/nanoporetech/medaka))
6. QCs assembly ([QUAST](https://github.com/ablab/quast))

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow.

> [!NOTE]
> This pipeline was tested using the following, other versions may work but are currently untested.
> 
> nf-core v2.14.1
> 
> nextflow v24.04.2
> 
> singularity v3.8.7

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq,genus,species,genome_size
sample1,/path/to/sample1.fastq.gz,Salmonella,enterica,-
sample2,/path/to/sample2.fastq.gz,Campylobacter,coli,-
sample3,/path/to/sample3.fastq.gz,Campylobacter,jejuni,-
sample4,/path/to/sample4.fastq.gz,Vibrio,-,-
sample5,/path/to/sample5.fastq.gz,Pseudomonas,aeruginosa,6.0m
```

Each row represents a fastq file (single-end) with the known genus, species, and genome size.

> [!NOTE]
> You can use `-` where the species is unknown. If the organism is not in the [lookup table](conf/lookup_table.tsv), you must include a genome size. For more details see [full samplesheet description](docs/usage.md#full-samplesheet)

If you'd like to create your own lookup table see [Advanced Usage](docs/usage.md#advanced-usage)


Now, you can run the pipeline using:

```bash
nextflow run ncezid-biome/stylo \
   -r v1.3.2 \
   -profile singularity \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

> [!NOTE]
> For CDC users, please see [CDC Usage](docs/CDC.md)

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

For more details about usage see the [Usage Page](docs/usage.md)

## Testing stylo on your server

If you'd like to test stylo on your server, you can run the following command

```bash
nextflow run ncezid-biome/stylo \
   -r v1.3.2 \
   -profile test,singularity \
   --outdir stylo_test/
```

## Credits

ncezid-biome/stylo was originally written by Arzoo Patel, Mohit Thakur.

We thank the following people for their extensive assistance in the development of this pipeline:

Justin Kim, Jessica Chen, Peyton Smith, Lee S. Katz, Joe Wirth, Curtis Kapsak

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use ncezid-biome/stylo for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
