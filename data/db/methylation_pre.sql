DROP TABLE IF EXISTS methylation;
CREATE TABLE methylation (
    id BIGSERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    cpg_id VARCHAR(16) NOT NULL,
    value REAL NOT NULL
);
