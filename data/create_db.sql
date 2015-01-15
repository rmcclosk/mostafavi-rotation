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

CREATE TABLE IF NOT EXISTS CpG_Gene (
    IlmnID TEXT REFERENCES CpG(IlmnID),
    UCSC_RefGene_Name TEXT,
    UCSC_RefGene_Accession TEXT,
    UCSC_RefGene_Group TEXT,
    PRIMARY KEY (IlmnID, UCSC_RefGene_Name)
);

CREATE TABLE IF NOT EXISTS refGene (
    bin smallint(5) unsigned NOT NULL,
    name varchar(255) NOT NULL,
    chrom varchar(255) NOT NULL,
    strand char(1) NOT NULL,
    txStart int(10) unsigned NOT NULL,
    txEnd int(10) unsigned NOT NULL,
    cdsStart int(10) unsigned NOT NULL,
    cdsEnd int(10) unsigned NOT NULL,
    exonCount int(10) unsigned NOT NULL,
    exonStarts longblob NOT NULL,
    exonEnds longblob NOT NULL,
    score int(11) DEFAULT NULL,
    name2 varchar(255) NOT NULL,
    cdsStartStat enum('none','unk','incmpl','cmpl') NOT NULL,
    cdsEndStat enum('none','unk','incmpl','cmpl') NOT NULL,
    exonFrames longblob NOT NULL,
);

.separator ","
.import wgEncodeHaibMethyl450CpgIslandDetails.txt cpg


