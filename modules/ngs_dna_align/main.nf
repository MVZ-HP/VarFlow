#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process ngs_dna_align {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/ngs_dna_align:1.0.1'
  containerOptions '--entrypoint ""'
  cpus params.cpus

  publishDir "${publish_dir}", mode: 'copy', overwrite: true

  input:
    tuple path(reads_dir), val(run_id), val(publish_dir)

  output:
    // Keep run_id in the path name for clarity
    path("ngs_dna_align.${run_id}")

  script:
    // Set default params if not provided
    def dedup_mode
    def skip_trim
    def extract_umis = ''
    if (params.mode == 'wes') {
      dedup_mode = params.dedup_mode ?: 'umi'
      skip_trim = params.skip_trim ?: ''
    } else if (params.mode == 'amplicon') {
      dedup_mode = params.dedup_mode ?: 'none'
      skip_trim = params.skip_trim ?: '--skip_trim'
    } else if (params.mode == 'mrd') {
      dedup_mode = params.dedup_mode ?: 'umi'
      extract_umis = params.extract_umis ? '--extract_umis' : ''
    }
    """
    python3 /app/scripts/ngs_dna_align.py \
      -f ${reads_dir} \
      -a ${params.assembly} \
      -m ${dedup_mode} \
      -r ${run_id} \
      -c ${task.cpus} \
      ${skip_trim} \
      ${extract_umis} \
      --no_date \
      -o \$PWD
    """
}
