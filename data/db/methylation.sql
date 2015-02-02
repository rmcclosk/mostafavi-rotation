DROP TABLE IF EXISTS methylation;

-- main table
CREATE TABLE methylation (
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    position INTEGER NOT NULL,
    value REAL NOT NULL
);

-- child tables
CREATE TABLE methylation_chr1 ( CHECK(chrom = 1) ) INHERITS (methylation);
CREATE TABLE methylation_chr2 ( CHECK(chrom = 2) ) INHERITS (methylation);
CREATE TABLE methylation_chr3 ( CHECK(chrom = 3) ) INHERITS (methylation);
CREATE TABLE methylation_chr4 ( CHECK(chrom = 4) ) INHERITS (methylation);
CREATE TABLE methylation_chr5 ( CHECK(chrom = 5) ) INHERITS (methylation);
CREATE TABLE methylation_chr6 ( CHECK(chrom = 6) ) INHERITS (methylation);
CREATE TABLE methylation_chr7 ( CHECK(chrom = 7) ) INHERITS (methylation);
CREATE TABLE methylation_chr8 ( CHECK(chrom = 8) ) INHERITS (methylation);
CREATE TABLE methylation_chr9 ( CHECK(chrom = 9) ) INHERITS (methylation);
CREATE TABLE methylation_chr10 ( CHECK(chrom = 10) ) INHERITS (methylation);
CREATE TABLE methylation_chr11 ( CHECK(chrom = 11) ) INHERITS (methylation);
CREATE TABLE methylation_chr12 ( CHECK(chrom = 12) ) INHERITS (methylation);
CREATE TABLE methylation_chr13 ( CHECK(chrom = 13) ) INHERITS (methylation);
CREATE TABLE methylation_chr14 ( CHECK(chrom = 14) ) INHERITS (methylation);
CREATE TABLE methylation_chr15 ( CHECK(chrom = 15) ) INHERITS (methylation);
CREATE TABLE methylation_chr16 ( CHECK(chrom = 16) ) INHERITS (methylation);
CREATE TABLE methylation_chr17 ( CHECK(chrom = 17) ) INHERITS (methylation);
CREATE TABLE methylation_chr18 ( CHECK(chrom = 18) ) INHERITS (methylation);
CREATE TABLE methylation_chr19 ( CHECK(chrom = 19) ) INHERITS (methylation);
CREATE TABLE methylation_chr20 ( CHECK(chrom = 20) ) INHERITS (methylation);
CREATE TABLE methylation_chr21 ( CHECK(chrom = 21) ) INHERITS (methylation);
CREATE TABLE methylation_chr22 ( CHECK(chrom = 22) ) INHERITS (methylation);

-- trigger
CREATE OR REPLACE FUNCTION methylation_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom )
    WHEN 1 THEN INSERT INTO methylation_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO methylation_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO methylation_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO methylation_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO methylation_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO methylation_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO methylation_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO methylation_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO methylation_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO methylation_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO methylation_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO methylation_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO methylation_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO methylation_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO methylation_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO methylation_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO methylation_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO methylation_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO methylation_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO methylation_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO methylation_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO methylation_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Wrong chromosome';
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_methylation_trigger
    BEFORE INSERT ON methylation
    FOR EACH ROW EXECUTE PROCEDURE methylation_insert_trigger();

-- import data
COPY methylation FROM '../db/methylation.tsv';

