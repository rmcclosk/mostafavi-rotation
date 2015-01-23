DROP TABLE IF EXISTS genotype;
CREATE TABLE genotype (
    id BIGSERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL,
    ref CHAR(1) NOT NULL,
    alt CHAR(1) NOT NULL,
    value REAL NOT NULL
);
