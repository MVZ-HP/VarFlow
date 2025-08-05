#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_var_annotate_indel {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_var_annotate:1.0.3'
  containerOptions "--entrypoint \"\" --volume ${params.vep_cache}:/vep"
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path snv_dir

  output:
    path "panel_var_annotate.indel.${params.run_id}"

  script:
    // Set default params if not provided
    def mincov = params.mincov ?: 400
    def minvaf = params.minvaf ?: 1.5
    def minvad = params.minvad ?: 0
    // Add -indel to the run id
    def run_id = "indel.${params.run_id}"

    """
    python3 /app/scripts/panel_var_annotate.py \
      -i ${snv_dir} \
      -a ${params.assembly} \
      -p ${params.panel} \
      -m ${mincov} \
      -f ${minvaf} \
      -r ${minvad} \
      -d /vep \
      -c ${task.cpus} \
      --run_id ${run_id} \
      --no_date \
      -o \$PWD
    """
}
