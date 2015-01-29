DROP TABLE IF EXISTS genotype CASCADE;

-- main table
CREATE TABLE genotype (
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL,
    value REAL NOT NULL
);

-- load data
COPY genotype FROM '../db/genotype.tsv';

-- foreign key constraints
ALTER TABLE genotype ADD CONSTRAINT fk_genotype_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype ADD CONSTRAINT fk_genotype_chrom 
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

-- indices
CREATE INDEX idx_genotype ON genotype(chrom, position);
