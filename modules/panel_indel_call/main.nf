#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_indel_call {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/panel_indel_call:1.0.2'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple path(align_dir), val(run_id)

  output:
    // Keep run_id in the path name for clarity
    tuple path("panel_indel_call.${run_id}"), val(run_id)

  script:
    """
    python3 /app/scripts/panel_indel_call.py \
      -b ${align_dir} \
      -a ${params.assembly} \
      -c ${task.cpus} \
      --run_id ${run_id} \
      --no_date \
      -o \$PWD
    """
}