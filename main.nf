#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ngs_dna_align            } from './modules/ngs_dna_align/main.nf'
include { ngs_snv_call             } from './modules/ngs_snv_call/main.nf'
include { panel_cov_qc             } from './modules/panel_cov_qc/main.nf'
include { panel_cnv_analysis       } from './modules/panel_cnv_analysis/main.nf'
include { panel_var_annotate       } from './modules/panel_var_annotate/main.nf'
include { panel_var_annotate_indel } from './modules/panel_var_annotate_indel/main.nf'
include { panel_indel_call         } from './modules/panel_indel_call/main.nf'

workflow {
  // Help message
  if( params.help ) {
    println '''
    VarFlow v1.0.0

    A Nextflow-DSL2 pipeline for DNA-seq alignment, QC, CNV, SNV calling, and annotation.

    Usage example WES (on default hg38):
      nextflow run mvz-hp/VarFlow -r v1.0.0 --mode wes --panel wes_panel \\
      --reads_dir FASTQ_folder --run_id WES_run_1 --cpus 16 && nextflow clean -f

    Usage:
      nextflow run mvz-hp/VarFlow -r v1.0.0 \\
        --mode        <wes|amplicon> \\
        --panel       <panel_name> \\
        --reads_dir   </path/to/fastq_folder> \\
        --bams_dir    </path/to/bam_folder> \\
        --vcfs_dir    </path/to/vcf_folder> \\
        --bam_vcf_dir </path/to/vcf_folder> \\
        --run_id      <unique_run_id> \\
        --assembly    <hg19|hg38> \\
        --mincov      <min_coverage> \\
        --minvaf      <min_variant_allele_frequency> \\
        --minvad      <min_variant_allele_depth> \\
        --vep_cache   <path_to_vep_cache> \\
        --cpus        <threads_per_process> \\
        && nextflow clean -f

    Options:
      --mode        Analysis mode: wes or amplicon. Required.
      --panel       Target panel name (e.g. wes_panel). Required.
      --reads_dir   Folder containing paired FASTQs (R1/R2). (w/o --bams_dir, --vcfs_dir).
      --bams_dir    Folder containing BAMs. (w/o --reads_dir, --vcfs_dir).
      --vcfs_dir    Folder containing VCFs. (w/o --reads_dir, --bams_dir).
      --bam_vcf_dir Folder containing BAMs and VCFs. (w/o --reads_dir, --reads_dir, --vcfs_dir).
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

  // Check if a valid mode was specified
  if( !(params.mode in ['wes', 'amplicon']) ) {
    error "No valid mode specified. Set --mode wes OR --mode amplicon."
  }

  // Check if panel was specified
  if( !(params.panel in ['wes_panel', 'lymphom', 'myeloid']) ) {
    error "No panel specified. Set --panel <panel_name>."
  }

  // Ensure only one of the input directory options is specified
  def dir_params = [params.reads_dir, params.bams_dir, params.vcfs_dir, params.bam_vcf_dir].findAll { it }
  if( dir_params.size() != 1 ) {
    error "You must specify exactly one of --reads_dir, --bams_dir, --vcfs_dir, or --bam_vcf_dir."
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
  if( params.bam_vcf_dir ) {
    def bamVcfFolder = file(params.bam_vcf_dir)
    if( !bamVcfFolder.exists() ) {
      error "The folder given by --bam_vcf_dir does not exist: ${bamVcfFolder}"
    }
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
    // Folder containing Bam files after alignment
    align_ch = ngs_dna_align(reads_ch)
    // Folder containing VCF files after SNV calling
    snv_ch = ngs_snv_call(align_ch)
    // Perform coverage QC, CNV analysis, and variant annotation
    panel_cov_qc(align_ch)
    panel_cnv_analysis(align_ch)
    panel_var_annotate(snv_ch)
    // If the mode is amplicon, also call and annotate indels
    if( params.mode == 'amplicon' ) {
      indel_ch = panel_indel_call(align_ch)
      panel_var_annotate_indel(indel_ch)
    }
  }
  // Input folder containing BAM files
  else if( params.bams_dir ) {
    // Input folder containing Bam files
    align_ch = Channel.value( file(params.bams_dir) )
    // Call SNVs
    snv_ch = ngs_snv_call(align_ch)
    // Perform coverage QC, CNV analysis, and variant annotation
    panel_cov_qc(align_ch)
    panel_cnv_analysis(align_ch)
    panel_var_annotate(snv_ch)
    // If the mode is amplicon, also call and annotate indels
    if( params.mode == 'amplicon' ) {
      indel_ch = panel_indel_call(align_ch)
      panel_var_annotate_indel(indel_ch)
    }
  }
  // Input folder containing VCF files
  else if( params.vcfs_dir ) {
    // Input folder containing VCF files
    snv_ch = Channel.value( file(params.vcfs_dir) )
    // Annotate the VCF files
    panel_var_annotate(snv_ch)
  }
  // Input folder containing both BAMs and VCFs
  else if( params.bam_vcf_dir ) {
    // Input folder containing Bam files
    align_ch = Channel.value( file(params.bam_vcf_dir) )
    // Input folder containing VCF files
    snv_ch = Channel.value( file(params.bam_vcf_dir) )
    // Perform coverage QC, CNV analysis, and variant annotation
    panel_cov_qc(align_ch)
    panel_cnv_analysis(align_ch)
    panel_var_annotate(snv_ch)
    // If the mode is amplicon, also call and annotate indels
    if( params.mode == 'amplicon' ) {
      indel_ch = panel_indel_call(align_ch)
      panel_var_annotate_indel(indel_ch)
    }
  }
}
