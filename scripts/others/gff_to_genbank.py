import sys
import os

from Bio import SeqIO
from Bio.Alphabet import generic_dna
from BCBio import GFF

def main(gff_file, fasta_file):
    out_file = "%s.gbff" % os.path.splitext(gff_file)[0]
    fasta_input = SeqIO.to_dict(SeqIO.parse(fasta_file, "fasta", generic_dna))
    gff_iter = GFF.parse(gff_file, fasta_input)
    SeqIO.write(gff_iter, out_file, "genbank")

if __name__ == "__main__":
    main(*sys.argv[1:])
