ALTER TABLE snp DROP CONSTRAINT IF EXISTS fk_snp_chrom;
ALTER TABLE snp ADD CONSTRAINT fk_snp_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

ALTER TABLE snp DROP CONSTRAINT IF EXISTS check_snp_ref;
ALTER TABLE snp ADD CONSTRAINT check_snp_ref
    CHECK (ref IN ('A', 'C', 'G', 'T'));

ALTER TABLE snp DROP CONSTRAINT IF EXISTS check_snp_alt;
ALTER TABLE snp ADD CONSTRAINT check_snp_alt
    CHECK (alt IN ('A', 'C', 'G', 'T'));

ANALYZE snp;
DROP INDEX IF EXISTS idx_snp_chrom_position;
CREATE INDEX idx_snp_chrom_position ON snp (chrom, position);
