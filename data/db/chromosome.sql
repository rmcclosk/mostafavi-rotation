DROP TABLE IF EXISTS chromosome;
CREATE TABLE chromosome (
    chrom INTEGER NOT NULL PRIMARY KEY,
    size INTEGER NOT NULL,
    CHECK (chrom >= 1 AND chrom <= 22)
);
