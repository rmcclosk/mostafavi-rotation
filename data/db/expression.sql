DROP TABLE IF EXISTS expression CASCADE;

-- main table
CREATE TABLE expression (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    gene_id INTEGER NOT NULL,
    value REAL NOT NULL
);

-- partition tables
CREATE TABLE expression_chr22 ( ) INHERITS (expression);

-- trigger (kinda annoying)
CREATE OR REPLACE FUNCTION trg_expression_insert()
RETURNS TRIGGER AS $$
BEGIN
    CASE (SELECT chrom FROM gene WHERE id = NEW.gene_id) 
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
ALTER TABLE expression_chr22 ADD CONSTRAINT pk_expression_chr22 PRIMARY KEY (id);

-- foreign keys
ALTER TABLE expression_chr22 ADD CONSTRAINT fk_expression_patient_chr22
    FOREIGN KEY (patient_id) REFERENCES patient(id);
ALTER TABLE expression_chr22 ADD CONSTRAINT fk_expression_gene_chr22
    FOREIGN KEY (gene_id) REFERENCES gene_chr22(id);

-- analyze
ANALYZE expression;
