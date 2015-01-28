DROP TABLE IF EXISTS expression CASCADE;

-- main table
CREATE TABLE expression (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    gene_id INTEGER NOT NULL,
    value REAL NOT NULL
);

-- partition tables
CREATE TABLE expression_chr1 ( ) INHERITS (expression);
CREATE TABLE expression_chr2 ( ) INHERITS (expression);
CREATE TABLE expression_chr3 ( ) INHERITS (expression);
CREATE TABLE expression_chr4 ( ) INHERITS (expression);
CREATE TABLE expression_chr5 ( ) INHERITS (expression);
CREATE TABLE expression_chr6 ( ) INHERITS (expression);
CREATE TABLE expression_chr7 ( ) INHERITS (expression);
CREATE TABLE expression_chr8 ( ) INHERITS (expression);
CREATE TABLE expression_chr9 ( ) INHERITS (expression);
CREATE TABLE expression_chr10 ( ) INHERITS (expression);
CREATE TABLE expression_chr11 ( ) INHERITS (expression);
CREATE TABLE expression_chr12 ( ) INHERITS (expression);
CREATE TABLE expression_chr13 ( ) INHERITS (expression);
CREATE TABLE expression_chr14 ( ) INHERITS (expression);
CREATE TABLE expression_chr15 ( ) INHERITS (expression);
CREATE TABLE expression_chr16 ( ) INHERITS (expression);
CREATE TABLE expression_chr17 ( ) INHERITS (expression);
CREATE TABLE expression_chr18 ( ) INHERITS (expression);
CREATE TABLE expression_chr19 ( ) INHERITS (expression);
CREATE TABLE expression_chr20 ( ) INHERITS (expression);
CREATE TABLE expression_chr21 ( ) INHERITS (expression);
CREATE TABLE expression_chr22 ( ) INHERITS (expression);

-- trigger (kinda annoying)
CREATE OR REPLACE FUNCTION trg_expression_insert()
RETURNS TRIGGER AS $$
BEGIN
    CASE (SELECT chrom FROM gene WHERE id = NEW.gene_id) 
        WHEN ( 1 ) THEN INSERT INTO expression_chr1 VALUES (NEW.*);
        WHEN ( 2 ) THEN INSERT INTO expression_chr2 VALUES (NEW.*);
        WHEN ( 3 ) THEN INSERT INTO expression_chr3 VALUES (NEW.*);
        WHEN ( 4 ) THEN INSERT INTO expression_chr4 VALUES (NEW.*);
        WHEN ( 5 ) THEN INSERT INTO expression_chr5 VALUES (NEW.*);
        WHEN ( 6 ) THEN INSERT INTO expression_chr6 VALUES (NEW.*);
        WHEN ( 7 ) THEN INSERT INTO expression_chr7 VALUES (NEW.*);
        WHEN ( 8 ) THEN INSERT INTO expression_chr8 VALUES (NEW.*);
        WHEN ( 9 ) THEN INSERT INTO expression_chr9 VALUES (NEW.*);
        WHEN ( 10 ) THEN INSERT INTO expression_chr10 VALUES (NEW.*);
        WHEN ( 11 ) THEN INSERT INTO expression_chr11 VALUES (NEW.*);
        WHEN ( 12 ) THEN INSERT INTO expression_chr12 VALUES (NEW.*);
        WHEN ( 13 ) THEN INSERT INTO expression_chr13 VALUES (NEW.*);
        WHEN ( 14 ) THEN INSERT INTO expression_chr14 VALUES (NEW.*);
        WHEN ( 15 ) THEN INSERT INTO expression_chr15 VALUES (NEW.*);
        WHEN ( 16 ) THEN INSERT INTO expression_chr16 VALUES (NEW.*);
        WHEN ( 17 ) THEN INSERT INTO expression_chr17 VALUES (NEW.*);
        WHEN ( 18 ) THEN INSERT INTO expression_chr18 VALUES (NEW.*);
        WHEN ( 19 ) THEN INSERT INTO expression_chr19 VALUES (NEW.*);
        WHEN ( 20 ) THEN INSERT INTO expression_chr20 VALUES (NEW.*);
        WHEN ( 21 ) THEN INSERT INTO expression_chr21 VALUES (NEW.*);
        WHEN ( 22 ) THEN INSERT INTO expression_chr22 VALUES (NEW.*);
    --ELSE RAISE EXCEPTION 'Bad chromosome';
    ELSE NULL;
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_expression_insert
    BEFORE INSERT ON expression
    FOR EACH ROW EXECUTE PROCEDURE trg_expression_insert();

