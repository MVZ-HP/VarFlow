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
    path("ngs_dna_align.${run_id}")

  script:
    // Set default params if not provided
    def dedup_mode
    def skip_trim
    if (params.mode == 'wes') {
      dedup_mode = params.dedup_mode ?: 'umi'
      skip_trim = params.skip_trim ?: null
    } else if (params.mode == 'amplicon') {
      dedup_mode = params.dedup_mode ?: 'none'
      skip_trim = params.skip_trim ?: '--skip_trim'
    }
    """
    python3 /app/scripts/ngs_dna_align.py \
      -f ${reads_dir} \
      -a ${params.assembly} \
      -m ${dedup_mode} \
      -r ${run_id} \
      -c ${task.cpus} \
      ${skip_trim} \
      --no_date \
      -o \$PWD
    """
}
