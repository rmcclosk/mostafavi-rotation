ALTER TABLE methylation DROP CONSTRAINT IF EXISTS fk_methylation_patient;
ALTER TABLE methylation ADD CONSTRAINT fk_methylation_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);

ALTER TABLE methylation DROP CONSTRAINT IF EXISTS fk_methylation_cpg;
ALTER TABLE methylation ADD CONSTRAINT fk_methylation_cpg
    FOREIGN KEY cpg_id REFERENCES cpg(id);

ANALYZE methylation;
