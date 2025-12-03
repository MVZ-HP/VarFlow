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