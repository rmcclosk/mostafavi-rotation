DROP TABLE IF EXISTS module;

-- main table
CREATE TABLE module (
    id SERIAL PRIMARY KEY,
    gene_name VARCHAR(32) NOT NULL,
    module SMALLINT NOT NULL
);

-- load data
COPY module (gene_name, module) FROM '../db/module.tsv';
