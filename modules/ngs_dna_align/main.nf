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
    def skip_trim = ''
    def extract_umis = ''
    def indel_friendly = ''
    if (params.panel == 'wes_panel') {
      dedup_mode = params.dedup_mode ?: 'umi'
      skip_trim = params.skip_trim ?: ''
    } else if (params.panel in ['lymphom', 'myeloid']) {
      dedup_mode = params.dedup_mode ?: 'none'
      skip_trim = params.skip_trim ?: '--skip_trim'
      indel_friendly = '--indel_friendly'
    } else if (params.panel == 'b_lymphoid') {
      dedup_mode = params.dedup_mode ?: 'umi'
      extract_umis = (params.extract_umis == null || params.extract_umis) ? '--extract_umis' : ''
    } else if (params.panel == 'mrd') {
      dedup_mode = params.dedup_mode ?: 'umi'
      // MRD libraries use duplex UMIs and indel-friendly alignment by default.
      // An explicit `--extract_umis false` still allows UMI extraction to be disabled.
      extract_umis = (params.extract_umis == null || params.extract_umis) ? '--extract_umis' : ''
      indel_friendly = '--indel_friendly'
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
      ${indel_friendly} \
      --no_date \
      -o \$PWD
    """
}