-- foreign keys
ALTER TABLE methylation_chr1 ADD CONSTRAINT fk_methylation_patient_chr1 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr2 ADD CONSTRAINT fk_methylation_patient_chr2 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr3 ADD CONSTRAINT fk_methylation_patient_chr3 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr4 ADD CONSTRAINT fk_methylation_patient_chr4 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr5 ADD CONSTRAINT fk_methylation_patient_chr5 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr6 ADD CONSTRAINT fk_methylation_patient_chr6 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr7 ADD CONSTRAINT fk_methylation_patient_chr7 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr8 ADD CONSTRAINT fk_methylation_patient_chr8 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr9 ADD CONSTRAINT fk_methylation_patient_chr9 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr10 ADD CONSTRAINT fk_methylation_patient_chr10 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr11 ADD CONSTRAINT fk_methylation_patient_chr11 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr12 ADD CONSTRAINT fk_methylation_patient_chr12 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr13 ADD CONSTRAINT fk_methylation_patient_chr13 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr14 ADD CONSTRAINT fk_methylation_patient_chr14 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr15 ADD CONSTRAINT fk_methylation_patient_chr15 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr16 ADD CONSTRAINT fk_methylation_patient_chr16 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr17 ADD CONSTRAINT fk_methylation_patient_chr17 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr18 ADD CONSTRAINT fk_methylation_patient_chr18 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr19 ADD CONSTRAINT fk_methylation_patient_chr19 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr20 ADD CONSTRAINT fk_methylation_patient_chr20 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr21 ADD CONSTRAINT fk_methylation_patient_chr21 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE methylation_chr22 ADD CONSTRAINT fk_methylation_patient_chr22 FOREIGN KEY (patient_id) REFERENCES patient(id);

-- index on patient_id for joining to genotype
CREATE INDEX idx_methylation_patient_chr1 ON methylation_chr1 (patient_id);
CREATE INDEX idx_methylation_patient_chr2 ON methylation_chr2 (patient_id);
CREATE INDEX idx_methylation_patient_chr3 ON methylation_chr3 (patient_id);
CREATE INDEX idx_methylation_patient_chr4 ON methylation_chr4 (patient_id);
CREATE INDEX idx_methylation_patient_chr5 ON methylation_chr5 (patient_id);
CREATE INDEX idx_methylation_patient_chr6 ON methylation_chr6 (patient_id);
CREATE INDEX idx_methylation_patient_chr7 ON methylation_chr7 (patient_id);
CREATE INDEX idx_methylation_patient_chr8 ON methylation_chr8 (patient_id);
CREATE INDEX idx_methylation_patient_chr9 ON methylation_chr9 (patient_id);
CREATE INDEX idx_methylation_patient_chr10 ON methylation_chr10 (patient_id);
CREATE INDEX idx_methylation_patient_chr11 ON methylation_chr11 (patient_id);
CREATE INDEX idx_methylation_patient_chr12 ON methylation_chr12 (patient_id);
CREATE INDEX idx_methylation_patient_chr13 ON methylation_chr13 (patient_id);
CREATE INDEX idx_methylation_patient_chr14 ON methylation_chr14 (patient_id);
CREATE INDEX idx_methylation_patient_chr15 ON methylation_chr15 (patient_id);
CREATE INDEX idx_methylation_patient_chr16 ON methylation_chr16 (patient_id);
CREATE INDEX idx_methylation_patient_chr17 ON methylation_chr17 (patient_id);
CREATE INDEX idx_methylation_patient_chr18 ON methylation_chr18 (patient_id);
CREATE INDEX idx_methylation_patient_chr19 ON methylation_chr19 (patient_id);
CREATE INDEX idx_methylation_patient_chr20 ON methylation_chr20 (patient_id);
CREATE INDEX idx_methylation_patient_chr21 ON methylation_chr21 (patient_id);
CREATE INDEX idx_methylation_patient_chr22 ON methylation_chr22 (patient_id);

-- analyse
ANALYZE methylation_chr1;
ANALYZE methylation_chr2;
ANALYZE methylation_chr3;
ANALYZE methylation_chr4;
ANALYZE methylation_chr5;
ANALYZE methylation_chr6;
ANALYZE methylation_chr7;
ANALYZE methylation_chr8;
ANALYZE methylation_chr9;
ANALYZE methylation_chr10;
ANALYZE methylation_chr11;
ANALYZE methylation_chr12;
ANALYZE methylation_chr13;
ANALYZE methylation_chr14;
ANALYZE methylation_chr15;
ANALYZE methylation_chr16;
ANALYZE methylation_chr17;
ANALYZE methylation_chr18;
ANALYZE methylation_chr19;
ANALYZE methylation_chr20;
ANALYZE methylation_chr21;
ANALYZE methylation_chr22;
