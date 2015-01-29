DROP TABLE IF EXISTS methylation;

-- main table
CREATE TABLE methylation (
    patient_id INTEGER NOT NULL,
    cpg_id VARCHAR(16) NOT NULL,
    value REAL NOT NULL
);

-- import data
COPY methylation FROM '../db/methylation.tsv';

-- foreign keys
ALTER TABLE methylation ADD CONSTRAINT fk_methylation_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation ADD CONSTRAINT fk_methylation_cpg
    FOREIGN KEY cpg_id REFERENCES cpg(id);

-- index
CREATE INDEX idx_methylation ON methylation (cpg_id);

-- analyse
ANALYZE methylation;
