#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process ngs_dna_align {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/ngs_dna_align:1.0.0'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path reads_dir   // a directory containing all R1/R2 FASTQs

  output:
    path "ngs_dna_align.${params.run_id}"

  script:
    """
    python3 /app/scripts/ngs_dna_align.py \
      -f ${reads_dir} \
      -a ${params.assembly} \
      -m ${params.dedup_mode} \
      -r ${params.run_id} \
      -c ${task.cpus} \
      --no_date \
      -o \$PWD
    """
}
