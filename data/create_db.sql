PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS chromosome (
    chrom INTEGER NOT NULL PRIMARY KEY,
    size INTEGER NOT NULL,
    CHECK (chrom >= 1 AND chrom <= 22)
);

CREATE TABLE IF NOT EXISTS gene (
    id TEXT NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    forward INTEGER NOT NULL,
    cds_start INTEGER,
    cds_end INTEGER,
    CHECK (forward IN (0, 1))
);

CREATE TABLE IF NOT EXISTS transcript (
    id TEXT NOT NULL PRIMARY KEY,
    gene_id TEXT NOT NULL REFERENCES gene(id)
);

CREATE TABLE IF NOT EXISTS exon (
    transcript_id TEXT NOT NULL REFERENCES transcript(id),
    start INTEGER NOT NULL,
    end INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS cpg (
    id TEXT NOT NULL PRIMARY KEY,
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    forward INTEGER NOT NULL,
    CHECK (forward IN (0, 1))
);

CREATE TABLE IF NOT EXISTS patient (
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
    msex INTEGER NOT NULL,
    apoe_genotype INTEGER,
    dlbany INTEGER,
    arteriol_scler INTEGER,
    ci_num2_gct INTEGER,
    ci_num2_mct INTEGER,
    pmAD INTEGER,
    pathoAD INTEGER,
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
    CHECK (msex IN (0, 1)),
    CHECK (pmAD IS NULL or pmAD IN (0, 1)),
    CHECK (pathoAD IS NULL OR pathoAD IN (0, 1))
);

CREATE TABLE IF NOT EXISTS methylation (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    cpg_id TEXT NOT NULL REFERENCES cpg(id),
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, cpg_id)
);

CREATE TABLE IF NOT EXISTS expression (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    gene_id TEXT NOT NULL REFERENCES gene(id),
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, gene_id)
);

CREATE TABLE IF NOT EXISTS acetylation (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    start INTEGER NOT NULL,
    end INTEGER NOT NULL,
    value REAL NOT NULL,
    PRIMARY KEY (patient_id, chrom, start, end)
);

CREATE TABLE IF NOT EXISTS genotype (
    patient_id INTEGER NOT NULL REFERENCES patient(id),
    chrom INTEGER NOT NULL REFERENCES chromosome(chrom),
    position INTEGER NOT NULL,
    genotype REAL NOT NULL,
    PRIMARY KEY (patient_id, chrom, position),
    CHECK (0 <= genotype AND genotype <= 2)
);
