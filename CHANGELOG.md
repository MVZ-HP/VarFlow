# Changelog

## [1.0.0] - 05.08.2025
### Hinzugefügt
- Initiale Version der nextflow pipeline `VarFlow`.
  - Module für Alignment (`ngs_dna_align`), Coverage-QC (`panel_cov_qc`),  
    CNV-Analyse (`panel_cnv_analysis`), SNV-Calling (`ngs_snv_call`)  
    und Annotation (`panel_var_annotate`), sowie Indel-Calling (`panel_indel_call`).  
  - Docker-Profile für reproduzierbare Ausführung.  
  - Automatisches Zusammenstellen aller Outputs in ein zentrales  
    `results/varflow.<run_id>.<date>`-Verzeichnis.
  - Modus-Auswahl über `--mode` (`wes` oder `amplicon`).
  - Input-Optionen: Ordner mit FASTQs, BAMs, VCFs, oder BAMs und VCFs