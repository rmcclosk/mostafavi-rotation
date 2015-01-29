DROP TABLE IF EXISTS cpg;

-- main table
CREATE TABLE cpg (
    id VARCHAR(16) NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL
);

-- load data
COPY cpg FROM '../db/cpg.tsv';

-- keys
ALTER TABLE cpg ADD CONSTRAINT pk_cpg PRIMARY KEY (id);
ALTER TABLE cpg ADD CONSTRAINT fk_cpg_chrom FOREIGN KEY (chrom) REFERENCES chromosome (chrom);

-- index
CREATE INDEX idx_cpg ON cpg (chrom, position);
