DROP TABLE IF EXISTS expression CASCADE;

-- main table
CREATE TABLE expression (
    patient_id INTEGER NOT NULL,
    gene_id INTEGER NOT NULL,
    value REAL NOT NULL
);

-- load data
COPY expression FROM '../db/expression.tsv';

-- keys
ALTER TABLE expression ADD CONSTRAINT fk_expression_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene FOREIGN KEY (gene_id) REFERENCES gene(id);

-- indices
CREATE INDEX idx_expression ON expression (patient_id, gene_id);

-- analyse
ANALYZE expression;
