DROP TABLE IF EXISTS genotype;
CREATE TABLE genotype (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    ref TEXT NOT NULL,
    alt TEXT NOT NULL,
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, chrom, position),
    CHECK (0 <= value AND value <= 2),
    CHECK (ref IN ('A', 'C', 'G', 'T') AND alt IN ('A', 'C', 'G', 'T'))
);
