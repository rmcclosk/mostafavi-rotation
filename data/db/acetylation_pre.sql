DROP TABLE IF EXISTS acetylation;
CREATE TABLE acetylation (
    id BIGSERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    peak_start INTEGER NOT NULL,
    peak_end INTEGER NOT NULL,
    value REAL NOT NULL
);
