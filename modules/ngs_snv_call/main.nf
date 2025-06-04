#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process ngs_snv_call {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/ngs_snv_call:1.0.0'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path align_dir

  output:
    path "ngs_snv_call.${params.run_id}"

  script:
    """
    python3 /app/scripts/ngs_snv_call.py \
      -b ${align_dir} \
      -a ${params.assembly} \
      -p ${params.panel} \
      -c ${task.cpus} \
      --no_date \
      -o \$PWD
    """
}