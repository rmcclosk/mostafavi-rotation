DROP TABLE IF EXISTS genotype CASCADE;

-- main table
CREATE TABLE genotype (
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL,
    value SMALLINT NOT NULL
);

-- partition tables
CREATE TABLE genotype_chr1 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr2 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr3 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr4 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr5 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr6 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr7 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr8 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr9 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr10 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr11 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr12 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr13 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr14 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr15 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr16 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr17 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr18 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr19 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr20 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr21 ( ) INHERITS (genotype);
CREATE TABLE genotype_chr22 ( ) INHERITS (genotype);

-- trigger
CREATE OR REPLACE FUNCTION genotype_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom )
    WHEN 1 THEN INSERT INTO genotype_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO genotype_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO genotype_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO genotype_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO genotype_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO genotype_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO genotype_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO genotype_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO genotype_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO genotype_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO genotype_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO genotype_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO genotype_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO genotype_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO genotype_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO genotype_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO genotype_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO genotype_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO genotype_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO genotype_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO genotype_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO genotype_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Wrong chromosome';
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_genotype_trigger
    BEFORE INSERT ON genotype
    FOR EACH ROW EXECUTE PROCEDURE genotype_insert_trigger();
