#!/usr/bin/perl -w

package DAWGPAWS;

use strict;
use File::Copy;
use Getopt::Long;
use Bio::Tools::Genemark;
use Pod::Select;               
use Pod::Text;                 
use IO::Scalar;                
use IO::Pipe;                  
use File::Spec;                

my ($VERSION) = q$Rev$ =~ /(\d+)/;
my $gff_ver = uc($ENV{DP_GFF}) || "GFF2";

my @inline;                    
my $msg;                       
my $infile;                    
my $outfile;                   
my $prefix;                    
my $rm_path;                   
my $ap_path;                   

my $src_prog = "GeneMark.hmm";        
my $src_seq = "unknown_src";         
my $param;                     

my $show_help = 0;             
my $show_version = 0;          
my $show_man = 0;              
my $show_usage = 0;                         
my $quiet = 0;                 
my $apollo = 0;                
my $test = 0;
my $verbose = 0;
my $debug = 0;                  

my $i;                         
my $ok = GetOptions(
		    # REQUIRED ARGUMENTS
		    "i|infile=s"   => \$infile,
                    "o|outfile=s"  => \$outfile,
		    "n|name=s"	   => \$src_seq,
		    # ADDITIONAL OPTIONS
		    "gff-ver=s"    => \$gff_ver,
		    "program=s"    => \$src_prog, 
	            "parameter=s"  => \$param,
		    # BOOLEANS
		    "verbose"      => \$verbose,
		    "debug"        => \$debug,
		    "test"         => \$test,
		    "usage"        => \$show_usage,
		    "version"      => \$show_version,
		    "man"          => \$show_man,
		    "h|help"       => \$show_help,
		    "q|quiet"      => \$quiet,);

unless ($gff_ver =~ "GFF3" || 
	$gff_ver =~ "GFF2") {
    if ($gff_ver =~ "3") {
	$gff_ver = "GFF3";
    }
    elsif ($gff_ver =~ "2") {
	$gff_ver = "GFF2";
    }
    else {
	print "\a";
	die "The gff-version \'$gff_ver\' is not recognized\n".
	    "The options GFF2 or GFF3 are supported\n";
    }
}

if ( ($show_usage) ) {
    print_help ("usage", $0 );
}

if ( ($show_help) || (!$ok) ) {
    print_help ("help",  $0 );
}

if ($show_man) {
    system ("perldoc $0");
    exit($ok ? 0 : 2);
}

if ($show_version) {
    print "\ncnv_genemark2gff.pl:\n".
	"Version: $VERSION\n\n";
    exit;
}

genemark_to_gff ($src_seq, $src_prog, $infile, $outfile, $param);

exit;

