DROP TABLE IF EXISTS expression CASCADE;

-- main table
CREATE TABLE expression (
    patient_id INTEGER NOT NULL,
    gene_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL,
    value REAL NOT NULL
);

-- partition tables
CREATE TABLE expression_chr1 ( CHECK(chrom = 1) ) INHERITS (expression);
CREATE TABLE expression_chr2 ( CHECK(chrom = 2) ) INHERITS (expression);
CREATE TABLE expression_chr3 ( CHECK(chrom = 3) ) INHERITS (expression);
CREATE TABLE expression_chr4 ( CHECK(chrom = 4) ) INHERITS (expression);
CREATE TABLE expression_chr5 ( CHECK(chrom = 5) ) INHERITS (expression);
CREATE TABLE expression_chr6 ( CHECK(chrom = 6) ) INHERITS (expression);
CREATE TABLE expression_chr7 ( CHECK(chrom = 7) ) INHERITS (expression);
CREATE TABLE expression_chr8 ( CHECK(chrom = 8) ) INHERITS (expression);
CREATE TABLE expression_chr9 ( CHECK(chrom = 9) ) INHERITS (expression);
CREATE TABLE expression_chr10 ( CHECK(chrom = 10) ) INHERITS (expression);
CREATE TABLE expression_chr11 ( CHECK(chrom = 11) ) INHERITS (expression);
CREATE TABLE expression_chr12 ( CHECK(chrom = 12) ) INHERITS (expression);
CREATE TABLE expression_chr13 ( CHECK(chrom = 13) ) INHERITS (expression);
CREATE TABLE expression_chr14 ( CHECK(chrom = 14) ) INHERITS (expression);
CREATE TABLE expression_chr15 ( CHECK(chrom = 15) ) INHERITS (expression);
CREATE TABLE expression_chr16 ( CHECK(chrom = 16) ) INHERITS (expression);
CREATE TABLE expression_chr17 ( CHECK(chrom = 17) ) INHERITS (expression);
CREATE TABLE expression_chr18 ( CHECK(chrom = 18) ) INHERITS (expression);
CREATE TABLE expression_chr19 ( CHECK(chrom = 19) ) INHERITS (expression);
CREATE TABLE expression_chr20 ( CHECK(chrom = 20) ) INHERITS (expression);
CREATE TABLE expression_chr21 ( CHECK(chrom = 21) ) INHERITS (expression);
CREATE TABLE expression_chr22 ( CHECK(chrom = 22) ) INHERITS (expression);

-- trigger
CREATE OR REPLACE FUNCTION expression_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom )
    WHEN 1 THEN INSERT INTO expression_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO expression_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO expression_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO expression_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO expression_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO expression_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO expression_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO expression_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO expression_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO expression_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO expression_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO expression_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO expression_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO expression_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO expression_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO expression_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO expression_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO expression_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO expression_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO expression_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO expression_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO expression_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Wrong chromosome';
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_expression_trigger
    BEFORE INSERT ON expression
    FOR EACH ROW EXECUTE PROCEDURE expression_insert_trigger();

-- load data
COPY expression FROM '../db/expression.tsv';

-- keys
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

ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr1 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr2 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr3 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr4 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr5 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr6 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr7 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr8 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr9 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr10 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr11 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr12 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr13 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr14 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr15 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr16 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr17 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr18 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr19 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr20 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr21 FOREIGN KEY (gene_id) REFERENCES gene(id);
ALTER TABLE expression ADD CONSTRAINT fk_expression_gene_chr22 FOREIGN KEY (gene_id) REFERENCES gene(id);

