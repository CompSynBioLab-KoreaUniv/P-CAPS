#!/usr/bin/python

import sys, getopt, re

def usage():
    print 'Usage: genemark2gff3.py -i <genemark_output_file>'
    print '  -i, --input: GeneMark output file'

def main(argv):
    inputFile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:",["input=",])
    except getopt.GetoptError:
        usage()
        sys.exit()
    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt in ("-i", "--input"):
            inputFile = arg
    if inputFile == '':
        usage()
        sys.exit()
    parsed_genemark = parse_genemark(inputFile)

def parse_genemark(inputFile):
    with open(inputFile) as f_in:
        genemark= (line.rstrip() for line in f_in)
        genemark = list(line for line in genemark if line)
    
    # Output and write header
    output = open('GeneMarkS_output.gff', 'w')
    output.write('##gff-version 3\n')
    for line in genemark:
        if re.search(r'\tCDS\t', line):
            scaffold = line.split('\t')[0].split(' ')[0]
            source = line.split('\t')[1]
            start = line.split('\t')[3]
            end = line.split('\t')[4]
            score = line.split('\t')[5]
            strand = line.split('\t')[6]
            id = line.split('\t')[8]
            output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\tID=%s\n' % (scaffold, source, 'CDS', start, end, score, strand, '1', id))
    output.close()

if __name__ == "__main__":
    main(sys.argv[1:])
