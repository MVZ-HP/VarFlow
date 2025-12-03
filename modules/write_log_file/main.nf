#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

process write_log_file {
  tag "${run_id}"
  cpus 1

  publishDir "varflow.${run_id}.${params.date}", mode: 'copy', overwrite: true

  input:
    tuple val(log_info), val(run_id)

  output:
    path "varflow_log_file.${run_id}.txt"

  script:

    // Collect all keys from all sections to compute a global width
    def pipeline_keys = log_info.Pipeline ? log_info.Pipeline.keySet() : []
    def module_keys   = log_info.Modules  ? log_info.Modules.keySet()  : []
    def param_keys    = log_info.Params   ? log_info.Params.keySet()   : []

    def all_keys = (pipeline_keys + module_keys + param_keys).collect { key -> key.toString() }
    def max_key_len = all_keys ? all_keys.collect { key -> key.size() }.max() : 0

    // Build the human-readable text
    def builder = new StringBuilder()

    builder << "VarFlow Log File\n"
    builder << "================\n\n"

    // Pipeline section
    builder << "Pipeline Information\n"
    builder << "--------------------\n"
    log_info.Pipeline.each { k, v ->
        builder << "${k.toString().padRight(max_key_len)}   ${v}\n"
    }
    // Add run id
    builder << "${'Run_ID'.padRight(max_key_len)}   ${run_id}\n"
    builder << "\n"

    // Modules section
    builder << "Module Versions\n"
    builder << "---------------\n"
    log_info.Modules.each { k, v ->
        builder << "${k.toString().padRight(max_key_len)}   ${v}\n"
    }
    builder << "\n"

    // Params section
    //builder << "Parameters\n"
    //builder << "----------\n"
    //log_info.Params.each { k, v ->
    //    builder << "${k.toString().padRight(max_key_len)}   ${v}\n"
    //}

    def text = builder.toString()

    """
    cat > varflow_log_file.${run_id}.txt << 'EOF'
${text}
EOF
    """
}
