DROP TABLE IF EXISTS gene CASCADE;

-- main table
CREATE TABLE gene (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(36) NOT NULL,
    chrom SMALLINT NOT NULL,
    forward BOOLEAN NOT NULL
);

-- partition tables
CREATE TABLE IF NOT EXISTS gene_chr22 ( ) INHERITS (gene);

-- insert trigger
CREATE OR REPLACE FUNCTION trg_gene_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.chrom = 22 ) THEN
        INSERT INTO gene_chr22 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Bad chromosome';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;
CREATE TRIGGER trg_gene_insert
    BEFORE INSERT ON gene
    FOR EACH ROW EXECUTE PROCEDURE trg_gene_insert();

-- load data
COPY gene FROM '../db/gene.tsv';

-- primary keys
ALTER TABLE gene_chr22 ADD CONSTRAINT pk_gene PRIMARY KEY (id);

-- foreign key constraints
ALTER TABLE gene ADD CONSTRAINT fk_gene_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

-- check constraints
ALTER TABLE gene_chr22 ADD CONSTRAINT chk_gene_chrom_22 CHECK (chrom = 22);
