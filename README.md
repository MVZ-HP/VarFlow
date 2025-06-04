# VarFlow

**VarFlow** is a modular Nextflow (DSL2) pipeline for DNA-seq variant analysis (alignment, coverage QC, CNV analysis, SNV calling, annotation). Each step runs in a Docker container for reproducibility.

---

## Prerequisites

- Java 8+  
- Nextflow (v24.10.0+)  
- Docker  
- (Optional) Pre-downloaded VEP cache at `$HOME/.vep`

---

## Installation

```bash
git clone https://github.com/mvz-hp/VarFlow.git
cd VarFlow
````

Or run directly from GitHub:

```bash
nextflow run mvz-hp/VarFlow -profile docker [options]
```

---

## Quickstart

```bash
nextflow run main.nf \
  -profile docker \
  --reads_dir   /path/to/fastq_folder \
  --run_id      myRunID \
  --assembly    hg38 \
  --panel       wes_panel \
  --mincov      200 \
  --vep_cache   "$HOME/.vep" \
  --cpus        16
```

* `--reads_dir`: folder containing paired FASTQs (`*_R1_*.fastq.gz` & `*_R2_*.fastq.gz`).
* `--run_id`: unique identifier (e.g. `WES123`).
* `--assembly`: `hg19` or `hg38` (default `hg38`).
* `--panel`: e.g. `wes_panel`.
* `--mincov`: minimum coverage (default `200`).
* `--vep_cache`: path to local VEP cache.
* `--cpus`: threads per step (default `4`).

On completion, a folder named `varflow.<run_id>.<date>/` contains subfolders:

```
ngs_dna_align.<run_id>/
panel_cov_qc.<run_id>/
panel_cnv_analysis.<run_id>/
ngs_snv_call.<run_id>/
panel_var_annotate.<run_id>/
```

---

## Cleaning Up

By default, VarFlow removes its `work/` directory when done. To manually clear it:

```bash
nextflow clean -f
```

---

## Contributing

Fork, edit, lint (`nextflow lint`), test on small data, and submit a pull request.

---

## License

MIT License. See [LICENSE](LICENSE).
