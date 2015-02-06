-- check constraints
ALTER TABLE genotype_chr1 ADD CONSTRAINT chk_genotype_chr1 CHECK (chrom = 1);
ALTER TABLE genotype_chr2 ADD CONSTRAINT chk_genotype_chr2 CHECK (chrom = 2);
ALTER TABLE genotype_chr3 ADD CONSTRAINT chk_genotype_chr3 CHECK (chrom = 3);
ALTER TABLE genotype_chr4 ADD CONSTRAINT chk_genotype_chr4 CHECK (chrom = 4);
ALTER TABLE genotype_chr5 ADD CONSTRAINT chk_genotype_chr5 CHECK (chrom = 5);
ALTER TABLE genotype_chr6 ADD CONSTRAINT chk_genotype_chr6 CHECK (chrom = 6);
ALTER TABLE genotype_chr7 ADD CONSTRAINT chk_genotype_chr7 CHECK (chrom = 7);
ALTER TABLE genotype_chr8 ADD CONSTRAINT chk_genotype_chr8 CHECK (chrom = 8);
ALTER TABLE genotype_chr9 ADD CONSTRAINT chk_genotype_chr9 CHECK (chrom = 9);
ALTER TABLE genotype_chr10 ADD CONSTRAINT chk_genotype_chr10 CHECK (chrom = 10);
ALTER TABLE genotype_chr11 ADD CONSTRAINT chk_genotype_chr11 CHECK (chrom = 11);
ALTER TABLE genotype_chr12 ADD CONSTRAINT chk_genotype_chr12 CHECK (chrom = 12);
ALTER TABLE genotype_chr13 ADD CONSTRAINT chk_genotype_chr13 CHECK (chrom = 13);
ALTER TABLE genotype_chr14 ADD CONSTRAINT chk_genotype_chr14 CHECK (chrom = 14);
ALTER TABLE genotype_chr15 ADD CONSTRAINT chk_genotype_chr15 CHECK (chrom = 15);
ALTER TABLE genotype_chr16 ADD CONSTRAINT chk_genotype_chr16 CHECK (chrom = 16);
ALTER TABLE genotype_chr17 ADD CONSTRAINT chk_genotype_chr17 CHECK (chrom = 17);
ALTER TABLE genotype_chr18 ADD CONSTRAINT chk_genotype_chr18 CHECK (chrom = 18);
ALTER TABLE genotype_chr19 ADD CONSTRAINT chk_genotype_chr19 CHECK (chrom = 19);
ALTER TABLE genotype_chr20 ADD CONSTRAINT chk_genotype_chr20 CHECK (chrom = 20);
ALTER TABLE genotype_chr21 ADD CONSTRAINT chk_genotype_chr21 CHECK (chrom = 21);
ALTER TABLE genotype_chr22 ADD CONSTRAINT chk_genotype_chr22 CHECK (chrom = 22);

-- foreign key constraints
ALTER TABLE genotype_chr1 ADD CONSTRAINT fk_genotype_patient_chr1 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr2 ADD CONSTRAINT fk_genotype_patient_chr2 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr3 ADD CONSTRAINT fk_genotype_patient_chr3 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr4 ADD CONSTRAINT fk_genotype_patient_chr4 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr5 ADD CONSTRAINT fk_genotype_patient_chr5 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr6 ADD CONSTRAINT fk_genotype_patient_chr6 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr7 ADD CONSTRAINT fk_genotype_patient_chr7 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr8 ADD CONSTRAINT fk_genotype_patient_chr8 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr9 ADD CONSTRAINT fk_genotype_patient_chr9 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr10 ADD CONSTRAINT fk_genotype_patient_chr10 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr11 ADD CONSTRAINT fk_genotype_patient_chr11 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr12 ADD CONSTRAINT fk_genotype_patient_chr12 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr13 ADD CONSTRAINT fk_genotype_patient_chr13 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr14 ADD CONSTRAINT fk_genotype_patient_chr14 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr15 ADD CONSTRAINT fk_genotype_patient_chr15 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr16 ADD CONSTRAINT fk_genotype_patient_chr16 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr17 ADD CONSTRAINT fk_genotype_patient_chr17 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr18 ADD CONSTRAINT fk_genotype_patient_chr18 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr19 ADD CONSTRAINT fk_genotype_patient_chr19 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr20 ADD CONSTRAINT fk_genotype_patient_chr20 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr21 ADD CONSTRAINT fk_genotype_patient_chr21 FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE genotype_chr22 ADD CONSTRAINT fk_genotype_patient_chr22 FOREIGN KEY (patient_id) REFERENCES patient(id);

