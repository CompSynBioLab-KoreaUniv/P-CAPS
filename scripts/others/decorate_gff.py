import getopt, sys, glob, os, re, datetime
from optparse import OptionParser
from collections import defaultdict

def usage():
    print ''

def main(argv):
    optparser_usage = 'decorate_gff.py -r <root_dir> -g <gene_gff3> -t <tRNA_gff3> -u <rRNA_gff3>'
    parser = OptionParser(usage=optparser_usage)
    parser.add_option("-r", "--rootDir", action="store", type="string",
        dest="directory", help='Root directory. All files are generated here')
    parser.add_option("-g", "--genegff", action="store", type="string",
        dest="genegff", help='Gene prediction file in gff3 format')
    parser.add_option("-t", "--trnagff", action="store", type="string",
        dest="trnagff", help='tRNA prediction file in gff3 format')
    parser.add_option("-u", "--rrnagff", action="store", type="string",
        dest="rrnagff", help='rRNA prediction file in gff3 format')

    (options, args) = parser.parse_args()
    if options.directory:
        root_dir = os.path.abspath(options.directory)
    else:
        print 'ERROR: please provide proper root direcotory'
        usage()
        sys.exit()
    
    if options.genegff:
        genegff = os.path.abspath(options.genegff)
    else:
        print 'ERROR: please provide proper gff3 file'
        usage()
        sys.exit()

    if options.trnagff:
        trnagff = os.path.abspath(options.trnagff)
    else:
        print 'ERROR: please provide proper gff3 file'
        usage()
        sys.exit()

    if options.rrnagff:
        rrnagff = os.path.abspath(options.rrnagff)
    else:
        print 'ERROR: please provide proper gff3 file'
        usage()
        sys.exit()

#Run function

    decorate_gff(genegff, trnagff, rrnagff, root_dir)

def decorate_gff(genegff, trnagff, rrnagff, root_dir):
    global D_all_feature
    D_all_feature = defaultdict(dict)
    with open(genegff, 'r') as f:
        lines = f.readlines()
        for line in lines:
            words = line.split(None, 8)
            if len(words) == 9 and words[2] == 'CDS':
                g_scaffold = words[0]
                g_start_site = words[3]
                g_feature_type = 'gene'
                D_all_feature[g_scaffold][int(g_start_site)] = [g_feature_type, line]

    with open(trnagff, 'r') as g:
        lines = g.readlines()
        for line in lines:
            words = line.split(None, 8)
            if len(words) == 9 and words[2] == 'tRNA':
                t_scaffold = words[0]
                t_start_site = words[3]
                t_feature_type = 'trna'
                D_all_feature[t_scaffold][int(t_start_site)] = [t_feature_type, line]

    with open(rrnagff, 'r') as h:
        lines = h.readlines()
        for line in lines:
            words = line.split(None, 8)
            i = 1
            if len(words) == 9 and words[2] == 'rRNA':
                r_scaffold = words[0]
                feature = words[8]
                new_feature = 'ID=rRNA_' + str(i) + ';product' + words[8].split(';Parent')[1]
                i += 1
                new_line = '\t'.join(words[0:8]) + '\t' + new_feature
                r_feature_type = 'rrna'
                D_all_feature[r_scaffold][int(words[3])] = [r_feature_type, new_line]

    scaffold_names = D_all_feature.keys()
    scaffold_names.sort()
    
    result_gff_file = os.path.join(root_dir, 'fully_decorated.gff')
    with open(result_gff_file, 'w') as o:
        for scaffold in scaffold_names:
            query_start_list = D_all_feature[scaffold].keys()
            query_start_list.sort()
            for start in query_start_list:
                query_line = D_all_feature[scaffold][start][1]
                o.write(query_line)
        

if __name__ == "__main__":
    main(sys.argv[1:])
