DROP TABLE IF EXISTS acetylation CASCADE;

-- main table
CREATE TABLE acetylation (
    patient_id INTEGER NOT NULL,
    chrom SMALLINT NOT NULL,
    peak_start INTEGER NOT NULL,
    peak_end INTEGER NOT NULL,
    value REAL NOT NULL
);

-- child tables
CREATE TABLE acetylation_chr1 ( CHECK(chrom = 1) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr2 ( CHECK(chrom = 2) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr3 ( CHECK(chrom = 3) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr4 ( CHECK(chrom = 4) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr5 ( CHECK(chrom = 5) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr6 ( CHECK(chrom = 6) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr7 ( CHECK(chrom = 7) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr8 ( CHECK(chrom = 8) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr9 ( CHECK(chrom = 9) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr10 ( CHECK(chrom = 10) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr11 ( CHECK(chrom = 11) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr12 ( CHECK(chrom = 12) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr13 ( CHECK(chrom = 13) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr14 ( CHECK(chrom = 14) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr15 ( CHECK(chrom = 15) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr16 ( CHECK(chrom = 16) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr17 ( CHECK(chrom = 17) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr18 ( CHECK(chrom = 18) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr19 ( CHECK(chrom = 19) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr20 ( CHECK(chrom = 20) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr21 ( CHECK(chrom = 21) ) INHERITS (acetylation);
CREATE TABLE acetylation_chr22 ( CHECK(chrom = 22) ) INHERITS (acetylation);

-- trigger
CREATE OR REPLACE FUNCTION acetylation_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    CASE ( NEW.chrom )
    WHEN 1 THEN INSERT INTO acetylation_chr1 VALUES (NEW.*);
    WHEN 2 THEN INSERT INTO acetylation_chr2 VALUES (NEW.*);
    WHEN 3 THEN INSERT INTO acetylation_chr3 VALUES (NEW.*);
    WHEN 4 THEN INSERT INTO acetylation_chr4 VALUES (NEW.*);
    WHEN 5 THEN INSERT INTO acetylation_chr5 VALUES (NEW.*);
    WHEN 6 THEN INSERT INTO acetylation_chr6 VALUES (NEW.*);
    WHEN 7 THEN INSERT INTO acetylation_chr7 VALUES (NEW.*);
    WHEN 8 THEN INSERT INTO acetylation_chr8 VALUES (NEW.*);
    WHEN 9 THEN INSERT INTO acetylation_chr9 VALUES (NEW.*);
    WHEN 10 THEN INSERT INTO acetylation_chr10 VALUES (NEW.*);
    WHEN 11 THEN INSERT INTO acetylation_chr11 VALUES (NEW.*);
    WHEN 12 THEN INSERT INTO acetylation_chr12 VALUES (NEW.*);
    WHEN 13 THEN INSERT INTO acetylation_chr13 VALUES (NEW.*);
    WHEN 14 THEN INSERT INTO acetylation_chr14 VALUES (NEW.*);
    WHEN 15 THEN INSERT INTO acetylation_chr15 VALUES (NEW.*);
    WHEN 16 THEN INSERT INTO acetylation_chr16 VALUES (NEW.*);
    WHEN 17 THEN INSERT INTO acetylation_chr17 VALUES (NEW.*);
    WHEN 18 THEN INSERT INTO acetylation_chr18 VALUES (NEW.*);
    WHEN 19 THEN INSERT INTO acetylation_chr19 VALUES (NEW.*);
    WHEN 20 THEN INSERT INTO acetylation_chr20 VALUES (NEW.*);
    WHEN 21 THEN INSERT INTO acetylation_chr21 VALUES (NEW.*);
    WHEN 22 THEN INSERT INTO acetylation_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Wrong chromosome';
    END CASE;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_acetylation_trigger
    BEFORE INSERT ON acetylation
    FOR EACH ROW EXECUTE PROCEDURE acetylation_insert_trigger();

-- load data
COPY acetylation FROM '../db/acetylation.tsv';

-- foreign keys
ALTER TABLE acetylation_chr1 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr2 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr3 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr4 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr5 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr6 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr7 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr8 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr9 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr10 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr11 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr12 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr13 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr14 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr15 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr16 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr17 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr18 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr19 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr20 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr21 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE acetylation_chr22 ADD CONSTRAINT fk_acetylation_patient FOREIGN KEY (patient_id) REFERENCES patient(id);

-- index on patient_id for joining

CREATE INDEX idx_acetylation_patient_chr1 ON acetylation_chr1 (patient_id);
CREATE INDEX idx_acetylation_patient_chr2 ON acetylation_chr2 (patient_id);
CREATE INDEX idx_acetylation_patient_chr3 ON acetylation_chr3 (patient_id);
CREATE INDEX idx_acetylation_patient_chr4 ON acetylation_chr4 (patient_id);
CREATE INDEX idx_acetylation_patient_chr5 ON acetylation_chr5 (patient_id);
CREATE INDEX idx_acetylation_patient_chr6 ON acetylation_chr6 (patient_id);
CREATE INDEX idx_acetylation_patient_chr7 ON acetylation_chr7 (patient_id);
CREATE INDEX idx_acetylation_patient_chr8 ON acetylation_chr8 (patient_id);
CREATE INDEX idx_acetylation_patient_chr9 ON acetylation_chr9 (patient_id);
CREATE INDEX idx_acetylation_patient_chr10 ON acetylation_chr10 (patient_id);
CREATE INDEX idx_acetylation_patient_chr11 ON acetylation_chr11 (patient_id);
CREATE INDEX idx_acetylation_patient_chr12 ON acetylation_chr12 (patient_id);
CREATE INDEX idx_acetylation_patient_chr13 ON acetylation_chr13 (patient_id);
CREATE INDEX idx_acetylation_patient_chr14 ON acetylation_chr14 (patient_id);
CREATE INDEX idx_acetylation_patient_chr15 ON acetylation_chr15 (patient_id);
CREATE INDEX idx_acetylation_patient_chr16 ON acetylation_chr16 (patient_id);
CREATE INDEX idx_acetylation_patient_chr17 ON acetylation_chr17 (patient_id);
CREATE INDEX idx_acetylation_patient_chr18 ON acetylation_chr18 (patient_id);
CREATE INDEX idx_acetylation_patient_chr19 ON acetylation_chr19 (patient_id);
CREATE INDEX idx_acetylation_patient_chr20 ON acetylation_chr20 (patient_id);
CREATE INDEX idx_acetylation_patient_chr21 ON acetylation_chr21 (patient_id);
CREATE INDEX idx_acetylation_patient_chr22 ON acetylation_chr22 (patient_id);

-- analyse
ANALYZE acetylation_chr1;
ANALYZE acetylation_chr2;
ANALYZE acetylation_chr3;
ANALYZE acetylation_chr4;
ANALYZE acetylation_chr5;
ANALYZE acetylation_chr6;
ANALYZE acetylation_chr7;
ANALYZE acetylation_chr8;
ANALYZE acetylation_chr9;
ANALYZE acetylation_chr10;
ANALYZE acetylation_chr11;
ANALYZE acetylation_chr12;
ANALYZE acetylation_chr13;
ANALYZE acetylation_chr14;
ANALYZE acetylation_chr15;
ANALYZE acetylation_chr16;
ANALYZE acetylation_chr17;
ANALYZE acetylation_chr18;
ANALYZE acetylation_chr19;
ANALYZE acetylation_chr20;
ANALYZE acetylation_chr21;
ANALYZE acetylation_chr22;
