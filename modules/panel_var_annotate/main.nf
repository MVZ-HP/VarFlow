#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process panel_var_annotate {
  tag "${params.run_id}"
  container 'ghcr.io/mvz-hp/panel_var_annotate:1.0.3'
  containerOptions "--entrypoint \"\" --volume ${params.vep_cache}:/vep"
  cpus  params.cpus

  publishDir "${params.out_dir}", mode: 'copy', overwrite: true

  input:
    path snv_dir

  output:
    path "panel_var_annotate.${params.run_id}.${params.date}"

  script:
    """
    python3 /app/scripts/panel_var_annotate.py \
      -i ${snv_dir} \
      -p ${params.panel} \
      -a ${params.assembly} \
      -m ${params.mincov} \
      -f ${params.minvaf} \
      -r ${params.minvad} \
      -d /vep \
      -c ${task.cpus} \
      -o \$PWD
    """
}
