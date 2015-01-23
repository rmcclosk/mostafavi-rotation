DROP TABLE IF EXISTS expression;
CREATE TABLE expression (
    id BIGSERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    gene_id VARCHAR(15) NOT NULL,
    value REAL NOT NULL
);
