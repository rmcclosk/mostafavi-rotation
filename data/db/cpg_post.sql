ALTER TABLE cpg DROP CONSTRAINT  IF EXISTS fk_cpg_chrom;
ALTER TABLE cpg ADD CONSTRAINT fk_cpg_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);
ANALYZE cpg;
