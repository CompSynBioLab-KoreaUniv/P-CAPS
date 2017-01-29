import getopt, sys, glob, os, re, datetime
from optparse import OptionParser
from collections import defaultdict

def usage():
    print ''

def main(argv):
    optparser_usage = 'annotate_gff.py -r <root_dir> -g <gff3> -f <protein faa> -u <uniref90 database protein faa>'
    parser = OptionParser(usage=optparser_usage)
    parser.add_option("-r", "--rootDir", action="store", type="string",
        dest="directory", help='Root directory. All files are generated here')
    parser.add_option("-g", "--gff", action="store", type="string",
        dest="gff", help='Gene prediction file in gff3 format')
    parser.add_option("-f", "--faa", action="store", type="string",
        dest="faa", help='Translation file in faa format')
    parser.add_option("-u", "--uni", action="store", type="string",
        dest="uni", help='Uniref90 database protein file in faa format')

    (options, args) = parser.parse_args()
    if options.directory:
        root_dir = os.path.abspath(options.directory)
    else:
        print 'ERROR: please provide proper root direcotory'
        usage()
        sys.exit()
    
    if options.gff:
        gff = os.path.abspath(options.gff)
    else:
        print 'ERROR: please provide proper gff3 file'
        usage()
        sys.exit()

    if options.faa:
        faa = os.path.abspath(options.faa)
    else:
        print 'ERROR: please provide proper faa file'
        usage()
        sys.exit()

    if options.uni:
        unpdb = os.path.abspath(options.uni)
    else:
        print 'ERROR: please provide proper db file'
        usage()
        sys.exit()

#Run function

    annotate_gff(gff, faa, root_dir, unpdb)

def annotate_gff(gff, faa, root_dir, unpdb):
    D_unpdb = defaultdict(str)
    with open(unpdb, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "n=" in line:
                gi = line.split(">",1)[1].split()[0]
                feature = ""
                featuretmp = line.split(None,1)[1]
                if "n=" in featuretmp:
                    feature = featuretmp.split(" n=",1)[0]
                if not "n=" in featuretmp:
                    print line
                D_unpdb[gi] = feature

    blast_file = os.path.join(root_dir, 'blastp', 'blastp_output.tbl')
    D_bltout = defaultdict(str)
    with open(blast_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            gene = line.split()[0]
            if D_bltout[gene] == "":
                D_bltout[gene] = line.split()[1]

#print len(D_bltout.keys())
            
    a_gff_file = re.sub('.gff$', '_uniref90_annotated.gff', gff)
    with open(a_gff_file, 'w') as o:
        o.write('##gff-version 3\n')
        with open(gff, 'r') as f:
            lines = f.readlines() 
            for line in lines:
                words = line.split()
                if len(words) > 8:
                    gene = words[8].split('ID=',1)[1]
                    if not D_bltout[gene] == "":
                        annot = D_unpdb[D_bltout[gene]]
                        line = line.split('\n')[0] + ';' + "product=" + annot + '\n'
                    o.write(line)
            


if __name__ == "__main__":
    main(sys.argv[1:])
