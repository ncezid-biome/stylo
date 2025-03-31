--- 
title: "STYLO: a lightweight nf-core style nanopore assembly pipeline optimized for enteric bacteria"
tags: 
  - nextflow 
  - bioinformatics 
  - genomics 
  - bacteria 
  - assembly 
  - nanopore 
  - longreads 
  - quality control 
  - filtering 
  - downsampling 
  - ont 
  - nf-core style 
authors: 
  - name: Arzoo Patel 
    orcid: 0009-0007-9033-5785 
    equal-contrib: true 
    affiliation: 1 
  - name: Mohit Thakur 
    orcid: TODO 
    equal-contrib: true 
    affiliation: 1 
  - name: Justin Kim 
    orcid: TODO 
    corresponding: true 
    affiliation: 1 
  - name: Peyton Smith 
    orcid: TODO 
    corresponding: true 
    affiliation: 1 
  - name: Lee Katz 
    orcid: TODO 
    corresponding: true 
    affiliation: 1 
  - name: Curtis Kapsak 
    orcid: TODO 
    corresponding: true 
    affiliation: 1
  - name: Jessica Chen 
    orcid: TODO 
    corresponding: true 
    affiliation: 1 
affiliations: 
 - name: Enteric Diseases Laboratory Branch, Division of Foodborne, Waterborne, and Environmental Diseases, National Center for Emerging and Zoonotic Infectious Diseases, Centers for Disease Control and Prevention, Atlanta, Georgia 
   index: 1 
date: 31 March 2025 
bibliography: paper.bib 
---

# Summary

Oxford Nanopore Technologies (ONT) sequencing is a promising technology with many potential applications in food safety. We have developed stylo, a lightweight nf-core style assembly workflow for ONT long reads, specifically optimized for enteric bacteria. The pipeline downsamples, assembles, and performs quality control by combining nanoq, Rasusa, Flye, Circlator, Medaka[@medaka], and BUSCO.  All of stylo’s dependencies are containerized and the pipeline is available on GitHub. 

# Statement of Need

There is a continuous need for foodborne outbreak detection in public health (PN citation). To determine the scope or severity of a foodborne outbreak, isolate assemblies are often used to characterize enteric bacteria (PN citation). As nanopore longreads becomes more cost effective and accurate (both citations?) there is an increased need for streamlined pipelines for processing potential outbreaks sequenced using Oxford Nanopore Technologies (ONT).  With the increased adoption modern High-performance computing (HPC) and cloud servers, pipelines built to leverage containerization and custom configurations allow for easy deployment on those servers. To address these needs, we have created stylo, a lightweight nf-core style nanopore assembly pipeline optimized for enteric bacteria.  

Stylo is optimized around PulseNet, a molecular surveillance network for foodborne infections in the United States (PN citation). PN facilitates the rapid detection of illness clusters and reduces the likelihood of outbreaks becoming large and widespread (PN citation 2023). There exist generalized nanopore assembly workflows such as Donut falls(citation), whereas stylo is a specialized workflow utilized by PN and for downstream genotyping.  

# Workflow Overview

1. Input: STYLO requires a comma separated value file with columns sample, fastq, genus, species. Fastq files must comprise of single-end longreads sequenced on an ONT instrument. Genus and species will be used to automatically determine genome size via a lookup table built into the pipeline.  

2. Filtering and Downsampling: The pipeline filters out reads that are less than a user provided minimum length using nanoq. the resulting fastq is then subsampled to a user provided coverage (default 80x) via Rasusa. 

3. Assembly: Flye is run on the subsampled fastq using the "--nano-hq" mode by default, expecting more recent ONT basecalling models. This parameter can be changed by the user. 

4. Post-processing and Quality Control: The pipeline uses Circlator fixstart with default parameters to rearrange circular assemblies to start at a dnaA gene. The pipeline then uses Medaka with default parameters to correct assembly sequences. Finally, the assembly quality is assessed via BUSCO, run with parameter mode set to "genome" 

5. Output: The pipeline outputs files for each step. Some keys files are the initial assembly by Flye, the final assembly by Medaka, and the Quality Control summary by BUSCO 

![Diagram of stylo steps.](stylo_tubemap.png)

# Availability

Stylo is freely available and open-source. It can be downloaded from the GitHub repository available at https://github.com/arzoopatel5/stylo.  

# Acknowledgements

These authors contributed equally as co-first: Arzoo Patel and Mohit Thakur. We acknowledge contributions from Joe Wirth. 

# References