-- indices
-- index by patient id to join expression
CREATE INDEX idx_genotype_patient_chr1 ON genotype_chr1 (patient_id);
CREATE INDEX idx_genotype_patient_chr2 ON genotype_chr2 (patient_id);
CREATE INDEX idx_genotype_patient_chr3 ON genotype_chr3 (patient_id);
CREATE INDEX idx_genotype_patient_chr4 ON genotype_chr4 (patient_id);
CREATE INDEX idx_genotype_patient_chr5 ON genotype_chr5 (patient_id);
CREATE INDEX idx_genotype_patient_chr6 ON genotype_chr6 (patient_id);
CREATE INDEX idx_genotype_patient_chr7 ON genotype_chr7 (patient_id);
CREATE INDEX idx_genotype_patient_chr8 ON genotype_chr8 (patient_id);
CREATE INDEX idx_genotype_patient_chr9 ON genotype_chr9 (patient_id);
CREATE INDEX idx_genotype_patient_chr10 ON genotype_chr10 (patient_id);
CREATE INDEX idx_genotype_patient_chr11 ON genotype_chr11 (patient_id);
CREATE INDEX idx_genotype_patient_chr12 ON genotype_chr12 (patient_id);
CREATE INDEX idx_genotype_patient_chr13 ON genotype_chr13 (patient_id);
CREATE INDEX idx_genotype_patient_chr14 ON genotype_chr14 (patient_id);
CREATE INDEX idx_genotype_patient_chr15 ON genotype_chr15 (patient_id);
CREATE INDEX idx_genotype_patient_chr16 ON genotype_chr16 (patient_id);
CREATE INDEX idx_genotype_patient_chr17 ON genotype_chr17 (patient_id);
CREATE INDEX idx_genotype_patient_chr18 ON genotype_chr18 (patient_id);
CREATE INDEX idx_genotype_patient_chr19 ON genotype_chr19 (patient_id);
CREATE INDEX idx_genotype_patient_chr20 ON genotype_chr20 (patient_id);
CREATE INDEX idx_genotype_patient_chr21 ON genotype_chr21 (patient_id);
CREATE INDEX idx_genotype_patient_chr22 ON genotype_chr22 (patient_id);

