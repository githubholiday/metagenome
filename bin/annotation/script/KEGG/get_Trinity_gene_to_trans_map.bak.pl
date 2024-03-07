#!/usr/bin/env perl

use strict;
use warnings;


while (<>) {
    if (/>(\S+).*\s+(\S+):(\d+)-(\d+)\(([\+\-])\)/) {
#        my $acc = $1;
	my $gene = $2;
	my $trans=$1;
        print "$trans\t$gene\n";
    }
}

exit(0);

