# Changelog

## [2.0.1] - 17.07.2026
### Geändert
- `--mode` entfernt; `--panel` wählt den Workflow jetzt eindeutig aus.
- `b_lymphoid` als UMI-basierter Amplicon-Workflow mit SNV- und Indel-Analyse, aber ohne CNV-Analyse ergänzt.
- MRD-Workflow an den validierten manuellen Ablauf angepasst:
  - UMI-Extraktion und indel-freundliches Alignment sind standardmäßig aktiv
  - SNV-Calling verwendet `--no_pre_realign`
  - Coverage-QC verwendet standardmäßig `mincov=15000`
  - Annotation verwendet standardmäßig `mincov=6000`, `minvaf=0.2`, `minvad=30` und schließt `weak_evidence` aus
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.1
  - `ngs_snv_call`: 1.0.2
  - `panel_cov_qc`: 1.0.14
  - `panel_cnv_analysis`: 1.0.11
  - `panel_indel_call`: 1.0.3
  - `panel_var_annotate`: 1.0.8

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

## [2.0.0] - 29.06.2026
### Hinzugefügt
- Gesamt-validierte Pipeline
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.1
  - `ngs_snv_call`: 1.0.2
  - `panel_cov_qc`: 1.0.13
  - `panel_cnv_analysis`: 1.0.11
  - `panel_indel_call`: 1.0.3
  - `panel_var_annotate`: 1.0.7

  ## [2.0.1] - 05.08.2026
### Hinzugefügt
- MRD und B-Lymphoid panels
- Modul-Versionen:
  - `ngs_dna_align`: 1.0.1
  - `ngs_snv_call`: 1.0.2
  - `panel_cov_qc`: 1.0.14
  - `panel_cnv_analysis`: 1.0.11
  - `panel_indel_call`: 1.0.3
  - `panel_var_annotate`: 1.0.8
