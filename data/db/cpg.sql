DROP TABLE IF EXISTS cpg;
CREATE TABLE cpg (
    id TEXT NOT NULL PRIMARY KEY,
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    forward INTEGER NOT NULL,
    CHECK (forward IN (0, 1))
);
