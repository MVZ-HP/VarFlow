#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_indel_call {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_indel_call:1.0.2'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path align_dir

  output:
    path "panel_indel_call.${params.run_id}"

  script:
    """
    python3 /app/scripts/panel_indel_call.py \
      -b ${align_dir} \
      -a ${params.assembly} \
      -c ${task.cpus} \
      --run_id ${params.run_id} \
      --no_date \
      -o \$PWD
    """
}