-- indices
-- index by patient id for joining to genotype
CREATE INDEX idx_expression_patient_chr1 ON expression_chr1 (patient_id);
CREATE INDEX idx_expression_patient_chr2 ON expression_chr2 (patient_id);
CREATE INDEX idx_expression_patient_chr3 ON expression_chr3 (patient_id);
CREATE INDEX idx_expression_patient_chr4 ON expression_chr4 (patient_id);
CREATE INDEX idx_expression_patient_chr5 ON expression_chr5 (patient_id);
CREATE INDEX idx_expression_patient_chr6 ON expression_chr6 (patient_id);
CREATE INDEX idx_expression_patient_chr7 ON expression_chr7 (patient_id);
CREATE INDEX idx_expression_patient_chr8 ON expression_chr8 (patient_id);
CREATE INDEX idx_expression_patient_chr9 ON expression_chr9 (patient_id);
CREATE INDEX idx_expression_patient_chr10 ON expression_chr10 (patient_id);
CREATE INDEX idx_expression_patient_chr11 ON expression_chr11 (patient_id);
CREATE INDEX idx_expression_patient_chr12 ON expression_chr12 (patient_id);
CREATE INDEX idx_expression_patient_chr13 ON expression_chr13 (patient_id);
CREATE INDEX idx_expression_patient_chr14 ON expression_chr14 (patient_id);
CREATE INDEX idx_expression_patient_chr15 ON expression_chr15 (patient_id);
CREATE INDEX idx_expression_patient_chr16 ON expression_chr16 (patient_id);
CREATE INDEX idx_expression_patient_chr17 ON expression_chr17 (patient_id);
CREATE INDEX idx_expression_patient_chr18 ON expression_chr18 (patient_id);
CREATE INDEX idx_expression_patient_chr19 ON expression_chr19 (patient_id);
CREATE INDEX idx_expression_patient_chr20 ON expression_chr20 (patient_id);
CREATE INDEX idx_expression_patient_chr21 ON expression_chr21 (patient_id);
CREATE INDEX idx_expression_patient_chr22 ON expression_chr22 (patient_id);

-- index by tss position for finding nearby loci
CREATE INDEX idx_expression_position_chr1 ON expression_chr1 (position);
CREATE INDEX idx_expression_position_chr2 ON expression_chr2 (position);
CREATE INDEX idx_expression_position_chr3 ON expression_chr3 (position);
CREATE INDEX idx_expression_position_chr4 ON expression_chr4 (position);
CREATE INDEX idx_expression_position_chr5 ON expression_chr5 (position);
CREATE INDEX idx_expression_position_chr6 ON expression_chr6 (position);
CREATE INDEX idx_expression_position_chr7 ON expression_chr7 (position);
CREATE INDEX idx_expression_position_chr8 ON expression_chr8 (position);
CREATE INDEX idx_expression_position_chr9 ON expression_chr9 (position);
CREATE INDEX idx_expression_position_chr10 ON expression_chr10 (position);
CREATE INDEX idx_expression_position_chr11 ON expression_chr11 (position);
CREATE INDEX idx_expression_position_chr12 ON expression_chr12 (position);
CREATE INDEX idx_expression_position_chr13 ON expression_chr13 (position);
CREATE INDEX idx_expression_position_chr14 ON expression_chr14 (position);
CREATE INDEX idx_expression_position_chr15 ON expression_chr15 (position);
CREATE INDEX idx_expression_position_chr16 ON expression_chr16 (position);
CREATE INDEX idx_expression_position_chr17 ON expression_chr17 (position);
CREATE INDEX idx_expression_position_chr18 ON expression_chr18 (position);
CREATE INDEX idx_expression_position_chr19 ON expression_chr19 (position);
CREATE INDEX idx_expression_position_chr20 ON expression_chr20 (position);
CREATE INDEX idx_expression_position_chr21 ON expression_chr21 (position);
CREATE INDEX idx_expression_position_chr22 ON expression_chr22 (position);

-- cluster by position
CLUSTER expression_chr1 USING idx_expression_position_chr1;
CLUSTER expression_chr2 USING idx_expression_position_chr2;
CLUSTER expression_chr3 USING idx_expression_position_chr3;
CLUSTER expression_chr4 USING idx_expression_position_chr4;
CLUSTER expression_chr5 USING idx_expression_position_chr5;
CLUSTER expression_chr6 USING idx_expression_position_chr6;
CLUSTER expression_chr7 USING idx_expression_position_chr7;
CLUSTER expression_chr8 USING idx_expression_position_chr8;
CLUSTER expression_chr9 USING idx_expression_position_chr9;
CLUSTER expression_chr10 USING idx_expression_position_chr10;
CLUSTER expression_chr11 USING idx_expression_position_chr11;
CLUSTER expression_chr12 USING idx_expression_position_chr12;
CLUSTER expression_chr13 USING idx_expression_position_chr13;
CLUSTER expression_chr14 USING idx_expression_position_chr14;
CLUSTER expression_chr15 USING idx_expression_position_chr15;
CLUSTER expression_chr16 USING idx_expression_position_chr16;
CLUSTER expression_chr17 USING idx_expression_position_chr17;
CLUSTER expression_chr18 USING idx_expression_position_chr18;
CLUSTER expression_chr19 USING idx_expression_position_chr19;
CLUSTER expression_chr20 USING idx_expression_position_chr20;
CLUSTER expression_chr21 USING idx_expression_position_chr21;
CLUSTER expression_chr22 USING idx_expression_position_chr22;

-- analyse
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
