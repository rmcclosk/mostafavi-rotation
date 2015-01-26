DROP TABLE IF EXISTS exon CASCADE;

-- main table
CREATE TABLE exon (
    id SERIAL PRIMARY KEY,
    transcript_id INTEGER NOT NULL,
    exon_start INTEGER NOT NULL,
    exon_end INTEGER NOT NULL,
    chrom SMALLINT NOT NULL
);

-- partition tables
CREATE TABLE exon_chr22 ( ) INHERITS (exon);

-- trigger
CREATE OR REPLACE FUNCTION trg_exon_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.chrom = 22 ) THEN INSERT INTO exon_chr22 VALUES (NEW.*);
    ELSE RAISE EXCEPTION 'Bad chromosome';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_exon_insert
    BEFORE INSERT ON exon
    FOR EACH ROW EXECUTE PROCEDURE trg_exon_insert();

-- load data
COPY exon (transcript_id, exon_start, exon_end, chrom) FROM '../db/exon.tsv';

-- drop chrom column
ALTER TABLE exon DROP COLUMN chrom;

-- primary keys
ALTER TABLE exon_chr22 ADD CONSTRAINT pk_exon_chr22 PRIMARY KEY (id);

-- foreign keys
ALTER TABLE exon_chr22 ADD CONSTRAINT fk_exon_transcript_chr22
    FOREIGN KEY (transcript_id) REFERENCES transcript_chr22(id);

-- analyze
ANALYZE exon_chr22;
