#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cnv_analysis {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_cnv_analysis:1.0.8'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path align_dir

  output:
    path "panel_cnv_analysis.${params.run_id}"

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
      --run_id ${params.run_id} \
      --no_date \
      -o \$PWD
    """
}