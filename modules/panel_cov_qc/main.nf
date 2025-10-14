#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cov_qc {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/panel_cov_qc:1.0.11'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple path(align_dir), val(run_id)

  output:
    // Keep run_id in the path name for clarity
    path("panel_cov_qc.${run_id}")

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
      --run_id ${run_id} \
      --no_date \
      -o \$PWD
    """
}