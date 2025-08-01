#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ngs_dna_align      } from './modules/ngs_dna_align/main.nf'
include { ngs_snv_call       } from './modules/ngs_snv_call/main.nf'
include { panel_cov_qc       } from './modules/panel_cov_qc/main.nf'
include { panel_cnv_analysis } from './modules/panel_cnv_analysis/main.nf'
include { panel_var_annotate } from './modules/panel_var_annotate/main.nf'
include { panel_indel_call   } from './modules/panel_indel_call/main.nf'

workflow {
  // Help message
  if( params.help ) {
    println '''
    VarFlow v1.0.0

    A Nextflow-DSL2 pipeline for DNA-seq alignment, QC, CNV, SNV calling, and annotation.

    Usage:
      nextflow run mvz-hp/VarFlow -r v1.0.0 \\
        --mode        <wes|amplicon> \\
        --reads_dir   </path/to/fastq_folder> \\
        --bams_dir    </path/to/bam_folder> \\
        --vcfs_dir    </path/to/vcf_folder> \\
        --run_id      <unique_run_id> \\
        --assembly    <hg19|hg38> \\
        --panel       <panel_name> \\
        --mincov      <min_coverage> \\
        --minvaf      <min_variant_allele_frequency> \\
        --minvad      <min_variant_allele_depth> \\
        --vep_cache   <path_to_vep_cache> \\
        --cpus        <threads_per_process> \\
        && nextflow clean -f

    Options:
      --mode        Analysis mode: wes or amplicon. Required.
      --reads_dir   Folder containing paired FASTQs (R1/R2). Required (w/o --bams_dir OR --vcfs_dir).
      --bams_dir    Folder containing BAMs. Required (w/o --reads_dir OR --vcfs_dir).
      --vcfs_dir    Folder containing VCFs. Required (w/o --reads_dir OR --bams_dir).
      --panel       Target panel name (e.g. wes_panel). Required.
      --run_id      Short tag to identify this run (no spaces). Default: auto-generated.
      --assembly    Reference genome (hg19 OR hg38). Default: hg38.
      --mincov      Minimum coverage threshold. Default: 200 (wes) / 400 (amplicon).
      --minvaf      Minimum variant allele frequency. Default: 1.0 (wes) / 1.5 (amplicon).
      --minvad      Minimum variant allele depth. Default: 10 (wes) / 0 (amplicon).
      --vep_cache   Local VEP cache directory. Default: $HOME/.vep.
      --cpus        Threads per step. Default: 4.
      --help        Show this help message and exit.
    '''
    System.exit(0)
  }

  // If we get here, --help was not requested. Now check that --reads_dir, --bams_dir or --vcfs_dir is set.
  def set_count = [params.reads_dir, params.bams_dir, params.vcfs_dir].count { it }
  if( set_count != 1 ) {
    error "Exactly one of --reads_dir, --bams_dir, or --vcfs_dir must be specified."
  }

  // Ensure the specified input folder actually exists
  if( params.reads_dir ) {
    def readsFolder = file(params.reads_dir)
    if( !readsFolder.exists() ) {
      error "The folder given by --reads_dir does not exist: ${readsFolder}"
    }
  }
  if( params.bams_dir ) {
    def bamsFolder = file(params.bams_dir)
    if( !bamsFolder.exists() ) {
      error "The folder given by --bams_dir does not exist: ${bamsFolder}"
    }
  }
  if( params.vcfs_dir ) {
    def vcfsFolder = file(params.vcfs_dir)
    if( !vcfsFolder.exists() ) {
      error "The folder given by --vcfs_dir does not exist: ${vcfsFolder}"
    }
  }

  // Check if a valid mode was specified
  if( !(params.mode in ['wes', 'amplicon']) ) {
    error "No valid mode specified. Set --mode wes OR --mode amplicon."
  }

  // Check if panel was specified
  if( !(params.panel in ['wes_panel', 'lymphom', 'myeloid']) ) {
    error "No panel specified. Set --panel <panel_name>."
  }

  // Set up the output directory
  def outDir = file(params.out_dir)
  if( !outDir.exists() ) {
    outDir.mkdirs()
  }

  // Wire the processes together according to the input parameters
  if( params.reads_dir ) {
    // Input folder containing FASTQ files
    reads_ch = Channel.value( file(params.reads_dir) )
    align_ch = ngs_dna_align(reads_ch)
    snv_ch   = ngs_snv_call(align_ch)
    panel_cov_qc(align_ch)
    panel_cnv_analysis(align_ch)
    panel_var_annotate(snv_ch)
    if( params.mode == 'amplicon' ) {
      panel_indel_call(align_ch)
    }
  }
  // Input folder containing BAM files
  else if( params.bams_dir ) {
    align_ch = Channel.value( file(params.bams_dir) )
    snv_ch   = ngs_snv_call(align_ch)
    panel_cov_qc(align_ch)
    panel_cnv_analysis(align_ch)
    panel_var_annotate(snv_ch)
    if( params.mode == 'amplicon' ) {
      panel_indel_call(align_ch)
    }
  }
  // Input folder containing VCF files
  else if( params.vcfs_dir ) {
    snv_ch   = Channel.value( file(params.vcfs_dir) )
    panel_var_annotate(snv_ch)
  }
}
