DROP TABLE IF EXISTS acetylation;

-- main table
CREATE TABLE acetylation (
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    peak_start INTEGER NOT NULL,
    peak_end INTEGER NOT NULL,
    value REAL NOT NULL
);

-- load data
COPY acetylation FROM '../db/acetylation.tsv';

-- keys
ALTER TABLE acetylation ADD CONSTRAINT fk_acetylation_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation ADD CONSTRAINT fk_acetylation_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

-- index
CREATE INDEX idx_acetylation ON acetylation (chrom, peak_start);

-- analyse
ANALYZE acetylation;