sub genemark_to_gff {
    
    my ($gm_src_seq, $gm_src_prog, $gm_in_path, $gff_out_path, 
	$parameter) = @_;

    my $attribute;
    my $source = $gm_src_prog;

    if ($gff_out_path) {
	open (GFFOUT, ">$gff_out_path") ||
	    die "ERROR: Can not output gff output file:\n$gff_out_path\n"
    }
    else {
	open (GFFOUT, ">&STDOUT") ||
	    die "Can not print to STDOUT\n";
    }
    if ($gff_ver =~ "GFF3") {
	print GFFOUT "##gff-version 3\n";
    }

    my $gm_obj;
    if ($gm_in_path) {
	$gm_obj = Bio::Tools::Genemark->new(-file => $gm_in_path);
    }
    else {
	$gm_obj = Bio::Tools::Genemark->new(-fh => \*STDIN);
    }
    
    if ($parameter) {
	$gm_src_prog = $gm_src_prog.":".$parameter;
    }

    my $rna_count = 0;
    my $gene_num = 0;

    while(my $gene = $gm_obj->next_prediction()) {
       
	$gene_num++;     
	my $gene_id = sprintf($gene_num); 
	my $gene_name = $gm_src_prog."_gene_".$gene_id."\n";
	$gene_id = "gene_id ".$gene_id;

	$rna_count++;
	my $rna_id = sprintf("%04d", $rna_count);
	
	my @exon_ary = $gene->exons();

	my $num_exon = @exon_ary;

	if ($gff_ver =~ "GFF3") {

	    $attribute = "ID=".$source."_".$gene_id;

	    my $gene_start = $gene->start();
	    my $gene_end = $gene->end();
	    if ($gene_start > $gene_end) {
		$gene_end =  $gene->start();
		$gene_start = $gene->end();
	    }

	    my $gene_score;
	    if ($gene->score()) {
		$gene_score = $gene->score();
	    }
	    else {
		$gene_score = ".";
	    }

	    my $gene_strand = $gene->strand()."\t";
	    if ($gene_strand =~ "-1") {
		$gene_strand = "-";
	    }
	    else {
		$gene_strand = "+";
	    }

	    print GFFOUT  $gm_src_seq."\t".     #seqname
		$source."\t".                   #source
		"gene\t".                       #feature
		"$gene_start\t".                #start
		"$gene_end\t".                  #end
		"$gene_score\t".                #score
		"$gene_strand\t".               #strand
		".\t".                          #frame
		$attribute.                     #attribute
		"\n";

	}

	
	my $exon_num = 0;
	for my $ind_exon (@exon_ary) {
	    
	    $exon_num++;
	    my $exon_id = sprintf("%05d", $exon_num); 
	    $exon_id = "exon".$exon_id;

	    my $feature = "CDS";

	    my $start = $ind_exon->start;
	    my $end = $ind_exon->end;
	    my $strand = $ind_exon->strand;
	    if ($start > $end) {
		$end =  $ind_exon->start();
		$start = $ind_exon->end();
	    }

	    if ($strand =~ '-1') {
		$strand = "-"; 
	    }
	    elsif ($strand =~ '1') {
		$strand = "+";
	    }
	    else {
		$strand = ".";
	    }

	    my $score = $ind_exon->score() || ".";

	    if ($gff_ver =~ "GFF3") {
		$attribute = "ID=".$source."_".$gene_id."_".$exon_id.
		    "\;Parent=".$source."_".$gene_id;
	    }
	    else {
		$attribute = $gene_id;
	    }

	    
	    my $frame = ".";

	    
	    print GFFOUT $gm_src_seq."\t".   # seq name
		$gm_src_prog."\t".           # source
		$feature."\t".               # feature
		$start."\t".                 # start
		$end."\t".                   # end
		$score."\t".                 # score
		$strand."\t".                # strand
		$frame."\t".                 # frame
		$attribute.                  # attribute		
		"\n";      

	}

    } 

    $gm_obj->close();

    if ($gff_out_path) {
	close (GFFOUT);
    }

}


sub print_help {
    my ($help_msg, $podfile) =  @_;
        
    print "\n";
    
    my $scalar = '';
    tie *STDOUT, 'IO::Scalar', \$scalar;
    
    if ($help_msg =~ "usage") {
	podselect({-sections => ["SYNOPSIS|MORE"]}, $0);
    }
    else {
	podselect({-sections => ["SYNOPSIS|ARGUMENTS|OPTIONS|MORE"]}, $0);
    }

    untie *STDOUT;
    
    my $pipe = IO::Pipe->new()
	or die "failed to create pipe: $!";
    
    my ($pid,$fd);

    if ( $pid = fork() ) { 
	open(TMPSTDIN, "<&STDIN")
	    or die "failed to dup stdin to tmp: $!";
	$pipe->reader();
	$fd = $pipe->fileno;
	open(STDIN, "<&=$fd")
	    or die "failed to dup \$fd to STDIN: $!";
	my $pod_txt = Pod::Text->new (sentence => 0, width => 78);
	$pod_txt->parse_from_filehandle;
	open(STDIN, "<&TMPSTDIN")
	    or die "failed to restore dup'ed stdin: $!";
    }
    else {
	$pipe->writer();
	$pipe->print($scalar);
	$pipe->close();	
	exit 0;
    }
    
    $pipe->close();
    close TMPSTDIN;

    print "\n";

    exit 0;
   
}
