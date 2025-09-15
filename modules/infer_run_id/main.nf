#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/**
 * Determine final run_id with precedence:
 *   1) explicit_id (if non-empty)
 *   2) SampleSheet.csv (RunName or RunID) in input_dir, if samplesheet=true
 *   3) default_id
 *
 * Inputs:
 *   - input_dir: directory chosen as the pipeline input root
 *   - explicit_id: user-passed run_id ('' if not set)
 *   - default_id: current default (e.g., myeloid_hg38_rXXXXXX)
 *   - samplesheet: boolean-like string ("true"/"false"), default true
 *
 * Output:
 *   - file 'run_id.txt' containing the final run_id
 */
process infer_run_id {
  tag "infer_run_id"

  // No container needed; busybox/sh coreutils are enough
  input:
    path input_dir
    val explicit_id
    val default_id
    val samplesheet

  output:
    path 'run_id.txt'

  script:
    """
    set -euo pipefail

    # 1) explicit_id wins if provided and non-empty
    if [ -n "${explicit_id}" ]; then
      echo "${explicit_id}" > run_id.txt
      exit 0
    fi

    # 2) try SampleSheet.csv if requested
    use_ss="${samplesheet}"
    if [ "\${use_ss}" = "true" ] || [ "\${use_ss}" = "True" ]; then
      sheet=\$(find "\$(realpath "${input_dir}")" -maxdepth 1 -type f -name "SampleSheet.csv" | head -1 || true)
      if [ -n "\$sheet" ]; then
        # Accept RunName or RunID in first column, value in the 2nd column
        runid=\$(grep -E '^(RunName|RunID),' "\$sheet" | head -1 | cut -d',' -f2 | tr -d '\r' || true)
        if [ -n "\$runid" ]; then
          echo "\$runid" > run_id.txt
          exit 0
        fi
      fi
    fi

    # 3) fallback to default_id
    echo "${default_id}" > run_id.txt
    """
}
