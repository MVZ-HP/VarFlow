#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_var_annotate_indel {
  tag "${run_id}"
  container 'ghcr.io/mvz-hp/panel_var_annotate:1.0.4'
  containerOptions "--entrypoint \"\" --volume ${params.vep_cache}:/vep"
  cpus params.cpus

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple path(snv_dir), val(run_id)

  output:
    // Keep run_id in the path name for clarity
    path("panel_var_annotate.indel.${run_id}")

  script:
    // Set default params if not provided
    def mincov = params.mincov ?: 400
    def minvaf = params.minvaf ?: 1.5
    def minvad = params.minvad ?: 0

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
      --run_id indel.${run_id} \
      --no_date \
      -o \$PWD
    """
}
