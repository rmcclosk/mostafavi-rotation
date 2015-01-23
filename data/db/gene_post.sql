ALTER TABLE gene DROP CONSTRAINT IF EXISTS fk_gene_chrom;
ALTER TABLE gene ADD CONSTRAINT fk_gene_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

ALTER TABLE transcript DROP CONSTRAINT IF EXISTS fk_transcript_gene;
ALTER TABLE gene ADD CONSTRAINT fk_gene_chrom
    FOREIGN KEY (chrom) REFERENCES chromosome(chrom);

ALTER TABLE exon DROP CONSTRAINT IF EXISTS fk_exon_transcript;
ALTER TABLE exon ADD CONSTRAINT fk_exon_transcript
    FOREIGN KEY (transcript_id) REFERENCES transcript(id);

ANALYZE gene;
ANALYZE transcript;
ANALYZE exon;