-- load data
COPY expression (patient_id, gene_id, value) FROM '../db/expression.tsv';

-- primary keys
ALTER TABLE expression_chr1 ADD CONSTRAINT pk_expression_chr1 PRIMARY KEY (id);
ALTER TABLE expression_chr2 ADD CONSTRAINT pk_expression_chr2 PRIMARY KEY (id);
ALTER TABLE expression_chr3 ADD CONSTRAINT pk_expression_chr3 PRIMARY KEY (id);
ALTER TABLE expression_chr4 ADD CONSTRAINT pk_expression_chr4 PRIMARY KEY (id);
ALTER TABLE expression_chr5 ADD CONSTRAINT pk_expression_chr5 PRIMARY KEY (id);
ALTER TABLE expression_chr6 ADD CONSTRAINT pk_expression_chr6 PRIMARY KEY (id);
ALTER TABLE expression_chr7 ADD CONSTRAINT pk_expression_chr7 PRIMARY KEY (id);
ALTER TABLE expression_chr8 ADD CONSTRAINT pk_expression_chr8 PRIMARY KEY (id);
ALTER TABLE expression_chr9 ADD CONSTRAINT pk_expression_chr9 PRIMARY KEY (id);
ALTER TABLE expression_chr10 ADD CONSTRAINT pk_expression_chr10 PRIMARY KEY (id);
ALTER TABLE expression_chr11 ADD CONSTRAINT pk_expression_chr11 PRIMARY KEY (id);
ALTER TABLE expression_chr12 ADD CONSTRAINT pk_expression_chr12 PRIMARY KEY (id);
ALTER TABLE expression_chr13 ADD CONSTRAINT pk_expression_chr13 PRIMARY KEY (id);
ALTER TABLE expression_chr14 ADD CONSTRAINT pk_expression_chr14 PRIMARY KEY (id);
ALTER TABLE expression_chr15 ADD CONSTRAINT pk_expression_chr15 PRIMARY KEY (id);
ALTER TABLE expression_chr16 ADD CONSTRAINT pk_expression_chr16 PRIMARY KEY (id);
ALTER TABLE expression_chr17 ADD CONSTRAINT pk_expression_chr17 PRIMARY KEY (id);
ALTER TABLE expression_chr18 ADD CONSTRAINT pk_expression_chr18 PRIMARY KEY (id);
ALTER TABLE expression_chr19 ADD CONSTRAINT pk_expression_chr19 PRIMARY KEY (id);
ALTER TABLE expression_chr20 ADD CONSTRAINT pk_expression_chr20 PRIMARY KEY (id);
ALTER TABLE expression_chr21 ADD CONSTRAINT pk_expression_chr21 PRIMARY KEY (id);
ALTER TABLE expression_chr22 ADD CONSTRAINT pk_expression_chr22 PRIMARY KEY (id);

-- foreign keys
ALTER TABLE expression_chr1 ADD CONSTRAINT fk_expression_patient_chr1 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr2 ADD CONSTRAINT fk_expression_patient_chr2 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr3 ADD CONSTRAINT fk_expression_patient_chr3 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr4 ADD CONSTRAINT fk_expression_patient_chr4 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr5 ADD CONSTRAINT fk_expression_patient_chr5 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr6 ADD CONSTRAINT fk_expression_patient_chr6 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr7 ADD CONSTRAINT fk_expression_patient_chr7 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr8 ADD CONSTRAINT fk_expression_patient_chr8 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr9 ADD CONSTRAINT fk_expression_patient_chr9 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr10 ADD CONSTRAINT fk_expression_patient_chr10 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr11 ADD CONSTRAINT fk_expression_patient_chr11 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr12 ADD CONSTRAINT fk_expression_patient_chr12 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr13 ADD CONSTRAINT fk_expression_patient_chr13 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr14 ADD CONSTRAINT fk_expression_patient_chr14 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr15 ADD CONSTRAINT fk_expression_patient_chr15 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr16 ADD CONSTRAINT fk_expression_patient_chr16 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr17 ADD CONSTRAINT fk_expression_patient_chr17 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr18 ADD CONSTRAINT fk_expression_patient_chr18 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr19 ADD CONSTRAINT fk_expression_patient_chr19 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr20 ADD CONSTRAINT fk_expression_patient_chr20 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr21 ADD CONSTRAINT fk_expression_patient_chr21 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr22 ADD CONSTRAINT fk_expression_patient_chr22 FOREIGN KEY (patient_id) REFERENCES patient(id);

