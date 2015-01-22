DROP TABLE IF EXISTS expression;
CREATE TABLE expression (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    gene_id TEXT NOT NULL REFERENCES gene(id),
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, gene_id)
);
