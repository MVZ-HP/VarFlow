#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ngs_dna_align      } from './modules/ngs_dna_align/main.nf'
include { ngs_snv_call       } from './modules/ngs_snv_call/main.nf'
include { panel_cov_qc       } from './modules/panel_cov_qc/main.nf'
include { panel_cnv_analysis } from './modules/panel_cnv_analysis/main.nf'
include { panel_var_annotate } from './modules/panel_var_annotate/main.nf'

workflow {
  // Input folder containing FASTQ files
  reads_ch = Channel.value( file(params.reads_dir) )

  // Wire the processes together
  align_ch = ngs_dna_align(reads_ch)
  snv_ch   = ngs_snv_call(align_ch)
  panel_cov_qc(align_ch)
  panel_cnv_analysis(align_ch)
  panel_var_annotate(snv_ch)
}
