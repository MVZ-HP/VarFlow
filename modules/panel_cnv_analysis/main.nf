#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cnv_analysis {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/panel_cnv_analysis:1.0.9'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple path(align_dir), val(run_id)

  output:
    // Keep run_id in the path name for clarity
    tuple path("panel_cnv_analysis.${run_id}"), val(run_id)

  script:
    // Set default params if not provided
    def method
    if (params.mode == 'wes') {
      method = 'hybrid_capture'
    } else if (params.mode == 'amplicon') {
      method = 'amplicon'
    }

    """
    python3 /app/scripts/panel_cnv_analysis.py \
      -t ${align_dir} \
      -a ${params.assembly} \
      -p ${params.panel} \
      -m ${method} \
      -c ${task.cpus} \
      --run_id ${run_id} \
      --no_date \
      -o \$PWD
    """
}