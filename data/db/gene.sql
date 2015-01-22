DROP TABLE IF EXISTS gene;
DROP TABLE IF EXISTS transcript;
DROP TABLE IF EXISTS exon;

CREATE TABLE gene (
    id TEXT NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    forward INTEGER NOT NULL,
    cds_start INTEGER,
    cds_end INTEGER,
    CHECK (forward IN (0, 1))
);

CREATE TABLE transcript (
    id TEXT NOT NULL PRIMARY KEY,
    gene_id TEXT NOT NULL REFERENCES gene(id)
);

CREATE TABLE exon (
    transcript_id TEXT NOT NULL REFERENCES transcript(id),
    exon_start INTEGER NOT NULL,
    exon_end INTEGER NOT NULL
);
