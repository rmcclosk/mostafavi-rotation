DROP TABLE IF EXISTS patient;
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
    msex INTEGER,
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
    aa_av_3 REAL,
    CHECK (msex IN (0, 1)),
    CHECK (pathoAD IN (0, 1) OR pathoAD IS NULL),
    CHECK (pmAD IN (0, 1) OR pmAD IS NULL)
);
