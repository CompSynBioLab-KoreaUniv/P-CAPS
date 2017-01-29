#!/usr/bin/env perl

use warnings;
use strict;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

my %options = ();
my $results = GetOptions (\%options, 
                          'input|i=s',
                          'log|l=s',
                          'help|h') || pod2usage();

if( $options{'help'} ){
    pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);

my $logfh;
if (defined $options{log}) {
    open($logfh, ">$options{log}") || die "can't create log file: $!";
}

my $ifh;
open($ifh, "<$options{input}") || die "can't open input file: $!";

print "##gff-version 3\n";

my $i=1;

foreach my $line (<$ifh>){
	my @cols = split /[\t]/, $line;
	chomp @cols;
	my $contig = $cols[0];

    if ($contig =~ /^(.+?)\s+$/) {
        $contig = $1;
    }

    next if $contig eq 'Sequence' || $contig eq 'Name' || $contig eq '--------';
    
	my $start = $cols[2];
	my $stop = $cols[3];
	my $target = $cols[4];
	my $score = $cols[8];
	if ($start < $stop){
		print "$contig\ttRNAScan-SE\ttRNA\t$start\t$stop\t$score\t+\t.\tID=$target\_$i\_tRNA\_$i\n";
		$i++;
	}else{
                print "$contig\ttRNAScan-SE\ttRNA\t$stop\t$start\t$score\t-\t.\tID=$target\_$i\_tRNA\_$i\n";
		$i++;
	}
}

exit(0);


sub _log {
    my $msg = shift;
    print $logfh "$msg\n" if $logfh;
}

sub check_parameters {
    my $options = shift;
    my @required = qw( input );
    for my $option ( @required ) {
        unless  ( defined $$options{$option} ) {
            die "--$option is a required option";
        }
    }
    $options{optional_argument2}   = 'foo'  unless ($options{optional_argument2});
}

