#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ngs_dna_align      } from './modules/ngs_dna_align/main.nf'
include { panel_cov_qc       } from './modules/panel_cov_qc/main.nf'
include { panel_cnv_analysis } from './modules/panel_cnv_analysis/main.nf'
include { ngs_snv_call       } from './modules/ngs_snv_call/main.nf'
include { panel_var_annotate } from './modules/panel_var_annotate/main.nf'

workflow {
  // default run_id
  params.run_id = params.run_id ?: workflow.id

  // collect all samples into one List<Map>
  sample_list_ch = Channel
    .fromFilePairs(params.reads_pattern, flat: false)
    .map    { id, reads -> [ id: id, r1: reads[0], r2: reads[1] ] }
    .collect()    // -> emits ONE List<Map>

  // build a channel of tuples (sample_list, fastq_files)
  // where fastq_files is a List of all R1+R2 File objects
  read_ch = sample_list_ch.map { sample_list ->
    def fastqs = sample_list.collectMany{ [ it.r1, it.r2 ] }
    tuple(sample_list, fastqs)
  }

  // wire into your modules
  align_ch = ngs_dna_align(read_ch)
  cov_ch   = panel_cov_qc(align_ch)
  cnv_ch   = panel_cnv_analysis(align_ch)
  snv_ch   = ngs_snv_call(align_ch)
  panel_var_annotate(snv_ch)
}
