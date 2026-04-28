# Changelog

## [1.0.0] - 05.08.2025
### Hinzugefügt
- Initiale Version der nextflow pipeline `VarFlow`.
- Module für Alignment (`ngs_dna_align`), Coverage-QC (`panel_cov_qc`),  
  CNV-Analyse (`panel_cnv_analysis`), SNV-Calling (`ngs_snv_call`)  
  und Annotation (`panel_var_annotate`), sowie Indel-Calling (`panel_indel_call`).  
- Automatisches Zusammenstellen aller Outputs in ein zentrales  
  `varflow.<run_id>.<date>`-Verzeichnis.
- Modus-Auswahl über `--mode` (`wes` oder `amplicon`).
- Input-Optionen: Ordner mit FASTQs, BAMs, VCFs, oder BAMs und VCFs
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.0
  - `ngs_snv_call`: 1.0.1
  - `panel_cov_qc`: 1.0.9
  - `panel_cnv_analysis`: 1.0.8
  - `panel_indel_call`: 1.0.1
  - `panel_var_annotate`: 1.0.3

## [1.0.1] - 01.10.2025
### Hinzugefügt
- Run-ID wird in SampleSheet.csv gesucht wenn nicht explizit angegeben.
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.0
  - `ngs_snv_call`: 1.0.1
  - `panel_cov_qc`: 1.0.10
  - `panel_cnv_analysis`: 1.0.9
  - `panel_indel_call`: 1.0.2
  - `panel_var_annotate`: 1.0.4

## [1.0.2] - 03.11.2025
### Hinzugefügt
- Option, um panel_indel_call im Amplicon-Modus zu überspringen (`skip_indel`).
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.0
  - `ngs_snv_call`: 1.0.1
  - `panel_cov_qc`: 1.0.11
  - `panel_cnv_analysis`: 1.0.10
  - `panel_indel_call`: 1.0.2
  - `panel_var_annotate`: 1.0.5

## [1.0.3] - 03.12.2025
### Hinzugefügt
- VarFlow-Log-Datei wird erstellt
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.0
  - `ngs_snv_call`: 1.0.1
  - `panel_cov_qc`: 1.0.11
  - `panel_cnv_analysis`: 1.0.10
  - `panel_indel_call`: 1.0.2
  - `panel_var_annotate`: 1.0.6

## [1.0.4] - 12.03.2026
### Hinzugefügt
- VarFlow für MRD teilweise angepasst:
  - `mrd` als Analysemodus ergänzt
  - `mrd` als Panel ergänzt
  - MRD-spezifische Default-Schwellen für Coverage-QC und Annotation ergänzt
  - Option `extract_umis` für MRD-Alignment ergänzt
  - CNV-Analyse wird im Modus `mrd` nicht ausgeführt
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.1
  - `ngs_snv_call`: 1.0.1
  - `panel_cov_qc`: 1.0.12
  - `panel_cnv_analysis`: 1.0.10
  - `panel_indel_call`: 1.0.2
  - `panel_var_annotate`: 1.0.7

## [1.0.5] - 28.04.2026
### Hinzugefügt
- CovQC v1.0.13: Anhand-PDF wird erstellt
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.1
  - `ngs_snv_call`: 1.0.1
  - `panel_cov_qc`: 1.0.13
  - `panel_cnv_analysis`: 1.0.10
  - `panel_indel_call`: 1.0.2
  - `panel_var_annotate`: 1.0.7