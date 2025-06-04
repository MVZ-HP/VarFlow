#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cov_qc {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_cov_qc:1.0.9'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path align_dir

  output:
    path "panel_cov_qc.${params.run_id}"

  script:
    """
    python3 /app/scripts/panel_cov_qc.py \
      -b ${align_dir} \
      -p ${params.panel} \
      -a ${params.assembly} \
      -m ${params.mincov} \
      -c ${task.cpus} \
      --no_date \
      -o \$PWD
    """
}