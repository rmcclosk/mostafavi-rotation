DROP TABLE IF EXISTS snp CASCADE;

-- main table
CREATE TABLE snp (
    rsid INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL
);

-- load data
COPY snp FROM '../db/snp.tsv';

-- keys
ALTER TABLE snp ADD CONSTRAINT pk_snp PRIMARY KEY (rsid);
ALTER TABLE snp ADD CONSTRAINT fk_snp_chrom FOREIGN KEY (chrom) REFERENCES chromosome (chrom);

-- index
CREATE INDEX idx_snp_chrom_position ON snp(chrom, position);

-- analyze
ANALYZE snp;
