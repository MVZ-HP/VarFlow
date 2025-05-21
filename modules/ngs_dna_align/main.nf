#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process ngs_dna_align {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/ngs_dna_align:1.0.0'
  containerOptions '--entrypoint ""'
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    // tuple(sample_list, fastqs) from read_ch
    tuple val(sample_list), path(fastqs)

  output:
    path "ngs_dna_align.${params.run_id}.${params.date}"

  script:
    // Inside $PWD we now have *all* FASTQs by basename
    def r1s = sample_list.collect{ it.r1.name }.join(',')
    def r2s = sample_list.collect{ it.r2.name }.join(',')

    """
    python3 /app/scripts/ngs_dna_align.py \
      -1 ${r1s} \
      -2 ${r2s} \
      -a ${params.assembly} \
      -m ${params.dedup_mode} \
      -r ${params.run_id} \
      -c ${task.cpus} \
      -o \$PWD
    """
}
