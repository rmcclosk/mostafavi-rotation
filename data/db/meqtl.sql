DROP TABLE IF EXISTS meqtl CASCADE;

-- main table
CREATE TABLE meqtl (
    chrom SMALLINT NOT NULL,
    cpg_position INTEGER NOT NULL,
    snp_position INTEGER NOT NULL,
    rho REAL NOT NULL,
    p_value DOUBLE PRECISION NOT NULL,
    adj_p_value DOUBLE PRECISION NOT NULL DEFAULT 1,
    q_value DOUBLE PRECISION NOT NULL DEFAULT 1
);

-- partition tables
CREATE TABLE meqtl_chr1 ( CHECK(chrom = 1) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr2 ( CHECK(chrom = 2) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr3 ( CHECK(chrom = 3) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr4 ( CHECK(chrom = 4) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr5 ( CHECK(chrom = 5) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr6 ( CHECK(chrom = 6) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr7 ( CHECK(chrom = 7) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr8 ( CHECK(chrom = 8) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr9 ( CHECK(chrom = 9) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr10 ( CHECK(chrom = 10) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr11 ( CHECK(chrom = 11) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr12 ( CHECK(chrom = 12) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr13 ( CHECK(chrom = 13) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr14 ( CHECK(chrom = 14) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr15 ( CHECK(chrom = 15) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr16 ( CHECK(chrom = 16) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr17 ( CHECK(chrom = 17) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr18 ( CHECK(chrom = 18) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr19 ( CHECK(chrom = 19) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr20 ( CHECK(chrom = 20) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr21 ( CHECK(chrom = 21) ) INHERITS (meqtl);
CREATE TABLE meqtl_chr22 ( CHECK(chrom = 22) ) INHERITS (meqtl);

-- trigger
CREATE OR REPLACE FUNCTION meqtl_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom )
    WHEN 1 THEN INSERT INTO meqtl_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO meqtl_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO meqtl_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO meqtl_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO meqtl_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO meqtl_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO meqtl_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO meqtl_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO meqtl_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO meqtl_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO meqtl_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO meqtl_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO meqtl_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO meqtl_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO meqtl_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO meqtl_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO meqtl_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO meqtl_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO meqtl_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO meqtl_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO meqtl_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO meqtl_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Wrong chromosome';
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_meqtl_trigger
    BEFORE INSERT ON meqtl
    FOR EACH ROW EXECUTE PROCEDURE meqtl_insert_trigger();

-- load data
COPY meqtl_chr1 FROM '../db/meqtl.tsv';
