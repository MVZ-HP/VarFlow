#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process ngs_dna_align {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/ngs_dna_align:1.0.0'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple path(reads_dir), val(run_id)

  output:
    // Keep run_id in the path name for clarity
    tuple path("ngs_dna_align.${run_id}"), val(run_id)

  script:
    def dedup_mode = (params.mode == 'wes') ? 'umi' : 'none'
    """
    python3 /app/scripts/ngs_dna_align.py \
      -f ${reads_dir} \
      -a ${params.assembly} \
      -m ${dedup_mode} \
      -r ${run_id} \
      -c ${task.cpus} \
      --no_date \
      -o \$PWD
    """
}
