#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cov_qc {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/panel_cov_qc:1.0.13'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "${publish_dir}", mode: 'copy', overwrite: true

  input:
    tuple path(align_dir), val(run_id), val(publish_dir)

  output:
    // Keep run_id in the path name for clarity
    path("panel_cov_qc.${run_id}")

  script:
    // Set default params if not provided
    def mincov
    def lowcov
    if (params.mode == 'wes') {
      mincov = params.mincov ?: 200
      lowcov = params.lowcov ?: 100
    } else if (params.mode == 'amplicon') {
      mincov = params.mincov ?: 400
      lowcov = params.lowcov
    } else if (params.mode == 'mrd') {
      mincov = params.mincov ?: 10000
      lowcov = params.lowcov
    }
    def lowcov_arg = lowcov != null ? "-l ${lowcov}" : ''

    """
    python3 /app/scripts/panel_cov_qc.py \
      -b ${align_dir} \
      -a ${params.assembly} \
      -p ${params.panel} \
      -m ${mincov} \
      ${lowcov_arg} \
      -c ${task.cpus} \
      --run_id ${run_id} \
      --no_date \
      -o \$PWD
    """
}
