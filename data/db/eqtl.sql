DROP TABLE IF EXISTS eqtl CASCADE;

-- main table
CREATE TABLE eqtl (
    chrom SMALLINT NOT NULL,
    gene_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    rho REAL NOT NULL,
    p_value DOUBLE PRECISION NOT NULL
);

-- partition tables
CREATE TABLE eqtl_chr1 ( CHECK(chrom = 1) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr2 ( CHECK(chrom = 2) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr3 ( CHECK(chrom = 3) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr4 ( CHECK(chrom = 4) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr5 ( CHECK(chrom = 5) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr6 ( CHECK(chrom = 6) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr7 ( CHECK(chrom = 7) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr8 ( CHECK(chrom = 8) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr9 ( CHECK(chrom = 9) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr10 ( CHECK(chrom = 10) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr11 ( CHECK(chrom = 11) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr12 ( CHECK(chrom = 12) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr13 ( CHECK(chrom = 13) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr14 ( CHECK(chrom = 14) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr15 ( CHECK(chrom = 15) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr16 ( CHECK(chrom = 16) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr17 ( CHECK(chrom = 17) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr18 ( CHECK(chrom = 18) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr19 ( CHECK(chrom = 19) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr20 ( CHECK(chrom = 20) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr21 ( CHECK(chrom = 21) ) INHERITS (eqtl);
CREATE TABLE eqtl_chr22 ( CHECK(chrom = 22) ) INHERITS (eqtl);

-- trigger
CREATE OR REPLACE FUNCTION eqtl_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom )
    WHEN 1 THEN INSERT INTO eqtl_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO eqtl_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO eqtl_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO eqtl_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO eqtl_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO eqtl_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO eqtl_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO eqtl_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO eqtl_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO eqtl_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO eqtl_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO eqtl_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO eqtl_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO eqtl_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO eqtl_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO eqtl_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO eqtl_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO eqtl_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO eqtl_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO eqtl_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO eqtl_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO eqtl_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Wrong chromosome';
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_eqtl_trigger
    BEFORE INSERT ON eqtl
    FOR EACH ROW EXECUTE PROCEDURE eqtl_insert_trigger();

-- load data
COPY eqtl FROM '../db/eqtl.tsv';

-- foreign key constraints
ALTER TABLE eqtl_chr1 ADD CONSTRAINT fk_eqtl_gene_chr1 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr2 ADD CONSTRAINT fk_eqtl_gene_chr2 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr3 ADD CONSTRAINT fk_eqtl_gene_chr3 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr4 ADD CONSTRAINT fk_eqtl_gene_chr4 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr5 ADD CONSTRAINT fk_eqtl_gene_chr5 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr6 ADD CONSTRAINT fk_eqtl_gene_chr6 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr7 ADD CONSTRAINT fk_eqtl_gene_chr7 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr8 ADD CONSTRAINT fk_eqtl_gene_chr8 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr9 ADD CONSTRAINT fk_eqtl_gene_chr9 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr10 ADD CONSTRAINT fk_eqtl_gene_chr10 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr11 ADD CONSTRAINT fk_eqtl_gene_chr11 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr12 ADD CONSTRAINT fk_eqtl_gene_chr12 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr13 ADD CONSTRAINT fk_eqtl_gene_chr13 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr14 ADD CONSTRAINT fk_eqtl_gene_chr14 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr15 ADD CONSTRAINT fk_eqtl_gene_chr15 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr16 ADD CONSTRAINT fk_eqtl_gene_chr16 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr17 ADD CONSTRAINT fk_eqtl_gene_chr17 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr18 ADD CONSTRAINT fk_eqtl_gene_chr18 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr19 ADD CONSTRAINT fk_eqtl_gene_chr19 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr20 ADD CONSTRAINT fk_eqtl_gene_chr20 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr21 ADD CONSTRAINT fk_eqtl_gene_chr21 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE eqtl_chr22 ADD CONSTRAINT fk_eqtl_gene_chr22 FOREIGN KEY (gene_id) REFERENCES gene(id);
