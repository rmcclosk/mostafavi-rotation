DROP TABLE IF EXISTS gene CASCADE;

-- main table
CREATE TABLE gene (
    id INTEGER NOT NULL,
    name VARCHAR(36) NOT NULL,
    chrom SMALLINT NOT NULL,
    gene_start INTEGER NOT NULL,
    gene_end INTEGER NOT NULL,
    forward BOOLEAN NOT NULL
);

-- load data
COPY gene FROM '../db/gene.tsv';

-- keys
ALTER TABLE gene ADD CONSTRAINT pk_gene PRIMARY KEY (id);
ALTER TABLE gene ADD CONSTRAINT fk_gene_chrom FOREIGN KEY (chrom) REFERENCES chromosome (chrom);

-- views
CREATE VIEW tss (gene_id, tss) AS 
SELECT id, CASE WHEN forward THEN gene_start ELSE gene_end END
FROM gene;
