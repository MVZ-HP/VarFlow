#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cov_qc {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_cov_qc:1.0.10'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path align_dir

  output:
    path "panel_cov_qc.${params.run_id}"

  script:
    // Set default params if not provided
    def mincov
    if (params.mode == 'wes') {
      mincov = params.mincov ?: 200
    } else if (params.mode == 'amplicon') {
      mincov = params.mincov ?: 400
    }

    """
    python3 /app/scripts/panel_cov_qc.py \
      -b ${align_dir} \
      -a ${params.assembly} \
      -p ${params.panel} \
      -m ${mincov} \
      -c ${task.cpus} \
      --run_id ${params.run_id} \
      --no_date \
      -o \$PWD
    """
}