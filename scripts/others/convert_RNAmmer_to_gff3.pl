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

## Open the input file
my $ifh;
open($ifh, "<$options{input}") || die "can't open input file: $!";
my $i=1;

## Parsing the file
print "##gff-version 3\n";
foreach my $line (<$ifh>){
	if($line =~ /^#/){next;}
	my @cols = split /[\t]/, $line;
	chomp @cols;
	my $contig = $cols[0];
	my $start = $cols[3];
	my $stop = $cols[4];
	my $target = $cols[8];
	my $score = $cols[5];
	if ($start < $stop){
		print "$contig\tRNAmmer\trRNA\t$start\t$stop\t$score\t+\t.\tID=$target\_$i\_rRNA;Parent=$target\_$i\n";
		$i++;
	}else{
		print "$contig\tRNAmmer\trRNA\t$start\t$stop\t$score\t-\t.\tID=$target\_$i\_rRNA;Parent=$target\_$i\n";
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
