DROP TABLE IF EXISTS methylation;
CREATE TABLE methylation (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    cpg_id TEXT NOT NULL REFERENCES cpg(id),
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, cpg_id)
);
