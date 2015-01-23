ALTER TABLE acetylation DROP CONSTRAINT IF EXISTS fk_acetylation_patient;
ALTER TABLE acetylation DROP CONSTRAINT IF EXISTS fk_acetylation_chrom;
ALTER TABLE acetylation ADD CONSTRAINT fk_acetylation_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation ADD CONSTRAINT fk_acetylation_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);
ANALYZE acetylation;
