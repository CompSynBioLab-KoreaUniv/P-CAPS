import getopt, sys, glob, os, re, subprocess, time
from collections import defaultdict
import cPickle

def usage():
    print ''

def main(argv):

    # Get argument
    in_file = ''
    in_faa = ''
    in_tag = ''

    try:
        opts, args = getopt.getopt(argv,"hg:f:t:", ['help'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt == '-g':
            in_gff = arg
        elif opt == '-f':
            in_faa = arg
        elif opt == '-t':
            in_tag = arg

    D_faa = defaultdict(str)

    with open(in_faa, 'r') as f:
        fdata = f.readlines()
        for line in fdata:
            if '>' in line:
                f_oldname = int(line.split('>')[1].split('\n')[0])
            else:
                seq = line.split('\n')[0]
                D_faa[f_oldname] += seq

    D_gff = defaultdict(dict)

    with open(in_gff, 'r') as g:
        gdata = g.readlines()
        for line in gdata:
            words = line.split()
            if len(words) > 8:
                q_scaff = words[0]
                q_src = words[1]
                q_tax = words[2]
                q_start = int(words[3])
                q_end = words[4]
                q_unk = words[5]
                q_str = words[6]
                q_zero = words[7]
                q_oldname = int(words[8].split('ID=')[1].split(';')[0])

                D_gff[q_scaff][q_start] = [q_scaff, q_src, q_tax, q_start, q_end, q_unk, q_str, q_zero, q_oldname]


    scafflist = D_gff.keys()
    scafflist.sort()


    D_startlist = defaultdict(list)
        
    for scaff in D_gff.keys():
        D_startlist[scaff] = D_gff[scaff].keys()
        D_startlist[scaff].sort()

    i = 0

    D_sorted = defaultdict(list)

    for scaff in scafflist:
        for start in D_startlist[scaff]:
            i += 1
            D_gff[scaff][start] += [i]
            D_sorted[i] = D_gff[scaff][start]


    # Write in output file
    o_gff = open('re_tagged.gff', 'w')
    o_gff.write('##gff-version 3\n')
    
    for i in D_sorted.keys():
        words = D_sorted[i]
        o_gff.write(words[0] + '\t')
        o_gff.write(words[1] + '\t')
        o_gff.write(words[2] + '\t')
        o_gff.write(str(words[3]) + '\t')
        o_gff.write(words[4] + '\t')
        o_gff.write(words[5] + '\t')
        o_gff.write(words[6] + '\t')
        o_gff.write(words[7] + '\t')

        code = str(i + 10000)[1:]

        o_gff.write('ID=' + in_tag + '_' + code + '\n') 

    o_faa = open('re_tagged.faa', 'w')
    for i in D_sorted.keys():
        words = D_sorted[i]

        code = str(i + 10000)[1:]

        o_faa.write('>' + in_tag + '_' + code + '\n') 
        query = D_faa[D_sorted[i][8]]
        while len(query) > 70:
            o_faa.write(query[0:70] + '\n')
            query = query[70:]
        o_faa.write(query + '\n')



if __name__ == "__main__":
    main(sys.argv[1:])
