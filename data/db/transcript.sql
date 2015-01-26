DROP TABLE IF EXISTS transcript CASCADE;

-- main table
CREATE TABLE transcript (
    id INTEGER NOT NULL PRIMARY KEY,
    gene_id INTEGER NOT NULL,
    cds_start INTEGER,
    cds_end INTEGER,
    chrom INTEGER NOT NULL
);

-- partition tables
CREATE TABLE IF NOT EXISTS transcript_chr22 ( ) INHERITS (transcript);

-- trigger
CREATE OR REPLACE FUNCTION trg_transcript_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.chrom = 22 ) THEN INSERT INTO transcript_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Bad chromosome';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_transcript_insert
    BEFORE INSERT ON transcript
    FOR EACH ROW EXECUTE PROCEDURE trg_transcript_insert();

-- load data
COPY transcript FROM '../db/transcript.tsv';

-- primary keys
ALTER TABLE transcript_chr22 ADD CONSTRAINT pk_transcript PRIMARY KEY (id);

-- foreign keys
ALTER TABLE transcript_chr22 ADD CONSTRAINT fk_transcript_gene_chr22
    FOREIGN KEY (gene_id) REFERENCES gene_chr22(id);

-- indices
CREATE INDEX idx_transcript_gene_chr22 ON transcript_chr22 (gene_id);

-- drop chrom column
ALTER TABLE transcript DROP COLUMN chrom;

-- analyze
ANALYZE transcript_chr22;
