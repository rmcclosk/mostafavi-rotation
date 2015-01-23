ALTER TABLE expression DROP CONSTRAINT IF EXISTS fk_expression_patient;
ALTER TABLE expression DROP CONSTRAINT IF EXISTS fk_expression_gene;
ALTER TABLE expression ADD CONSTRAINT fk_expression_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene
    FOREIGN KEY (gene_id) REFERENCES gene(id);
ANALYZE expression;
