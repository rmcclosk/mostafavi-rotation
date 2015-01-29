#!/usr/bin/env perl

use strict;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::DBSQL::GeneAdaptor;
use Bio::EnsEMBL::Utils::Slice;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org', 
    -user => 'anonymous'
);

my $gene_adaptor  = $registry->get_adaptor( 'Human', 'Core', 'Gene' );
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );

for (my $chr = 1; $chr <= 22; ++$chr) {
    my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr );
    my $genes = $gene_adaptor->fetch_all_by_Slice($slice);
    while ( my $gene = shift @{$genes} ) {
        my $id = $gene->stable_id();
        $id =~ s/ENSG//;
        my $start = $gene->start();
        my $end = $gene->end();
        my $strand = $gene->strand() == 1 ? "TRUE" : "FALSE";
        my $name = $gene->external_name();
        print "$id\t$name\t$chr\t$start\t$end\t$strand\n";
    }
}
