ALTER TABLE genotype DROP CONSTRAINT IF EXISTS fk_genotype_chrom;
ALTER TABLE genotype ADD CONSTRAINT fk_genotype_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

ALTER TABLE genotype DROP CONSTRAINT IF EXISTS fk_genotype_patient;
ALTER TABLE genotype ADD CONSTRAINT fk_genotype_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);

ALTER TABLE genotype DROP CONSTRAINT IF EXISTS check_genotype_value;
ALTER TABLE genotype ADD CONSTRAINT check_genotype_value
    CHECK (0 <= value AND value <= 2);

ALTER TABLE genotype DROP CONSTRAINT IF EXISTS check_genotype_ref;
ALTER TABLE genotype ADD CONSTRAINT check_genotype_ref
    CHECK (ref IN ('A', 'C', 'G', 'T'));

ALTER TABLE genotype DROP CONSTRAINT IF EXISTS check_genotype_alt;
ALTER TABLE genotype ADD CONSTRAINT check_genotype_alt
    CHECK (alt IN ('A', 'C', 'G', 'T'));

ANALYZE genotype;
