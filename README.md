# VarFlow

VarFlow is a Nextflow DSL2 pipeline for targeted DNA sequencing analysis. It orchestrates containerized modules for alignment, SNV calling, coverage QC, CNV analysis, and variant annotation, and it can start from FASTQ, BAM, VCF, or mixed BAM/VCF inputs depending on how far upstream processing has already been completed.

## What VarFlow Does

VarFlow standardizes routine panel and exome analysis into a single reproducible workflow:

- Aligns paired-end FASTQs to `hg19` or `hg38`
- Performs SNV calling from aligned BAMs
- Runs coverage QC with mode-specific minimum coverage defaults
- Runs CNV analysis for `wes` and `amplicon` workflows
- Annotates SNVs with VEP
- Runs amplicon-only indel calling and annotation when enabled
- Publishes all outputs into a single run-specific directory together with a pipeline log file

All analysis steps run inside Docker containers pinned in the workflow modules.

## Workflow Modes

VarFlow supports three analysis modes:

| Mode | Intended use | Default `mincov` | Default `minvaf` | Default `minvad` | Notes |
| --- | --- | ---: | ---: | ---: | --- |
| `wes` | Whole-exome / hybrid capture style runs | 200 | 1.0 | 10 | CNV enabled by default |
| `amplicon` | Amplicon panel sequencing | 400 | 1.5 | 10 | Indel calling enabled unless `--skip_indel` is set |
| `mrd` | MRD-oriented processing | 10000 for coverage QC, 5000 for annotation | 0.1 | 3 | CNV is skipped automatically |

Additional mode-dependent behavior in alignment:

- `wes`: defaults to `dedup_mode=umi`
- `amplicon`: defaults to `dedup_mode=none` and skips trimming unless overridden
- `mrd`: defaults to `dedup_mode=umi`; optional `--extract_umis` is supported

## Supported Input Entry Points

Exactly one of the following input options must be provided:

| Input option | Expected content | Pipeline entry point |
| --- | --- | --- |
| `--reads_dir` | Paired FASTQs | Full workflow starting with alignment |
| `--bams_dir` | BAM files | Starts from SNV calling / downstream analyses |
| `--vcfs_dir` | VCF files | Annotation only |
| `--bam_vcf_dir` | BAM and VCF files in one directory | Coverage QC, CNV, annotation, and optional indel calling |

Run ID selection is resolved in this order:

1. `--run_id` if explicitly supplied
2. `RunName` or `RunID` from `SampleSheet.csv` in the input directory when `--samplesheet true`
3. An auto-generated default such as `myeloid_hg38_r123456`

## Requirements

- Java 8 or newer
- Nextflow `24.10.0` or newer
- Docker
- Local VEP cache directory for annotation, defaulting to `$HOME/.vep`

## Installation

```bash
git clone https://github.com/mvz-hp/VarFlow.git
cd VarFlow
```

You can also run the published pipeline directly:

```bash
nextflow run mvz-hp/VarFlow -profile docker [options]
```

## Common Run Examples

### 1. Full WES run from FASTQs

```bash
nextflow run main.nf \
  -profile docker \
  --mode wes \
  --panel wes_panel \
  --reads_dir /path/to/fastqs \
  --run_id WES_run_001 \
  --assembly hg38 \
  --vep_cache "$HOME/.vep" \
  --cpus 16
```

### 2. Amplicon run from BAMs

```bash
nextflow run main.nf \
  -profile docker \
  --mode amplicon \
  --panel myeloid \
  --bams_dir /path/to/bams \
  --assembly hg38 \
  --mincov 500 \
  --minvaf 2.0 \
  --cpus 8
```

### 3. Annotation-only run from VCFs

```bash
nextflow run main.nf \
  -profile docker \
  --mode wes \
  --panel wes_panel \
  --vcfs_dir /path/to/vcfs \
  --vep_cache "$HOME/.vep"
```

### 4. MRD-oriented run from FASTQs

```bash
nextflow run main.nf \
  -profile docker \
  --mode mrd \
  --panel mrd \
  --reads_dir /path/to/fastqs \
  --assembly hg38 \
  --extract_umis \
  --cpus 16
```

## Parameters

### Required in normal use

- `--mode`: `wes`, `amplicon`, or `mrd`
- `--panel`: one of `wes_panel`, `lymphom`, `myeloid`, `mrd`
- One input directory option: `--reads_dir`, `--bams_dir`, `--vcfs_dir`, or `--bam_vcf_dir`

### Frequently used

| Parameter | Description | Default |
| --- | --- | --- |
| `--run_id` | Explicit run identifier | Auto-resolved |
| `--assembly` | Reference genome | `hg38` |
| `--vep_cache` | Local VEP cache path mounted into annotation container | `$HOME/.vep` |
| `--cpus` | CPUs per process | `4` |
| `--samplesheet` | Try to infer run ID from `SampleSheet.csv` | `true` |

### Analysis thresholds

| Parameter | Meaning | Default |
| --- | --- | --- |
| `--mincov` | Minimum coverage threshold | Mode-dependent |
| `--minvaf` | Minimum variant allele frequency threshold | Mode-dependent |
| `--minvad` | Minimum variant allele depth threshold | `10` for `wes` and `amplicon`, `3` for `mrd` |

### Optional behavior switches

| Parameter | Effect |
| --- | --- |
| `--skip_covqc` | Skip coverage QC |
| `--skip_cnv` | Skip CNV analysis |
| `--skip_indel` | Skip indel calling and indel annotation in `amplicon` mode |
| `--dedup_mode` | Override alignment deduplication mode |
| `--skip_trim` | Pass through to alignment step |
| `--extract_umis` | Enable UMI extraction in `mrd` mode |
| `--help` | Print workflow help |

## Outputs

Each run creates a unique publish directory in the launch directory:

```text
varflow.<run_id>.<yyyy-MM-dd>/
```

If a directory with that name already exists, VarFlow appends an incrementing suffix such as `_1`.

Typical outputs include:

```text
varflow.<run_id>.<date>/
├── ngs_dna_align.<run_id>/
├── ngs_snv_call.<run_id>/
├── panel_cov_qc.<run_id>/
├── panel_cnv_analysis.<run_id>/
├── panel_var_annotate.<run_id>/
├── panel_indel_call.<run_id>/                  # amplicon mode only
├── panel_var_annotate.indel.<run_id>/          # amplicon mode only
└── varflow_log_file.<run_id>.txt
```

The exact set of folders depends on the selected mode, entry point, and skip flags.

## Operational Notes

- `workDir` is configured as `$HOME/nf-work`
- Docker is enabled by default in `nextflow.config`
- Published outputs are copied, not symlinked
- The pipeline writes a log file containing the VarFlow version, Nextflow version, run timestamp, run ID, and module versions

## Help and Cleanup

Show the built-in help:

```bash
nextflow run main.nf --help
```

Clean old Nextflow work data when appropriate:

```bash
nextflow clean -f
```

## Development

Before opening a pull request:

1. Run the pipeline on a representative small dataset.
2. Verify the expected output directories for the chosen mode and input type.
3. Update [CHANGELOG.md](/mnt/d/GitHub/VarFlow/CHANGELOG.md) if behavior or module versions changed.

## License

MIT License. See [LICENSE](LICENSE).
