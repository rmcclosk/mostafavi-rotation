DROP TABLE IF EXISTS snp;
DROP INDEX IF EXISTS idx_snp_chrom_position;

CREATE TABLE snp (
    rsid TEXT NOT NULL PRIMARY KEY,
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    forward INTEGER NOT NULL,
    ref TEXT NOT NULL,
    alt TEXT NOT NULL,
    CHECK (ref IN ('A', 'C', 'G', 'T') AND alt IN ('A', 'C', 'G', 'T')),
    CHECK (forward IN (0, 1))
);

CREATE INDEX idx_snp_chrom_position ON snp (chrom, position);