-- index by position to find QTLs
CREATE INDEX idx_genotype_position_chr1 ON genotype_chr1 (position);
CREATE INDEX idx_genotype_position_chr2 ON genotype_chr2 (position);
CREATE INDEX idx_genotype_position_chr3 ON genotype_chr3 (position);
CREATE INDEX idx_genotype_position_chr4 ON genotype_chr4 (position);
CREATE INDEX idx_genotype_position_chr5 ON genotype_chr5 (position);
CREATE INDEX idx_genotype_position_chr6 ON genotype_chr6 (position);
CREATE INDEX idx_genotype_position_chr7 ON genotype_chr7 (position);
CREATE INDEX idx_genotype_position_chr8 ON genotype_chr8 (position);
CREATE INDEX idx_genotype_position_chr9 ON genotype_chr9 (position);
CREATE INDEX idx_genotype_position_chr10 ON genotype_chr10 (position);
CREATE INDEX idx_genotype_position_chr11 ON genotype_chr11 (position);
CREATE INDEX idx_genotype_position_chr12 ON genotype_chr12 (position);
CREATE INDEX idx_genotype_position_chr13 ON genotype_chr13 (position);
CREATE INDEX idx_genotype_position_chr14 ON genotype_chr14 (position);
CREATE INDEX idx_genotype_position_chr15 ON genotype_chr15 (position);
CREATE INDEX idx_genotype_position_chr16 ON genotype_chr16 (position);
CREATE INDEX idx_genotype_position_chr17 ON genotype_chr17 (position);
CREATE INDEX idx_genotype_position_chr18 ON genotype_chr18 (position);
CREATE INDEX idx_genotype_position_chr19 ON genotype_chr19 (position);
CREATE INDEX idx_genotype_position_chr20 ON genotype_chr20 (position);
CREATE INDEX idx_genotype_position_chr21 ON genotype_chr21 (position;
CREATE INDEX idx_genotype_position_chr22 ON genotype_chr22 (position);

-- drop MAF < 0.1
CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr1 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr1 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr1 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr2 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr2 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr2 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr3 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr3 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr3 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr4 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr4 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr4 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr5 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr5 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr5 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr6 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr6 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr6 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr7 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr7 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr7 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr8 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr8 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr8 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr9 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr9 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr9 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr10 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr10 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr10 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr11 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr11 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr11 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr12 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr12 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr12 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr13 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr13 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr13 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr14 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr14 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr14 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr15 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr15 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr15 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr16 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr16 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr16 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr17 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr17 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr17 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr18 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr18 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr18 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr19 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr19 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr19 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr20 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr20 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr20 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr21 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr21 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr21 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

CREATE TEMPORARY TABLE modes AS SELECT position, mode() WITHIN GROUP (ORDER BY value) FROM genotype_chr22 GROUP BY position;
CREATE TEMPORARY TABLE maf AS SELECT m.position, avg((value != mode)::int) FROM modes m JOIN genotype_chr22 g ON m.position = g.position GROUP BY m.position;
DELETE FROM genotype_chr22 WHERE position IN (select position from maf where avg < 0.1);
DROP TABLE maf; DROP TABLE modes;

-- cluster by position
CLUSTER genotype_chr1 USING idx_genotype_position_chr1;
CLUSTER genotype_chr2 USING idx_genotype_position_chr2;
CLUSTER genotype_chr3 USING idx_genotype_position_chr3;
CLUSTER genotype_chr4 USING idx_genotype_position_chr4;
CLUSTER genotype_chr5 USING idx_genotype_position_chr5;
CLUSTER genotype_chr6 USING idx_genotype_position_chr6;
CLUSTER genotype_chr7 USING idx_genotype_position_chr7;
CLUSTER genotype_chr8 USING idx_genotype_position_chr8;
CLUSTER genotype_chr9 USING idx_genotype_position_chr9;
CLUSTER genotype_chr10 USING idx_genotype_position_chr10;
CLUSTER genotype_chr11 USING idx_genotype_position_chr11;
CLUSTER genotype_chr12 USING idx_genotype_position_chr12;
CLUSTER genotype_chr13 USING idx_genotype_position_chr13;
CLUSTER genotype_chr14 USING idx_genotype_position_chr14;
CLUSTER genotype_chr15 USING idx_genotype_position_chr15;
CLUSTER genotype_chr16 USING idx_genotype_position_chr16;
CLUSTER genotype_chr17 USING idx_genotype_position_chr17;
CLUSTER genotype_chr18 USING idx_genotype_position_chr18;
CLUSTER genotype_chr19 USING idx_genotype_position_chr19;
CLUSTER genotype_chr20 USING idx_genotype_position_chr20;
CLUSTER genotype_chr21 USING idx_genotype_position_chr21;
CLUSTER genotype_chr22 USING idx_genotype_position_chr22;

-- analyze
ANALYZE genotype_chr1;
ANALYZE genotype_chr2;
ANALYZE genotype_chr3;
ANALYZE genotype_chr4;
ANALYZE genotype_chr5;
ANALYZE genotype_chr6;
ANALYZE genotype_chr7;
ANALYZE genotype_chr8;
ANALYZE genotype_chr9;
ANALYZE genotype_chr10;
ANALYZE genotype_chr11;
ANALYZE genotype_chr12;
ANALYZE genotype_chr13;
ANALYZE genotype_chr14;
ANALYZE genotype_chr15;
ANALYZE genotype_chr16;
ANALYZE genotype_chr17;
ANALYZE genotype_chr18;
ANALYZE genotype_chr19;
ANALYZE genotype_chr20;
ANALYZE genotype_chr21;
ANALYZE genotype_chr22;
