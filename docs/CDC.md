## Usage at CDC

If you are a CDC user, you should use the institutional config on scicomp when running stylo. The config can be accessed at `/scicomp/reference-pure/nextflow/nextflow-configs/latest.scicomp.config`. 
This will allow you to leverage the Rosalind HPC when running stylo. You should always use the `singularity` and `scicomp_rosalind` profiles, since stylo does not support the other profiles provided by scicomp.

```bash
nextflow run ncezid-biome/stylo \
   -r v1.3.2 \
   -c /scicomp/reference-pure/nextflow/nextflow-configs/latest.scicomp.config \
   -profile scicomp_rosalind,singularity \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```
