#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process resolve_publish_dir {
  tag "${run_id}"
  cpus 1

  input:
    val run_id

  output:
    path 'publish_dir.txt'

  script:
    """
    set -euo pipefail

    base="varflow.${run_id}.${params.date}"
    launch_dir="${workflow.launchDir}"
    idx=0

    while true; do
      if [ "\$idx" -eq 0 ]; then
        candidate="\$base"
      else
        candidate="\${base}_\${idx}"
      fi

      # Atomically reserve the publish directory so concurrent runs cannot pick the same name.
      if mkdir -p "\$launch_dir" && mkdir "\$launch_dir/\$candidate" 2>/dev/null; then
        printf '%s\\n' "\$candidate" > publish_dir.txt
        exit 0
      fi

      idx=\$((idx + 1))
    done
    """
}