ALTER TABLE expression_chr1 ADD CONSTRAINT fk_expression_gene_chr1 FOREIGN KEY (gene_id) REFERENCES gene_chr1(id);
ALTER TABLE expression_chr2 ADD CONSTRAINT fk_expression_gene_chr2 FOREIGN KEY (gene_id) REFERENCES gene_chr2(id);
ALTER TABLE expression_chr3 ADD CONSTRAINT fk_expression_gene_chr3 FOREIGN KEY (gene_id) REFERENCES gene_chr3(id);
ALTER TABLE expression_chr4 ADD CONSTRAINT fk_expression_gene_chr4 FOREIGN KEY (gene_id) REFERENCES gene_chr4(id);
ALTER TABLE expression_chr5 ADD CONSTRAINT fk_expression_gene_chr5 FOREIGN KEY (gene_id) REFERENCES gene_chr5(id);
ALTER TABLE expression_chr6 ADD CONSTRAINT fk_expression_gene_chr6 FOREIGN KEY (gene_id) REFERENCES gene_chr6(id);
ALTER TABLE expression_chr7 ADD CONSTRAINT fk_expression_gene_chr7 FOREIGN KEY (gene_id) REFERENCES gene_chr7(id);
ALTER TABLE expression_chr8 ADD CONSTRAINT fk_expression_gene_chr8 FOREIGN KEY (gene_id) REFERENCES gene_chr8(id);
ALTER TABLE expression_chr9 ADD CONSTRAINT fk_expression_gene_chr9 FOREIGN KEY (gene_id) REFERENCES gene_chr9(id);
ALTER TABLE expression_chr10 ADD CONSTRAINT fk_expression_gene_chr10 FOREIGN KEY (gene_id) REFERENCES gene_chr10(id);
ALTER TABLE expression_chr11 ADD CONSTRAINT fk_expression_gene_chr11 FOREIGN KEY (gene_id) REFERENCES gene_chr11(id);
ALTER TABLE expression_chr12 ADD CONSTRAINT fk_expression_gene_chr12 FOREIGN KEY (gene_id) REFERENCES gene_chr12(id);
ALTER TABLE expression_chr13 ADD CONSTRAINT fk_expression_gene_chr13 FOREIGN KEY (gene_id) REFERENCES gene_chr13(id);
ALTER TABLE expression_chr14 ADD CONSTRAINT fk_expression_gene_chr14 FOREIGN KEY (gene_id) REFERENCES gene_chr14(id);
ALTER TABLE expression_chr15 ADD CONSTRAINT fk_expression_gene_chr15 FOREIGN KEY (gene_id) REFERENCES gene_chr15(id);
ALTER TABLE expression_chr16 ADD CONSTRAINT fk_expression_gene_chr16 FOREIGN KEY (gene_id) REFERENCES gene_chr16(id);
ALTER TABLE expression_chr17 ADD CONSTRAINT fk_expression_gene_chr17 FOREIGN KEY (gene_id) REFERENCES gene_chr17(id);
ALTER TABLE expression_chr18 ADD CONSTRAINT fk_expression_gene_chr18 FOREIGN KEY (gene_id) REFERENCES gene_chr18(id);
ALTER TABLE expression_chr19 ADD CONSTRAINT fk_expression_gene_chr19 FOREIGN KEY (gene_id) REFERENCES gene_chr19(id);
ALTER TABLE expression_chr20 ADD CONSTRAINT fk_expression_gene_chr20 FOREIGN KEY (gene_id) REFERENCES gene_chr20(id);
ALTER TABLE expression_chr21 ADD CONSTRAINT fk_expression_gene_chr21 FOREIGN KEY (gene_id) REFERENCES gene_chr21(id);
ALTER TABLE expression_chr22 ADD CONSTRAINT fk_expression_gene_chr22 FOREIGN KEY (gene_id) REFERENCES gene_chr22(id);

-- analyze
ANALYZE expression_chr1;
ANALYZE expression_chr2;
ANALYZE expression_chr3;
ANALYZE expression_chr4;
ANALYZE expression_chr5;
ANALYZE expression_chr6;
ANALYZE expression_chr7;
ANALYZE expression_chr8;
ANALYZE expression_chr9;
ANALYZE expression_chr10;
ANALYZE expression_chr11;
ANALYZE expression_chr12;
ANALYZE expression_chr13;
ANALYZE expression_chr14;
ANALYZE expression_chr15;
ANALYZE expression_chr16;
ANALYZE expression_chr17;
ANALYZE expression_chr18;
ANALYZE expression_chr19;
ANALYZE expression_chr20;
ANALYZE expression_chr21;
ANALYZE expression_chr22;
