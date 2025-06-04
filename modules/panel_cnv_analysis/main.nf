#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_cnv_analysis {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_cnv_analysis:1.0.7'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path align_dir

  output:
    path "panel_cnv_analysis.${params.run_id}"

  script:
    """
    python3 /app/scripts/panel_cnv_analysis.py \
      -t ${align_dir} \
      -p ${params.panel} \
      -a ${params.assembly} \
      -w \
      -c ${task.cpus} \
      --no_date \
      -o \$PWD
    """
}