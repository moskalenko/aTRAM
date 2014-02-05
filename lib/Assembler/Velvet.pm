#!/usr/bin/env perl
package Velvet;
use strict;
use Subfunctions;

# Assembler modules need to know:
	# where to find the short reads (pass this in as a file name)
	# what the assembly parameters are. (pass this in as a hash)
# Assembler modules should return a hash of the resulting contigs.

# Hash of assembler's required binaries
our $binaries = {velveth => "velveth", velvetg => "velvetg"};

sub get_binaries {
	return $binaries;
}

sub assembler {
	my $self = shift;
	my $short_read_file = shift;
	my $params = shift;

	my ($kmer, $tempdir, $ins_length, $exp_cov, $min_contig_len, $output_file) = 0;
	my $longreads = "";

	if ((ref $params) =~ /HASH/) {
        if (exists $params->{"kmer"}) {
			$kmer = $params->{"kmer"};
		}
		if (exists $params->{"tempdir"}) {
			$tempdir = $params->{"tempdir"};
		}
		if (exists $params->{"longreads"}) {
			$longreads = $params->{"longreads"};
		}
		if (exists $params->{"ins_length"}) {
			$ins_length = $params->{"ins_length"};
		}
		if (exists $params->{"exp_cov"}) {
			$exp_cov = $params->{"exp_cov"};
		}
		if (exists $params->{"min_contig_len"}) {
			$min_contig_len = $params->{"min_contig_len"};
		}
		if (exists $params->{"output"}) {
			$output_file = $params->{"output"};
		}
	}
	# using velvet
	if ($longreads ne "") {
		Subfunctions::system_call ("$binaries->{velveth} $tempdir $kmer -fasta -shortPaired $short_read_file -long $longreads");
	} else {
		Subfunctions::system_call ("$binaries->{velveth} $tempdir $kmer -fasta -shortPaired $short_read_file");
	}
	Subfunctions::system_call ("$binaries->{velvetg} $tempdir -ins_length $ins_length -exp_cov $exp_cov -min_contig_lgth $min_contig_len");

	my ($contigs, undef) = Subfunctions::parsefasta ("$tempdir/contigs.fa");

	open OUTFH, ">", $output_file;
	foreach my $contigname (keys %$contigs) {
		my $sequence = $contigs->{$contigname};
		#NODE_41_length_2668_cov_4.901050
		$contigname =~ s/^NODE_(\d+)_length_(\d+)_cov_(\d+\.\d).*$/$1_len_$2_cov_$3/;
		print OUTFH ">$contigname\n$sequence\n";
	}
	close OUTFH;
	return $contigs;
}

return 1;
