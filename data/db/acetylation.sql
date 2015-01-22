DROP TABLE IF EXISTS acetylation;
CREATE TABLE acetylation (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    peak_start INTEGER NOT NULL,
    peak_end INTEGER NOT NULL,
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, chrom, peak_start, peak_end)
);
