DROP TABLE IF EXISTS chromosome CASCADE;
CREATE TABLE chromosome (
    chrom SMALLINT NOT NULL PRIMARY KEY,
    size INTEGER NOT NULL,
    CHECK (chrom >= 1 AND chrom <= 22)
);
