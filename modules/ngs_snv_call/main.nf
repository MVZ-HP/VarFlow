#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process ngs_snv_call {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/ngs_snv_call:1.0.1'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple path(align_dir), val(run_id)

  output:
    // Keep run_id in the path name for clarity
    path("ngs_snv_call.${run_id}")

  script:
    """
    python3 /app/scripts/ngs_snv_call.py \
      -b ${align_dir} \
      -a ${params.assembly} \
      -p ${params.panel} \
      -c ${task.cpus} \
      --run_id ${run_id} \
      --no_date \
      -o \$PWD
    """
}