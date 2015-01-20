CREATE TABLE chromosome (
    chrom SMALLINT NOT NULL PRIMARY KEY,
    size INTEGER NOT NULL,
    CHECK (chrom >= 1 AND chrom <= 22)
);

CREATE TABLE gene (
    id VARCHAR(16) NOT NULL PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    chrom SMALLINT NOT NULL REFERENCES chromosome(chrom),
    forward BOOLEAN NOT NULL,
    cds_start INTEGER,
    cds_end INTEGER
);

CREATE TABLE transcript (
    id VARCHAR(16) NOT NULL PRIMARY KEY,
    gene_id VARCHAR(16) NOT NULL REFERENCES gene(id)
);

CREATE TABLE exon (
    transcript_id VARCHAR(16) NOT NULL REFERENCES transcript(id),
    exon_start INTEGER NOT NULL,
    exon_end INTEGER NOT NULL
);

CREATE TABLE cpg (
    id VARCHAR(16) NOT NULL PRIMARY KEY,
    chrom SMALLINT NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    forward BOOLEAN NOT NULL
);

CREATE TABLE patient (
    id INTEGER NOT NULL PRIMARY KEY,
    globcog_random_slope REAL,
    cog_ep_random_slope REAL,
    parksc_bv REAL,
    gaitsc_bv REAL,
    bradysc_bv REAL,
    rigidsc_bv REAL,
    tremsc_bv REAL,
    parksc_lv REAL,
    gaitsc_lv REAL,
    bradysc_lv REAL,
    rigidsc_lv REAL,
    tremsc_lv REAL,
    cog_ep_lv REAL,
    globcog_lv REAL,
    age_bl REAL,
    age_death REAL,
    educ INTEGER,
    msex BOOLEAN,
    apoe_genotype INTEGER,
    dlbany INTEGER,
    arteriol_scler INTEGER,
    ci_num2_gct INTEGER,
    ci_num2_mct INTEGER,
    pmAD BOOLEAN,
    pathoAD BOOLEAN,
    studyn INTEGER,
    np_sqrt REAL,
    nft_sqrt REAL,
    gpath_sqrt REAL,
    tangles_sqrt REAL,
    amyloid_sqrt REAL,
    apoe4n INTEGER,
    pkyrs_bl REAL,
    EV1 REAL,
    EV2 REAL,
    EV3 REAL,
    EV4 REAL,
    EV5 REAL,
    EV6 REAL,
    EV7 REAL,
    EV8 REAL,
    EV9 REAL,
    EV10 REAL,
    aa_av_3 REAL
);

CREATE TABLE methylation (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    cpg_id VARCHAR(16) NOT NULL REFERENCES cpg(id),
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, cpg_id)
);

CREATE TABLE expression (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    gene_id VARCHAR(16) NOT NULL REFERENCES gene(id),
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, gene_id)
);

CREATE TABLE acetylation (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    peak_start INTEGER NOT NULL,
    peak_end INTEGER NOT NULL,
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, chrom, peak_start, peak_end)
);

CREATE TABLE snp (
    rsid VARCHAR(16) NOT NULL PRIMARY KEY,
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    forward BOOLEAN NOT NULL,
    ref CHAR(1) NOT NULL,
    alt CHAR(1) NOT NULL,
    CHECK (ref IN ('A', 'C', 'G', 'T') AND alt IN ('A', 'C', 'G', 'T'))
);

CREATE TABLE genotype (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    rsid VARCHAR(16) NOT NULL REFERENCES snp(rsid),
    genotype REAL NOT NULL,
    PRIMARY KEY (patient_id, rsid),
    CHECK (0 <= genotype AND genotype <= 2)
);
