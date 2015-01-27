DROP TABLE IF EXISTS gene CASCADE;

-- main table
CREATE TABLE gene (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(36) NOT NULL,
    chrom SMALLINT NOT NULL,
    gene_start INTEGER NOT NULL,
    gene_end INTEGER NOT NULL,
    forward BOOLEAN NOT NULL
);

-- partition tables
CREATE TABLE IF NOT EXISTS gene_chr1 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr2 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr3 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr4 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr5 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr6 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr7 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr8 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr9 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr10 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr11 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr12 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr13 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr14 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr15 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr16 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr17 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr18 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr19 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr20 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr21 ( ) INHERITS (gene);
CREATE TABLE IF NOT EXISTS gene_chr22 ( ) INHERITS (gene);

-- insert trigger
CREATE OR REPLACE FUNCTION trg_gene_insert()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom ) 
    WHEN 1 THEN INSERT INTO gene_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO gene_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO gene_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO gene_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO gene_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO gene_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO gene_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO gene_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO gene_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO gene_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO gene_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO gene_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO gene_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO gene_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO gene_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO gene_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO gene_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO gene_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO gene_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO gene_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO gene_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO gene_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Bad chromosome';
    END CASE;
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
ALTER TABLE gene_chr1 ADD CONSTRAINT pk_gene_chr1 PRIMARY KEY (id);
ALTER TABLE gene_chr2 ADD CONSTRAINT pk_gene_chr2 PRIMARY KEY (id);
ALTER TABLE gene_chr3 ADD CONSTRAINT pk_gene_chr3 PRIMARY KEY (id);
ALTER TABLE gene_chr4 ADD CONSTRAINT pk_gene_chr4 PRIMARY KEY (id);
ALTER TABLE gene_chr5 ADD CONSTRAINT pk_gene_chr5 PRIMARY KEY (id);
ALTER TABLE gene_chr6 ADD CONSTRAINT pk_gene_chr6 PRIMARY KEY (id);
ALTER TABLE gene_chr7 ADD CONSTRAINT pk_gene_chr7 PRIMARY KEY (id);
ALTER TABLE gene_chr8 ADD CONSTRAINT pk_gene_chr8 PRIMARY KEY (id);
ALTER TABLE gene_chr9 ADD CONSTRAINT pk_gene_chr9 PRIMARY KEY (id);
ALTER TABLE gene_chr10 ADD CONSTRAINT pk_gene_chr10 PRIMARY KEY (id);
ALTER TABLE gene_chr11 ADD CONSTRAINT pk_gene_chr11 PRIMARY KEY (id);
ALTER TABLE gene_chr12 ADD CONSTRAINT pk_gene_chr12 PRIMARY KEY (id);
ALTER TABLE gene_chr13 ADD CONSTRAINT pk_gene_chr13 PRIMARY KEY (id);
ALTER TABLE gene_chr14 ADD CONSTRAINT pk_gene_chr14 PRIMARY KEY (id);
ALTER TABLE gene_chr15 ADD CONSTRAINT pk_gene_chr15 PRIMARY KEY (id);
ALTER TABLE gene_chr16 ADD CONSTRAINT pk_gene_chr16 PRIMARY KEY (id);
ALTER TABLE gene_chr17 ADD CONSTRAINT pk_gene_chr17 PRIMARY KEY (id);
ALTER TABLE gene_chr18 ADD CONSTRAINT pk_gene_chr18 PRIMARY KEY (id);
ALTER TABLE gene_chr19 ADD CONSTRAINT pk_gene_chr19 PRIMARY KEY (id);
ALTER TABLE gene_chr20 ADD CONSTRAINT pk_gene_chr20 PRIMARY KEY (id);
ALTER TABLE gene_chr21 ADD CONSTRAINT pk_gene_chr21 PRIMARY KEY (id);
ALTER TABLE gene_chr22 ADD CONSTRAINT pk_gene_chr22 PRIMARY KEY (id);

-- check constraints
ALTER TABLE gene_chr1 ADD CONSTRAINT chk_gene_chrom_1 CHECK (chrom = 1);
ALTER TABLE gene_chr2 ADD CONSTRAINT chk_gene_chrom_2 CHECK (chrom = 2);
ALTER TABLE gene_chr3 ADD CONSTRAINT chk_gene_chrom_3 CHECK (chrom = 3);
ALTER TABLE gene_chr4 ADD CONSTRAINT chk_gene_chrom_4 CHECK (chrom = 4);
ALTER TABLE gene_chr5 ADD CONSTRAINT chk_gene_chrom_5 CHECK (chrom = 5);
ALTER TABLE gene_chr6 ADD CONSTRAINT chk_gene_chrom_6 CHECK (chrom = 6);
ALTER TABLE gene_chr7 ADD CONSTRAINT chk_gene_chrom_7 CHECK (chrom = 7);
ALTER TABLE gene_chr8 ADD CONSTRAINT chk_gene_chrom_8 CHECK (chrom = 8);
ALTER TABLE gene_chr9 ADD CONSTRAINT chk_gene_chrom_9 CHECK (chrom = 9);
ALTER TABLE gene_chr10 ADD CONSTRAINT chk_gene_chrom_10 CHECK (chrom = 10);
ALTER TABLE gene_chr11 ADD CONSTRAINT chk_gene_chrom_11 CHECK (chrom = 11);
ALTER TABLE gene_chr12 ADD CONSTRAINT chk_gene_chrom_12 CHECK (chrom = 12);
ALTER TABLE gene_chr13 ADD CONSTRAINT chk_gene_chrom_13 CHECK (chrom = 13);
ALTER TABLE gene_chr14 ADD CONSTRAINT chk_gene_chrom_14 CHECK (chrom = 14);
ALTER TABLE gene_chr15 ADD CONSTRAINT chk_gene_chrom_15 CHECK (chrom = 15);
ALTER TABLE gene_chr16 ADD CONSTRAINT chk_gene_chrom_16 CHECK (chrom = 16);
ALTER TABLE gene_chr17 ADD CONSTRAINT chk_gene_chrom_17 CHECK (chrom = 17);
ALTER TABLE gene_chr18 ADD CONSTRAINT chk_gene_chrom_18 CHECK (chrom = 18);
ALTER TABLE gene_chr19 ADD CONSTRAINT chk_gene_chrom_19 CHECK (chrom = 19);
ALTER TABLE gene_chr20 ADD CONSTRAINT chk_gene_chrom_20 CHECK (chrom = 20);
ALTER TABLE gene_chr21 ADD CONSTRAINT chk_gene_chrom_21 CHECK (chrom = 21);
ALTER TABLE gene_chr22 ADD CONSTRAINT chk_gene_chrom_22 CHECK (chrom = 22);

-- views
CREATE VIEW tss (gene_id, gene_name, tss) AS 
SELECT id, name, CASE WHEN forward THEN gene_start ELSE gene_end END FROM gene;
