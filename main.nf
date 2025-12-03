#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ngs_dna_align            } from './modules/ngs_dna_align/main.nf'
include { ngs_snv_call             } from './modules/ngs_snv_call/main.nf'
include { panel_cov_qc             } from './modules/panel_cov_qc/main.nf'
include { panel_cnv_analysis       } from './modules/panel_cnv_analysis/main.nf'
include { panel_var_annotate       } from './modules/panel_var_annotate/main.nf'
include { panel_var_annotate_indel } from './modules/panel_var_annotate_indel/main.nf'
include { panel_indel_call         } from './modules/panel_indel_call/main.nf'
include { infer_run_id             } from './modules/infer_run_id/main.nf'
include { write_log_file           } from './modules/write_log_file/main.nf'

workflow {
  //VARFFLOW_VERSION = '1.0.3'
  // Help message
  if( params.help ) {
    println '''
    VarFlow v1.0.3

    A Nextflow-DSL2 pipeline for DNA-seq alignment, QC, CNV, SNV calling, and annotation.

    Usage example WES (on default hg38):
      nextflow run mvz-hp/VarFlow -r v1.0.3 --mode wes --panel wes_panel \\
      --reads_dir FASTQ_folder --run_id WES_run_1 --cpus 16 && nextflow clean -f

    Usage:
      nextflow run mvz-hp/VarFlow -r v1.0.3 \\
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
        --skip_indel  (skip indel calling and annotation; amplicon mode only) \\
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
      --minvad      Minimum variant allele depth. Default: 10.
      --vep_cache   Local VEP cache directory. Default: $HOME/.vep.
      --skip_indel  Skip indel calling and annotation (amplicon mode only).
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
  def dir_params = [params.reads_dir, params.bams_dir, params.vcfs_dir, params.bam_vcf_dir].findAll { d -> d }
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

    // Figure out which input dir is in use
  def chosen_dir = params.reads_dir ?: params.bams_dir ?: params.vcfs_dir ?: params.bam_vcf_dir
  if( !chosen_dir ) {
    error "You must specify exactly one of --reads_dir, --bams_dir, --vcfs_dir, or --bam_vcf_dir."
  }
  def chosenFolder = file(chosen_dir)
  if( !chosenFolder.exists() ) {
    error "The chosen input folder does not exist: ${chosenFolder}"
  }

  // Build a single-path channel for infer_run_id
  input_dir_ch = channel.value( chosenFolder )

  // Infer run_id (explicit -> SampleSheet -> default)
  runid_file_ch = infer_run_id(
      input_dir_ch,
      params.run_id ?: '',
      params.run_id_def,
      (params.samplesheet == null ? true : params.samplesheet).toString()
  )

  // Turn file into a value channel (trim newline)
  run_id_ch = runid_file_ch.map { f -> f.text.trim() }

  // Prepare channels for the four entry modes
  if( params.reads_dir ) {
    reads_ch = channel.value( chosenFolder )
    // Pair each input with the single run_id value
    reads_plus_id_ch = reads_ch.combine(run_id_ch)
    // Align
    bam_ch = ngs_dna_align(reads_plus_id_ch)
    bam_plus_id = bam_ch.combine(run_id_ch)
    // Call SNVs
    snv_ch = ngs_snv_call(bam_plus_id)
    snv_plus_id = snv_ch.combine(run_id_ch)
    // QC+CNV+Annot
    cov_out = panel_cov_qc(bam_plus_id)
    cnv_out = panel_cnv_analysis(bam_plus_id)
    ann_out = panel_var_annotate(snv_plus_id)
    // ----- barrier that fires *after* cov + cnv + ann are done -----
    def barrier = channel
                  .empty()
                  .mix( cov_out.map{ true } )
                  .mix( cnv_out.map{ true } )
                  .mix( ann_out.map{ true } )
                  .collect()            // waits for all three tokens
                  .map{ 'ready' }       // single value for gating
    // Indels only in amplicon mode
    if( params.mode == 'amplicon' && !params.skip_indel ) {
      // Gate indel calling on the barrier
      indel_in = bam_plus_id.combine(barrier)
      indel_ch = panel_indel_call(indel_in)
      indel_plus_id = indel_ch.combine(run_id_ch)
      panel_var_annotate_indel(indel_plus_id)
    }
  }
  else if( params.bams_dir ) {
    bam_ch = channel.value( chosenFolder )
    bam_plus_id = bam_ch.combine(run_id_ch)
    // Call SNVs
    snv_ch = ngs_snv_call(bam_plus_id)
    snv_plus_id = snv_ch.combine(run_id_ch)
    // QC+CNV+Annot
    cov_out = panel_cov_qc(bam_plus_id)
    cnv_out = panel_cnv_analysis(bam_plus_id)
    ann_out = panel_var_annotate(snv_plus_id)
    // ----- barrier that fires *after* cov + cnv + ann are done -----
    def barrier = channel
                  .empty()
                  .mix( cov_out.map{ true } )
                  .mix( cnv_out.map{ true } )
                  .mix( ann_out.map{ true } )
                  .collect()            // waits for all three tokens
                  .map{ 'ready' }       // single value for gating
    // Indels only in amplicon mode
    if( params.mode == 'amplicon' && !params.skip_indel ) {
      // Gate indel calling on the barrier
      indel_in = bam_plus_id.combine(barrier)
      indel_ch = panel_indel_call(indel_in)
      indel_plus_id = indel_ch.combine(run_id_ch)
      panel_var_annotate_indel(indel_plus_id)
    }
  }
  else if( params.vcfs_dir ) {
    snv_ch = channel.value( chosenFolder )
    snv_plus_id_ch = snv_ch.combine(run_id_ch)
    // Annotate only
    panel_var_annotate(snv_plus_id_ch)
  }
  else if( params.bam_vcf_dir ) {
    both_ch = channel.value( chosenFolder )
    both_plus_id_ch = both_ch.combine(run_id_ch)
    // QC+CNV+Annot
    cov_out = panel_cov_qc(both_plus_id_ch)
    cnv_out = panel_cnv_analysis(both_plus_id_ch)
    ann_out = panel_var_annotate(both_plus_id_ch)
    // ----- barrier that fires *after* cov + cnv + ann are done -----
    def barrier = channel
                  .empty()
                  .mix( cov_out.map{ true } )
                  .mix( cnv_out.map{ true } )
                  .mix( ann_out.map{ true } )
                  .collect()            // waits for all three tokens
                  .map{ 'ready' }       // single value for gating
    // Indels only in amplicon mode
    if( params.mode == 'amplicon' && !params.skip_indel ) {
      // Gate indel calling on the barrier
      indel_in = both_plus_id_ch.combine(barrier)
      indel_ch = panel_indel_call(indel_in)
      indel_plus_id = indel_ch.combine(run_id_ch)
      panel_var_annotate_indel(indel_plus_id)
    }
  }

  // LOGGING
  // Define information for logging
  log_info = [
    Pipeline: [
      VarFlow_version  : '1.0.3',
      Nextflow_version : workflow.nextflow.version,
      Date_time        : "${params.date} ${new Date().format('HH:mm:ss')}"
    ],

    Modules: [
      ngs_dna_align        : '1.0.0',
      ngs_snv_call         : '1.0.1',
      panel_cov_qc         : '1.0.11',
      panel_cnv_analysis   : '1.0.10',
      panel_indel_call     : '1.0.2',
      panel_var_annotate   : '1.0.6'
    ],

    //Params: params
  ]

  // prepare versions channel
  versions_ch = channel.value(log_info)

  // combine with run_id
  versions_plus_id_ch = versions_ch.combine(run_id_ch)

  // write versions log file
  write_log_file(versions_plus_id_ch)
  
}
