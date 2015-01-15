PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS CpG (
    IlmnID TEXT PRIMARY KEY,
    Name TEXT,
    AddressA_ID INTEGER,
    AlleleA_ProbeSeq TEXT,
    AddressB_ID INTEGER,
    AlleleB_ProbeSeq TEXT,
    Infinium_Design_Type TEXT,
    Next_Base TEXT,
    Color_Channel TEXT,
    Forward_Sequence TEXT,
    Genome_Build INTEGER,
    CHR TEXT,
    MAPINFO INTEGER,
    SourceSeq TEXT,
    Chromosome_36 TEXT,
    Coordinate_36 INTEGER,
    Strand TEXT,
    Probe_SNPs TEXT,
    Probe_SNPs_10 TEXT,
    Random_Loci TEXT,
    Methyl27_Loci TEXT,
    UCSC_RefGene_Name TEXT,
    UCSC_RefGene_Accession TEXT,
    UCSC_RefGene_Group TEXT,
    UCSC_CpG_Islands_Name TEXT,
    Relation_to_UCSC_CpG_Island TEXT,
    Phantom TEXT,
    DMR TEXT,
    Enhancer TEXT,
    HMM_Island TEXT,
    Regulatory_Feature_Name TEXT,
    Regulatory_Feature_Group TEXT,
    DHS TEXT
);

CREATE TABLE IF NOT EXISTS refGene (
    bin INTEGER, 
    name TEXT PRIMARY KEY,
    chrom TEXT,
    strand TEXT,
    txStart INTEGER,
    txEnd INTEGER,
    cdsStart INTEGER,
    cdsEnd INTEGER,
    exonCount INTEGER,
    exonStarts TEXT,
    exonEnds TEXT,
    score INTEGER,
    name2 TEXT,
    cdsStartStat TEXT,
    cdsEndStat TEXT,
    exonFrames TEXT
);

CREATE TABLE IF NOT EXISTS CpGGene (
    IlmnID TEXT REFERENCES CpG(IlmnID),
    UCSC_RefGene_Name TEXT,
    UCSC_RefGene_Accession TEXT REFERENCES refGene(name),
    UCSC_RefGene_Group TEXT,
    PRIMARY KEY (IlmnID, UCSC_RefGene_Accession)
);
