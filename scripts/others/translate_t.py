import getopt, sys, glob, os, re, subprocess, time

def usage():
    print ''

def main(argv):

    # Get argument
    global gff, fasta
    gff = ''
    fasta = ''

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
            gff = arg
        elif opt == '-f':
            fasta = arg

    # Making dict
    global features, contigs
    features = {}
    contigs = {}
    
    # codon table
    codon = ('TTT', 'TTC', 'TTA', 'TTG', 'TCT', 'TCC', 'TCA', 'TCG', 'TAT', 'TAC', 'TAA', 'TAG', 'TGT', 'TGC', 'TGA', 'TGG', 'CTT', 'CTC', 'CTA', 'CTG', 'CCT', 'CCC', 'CCA', 'CCG', 'CAT', 'CAC', 'CAA', 'CAG', 'CGT', 'CGC', 'CGA', 'CGG', 'ATT', 'ATC', 'ATA', 'ATG', 'ACT', 'ACC', 'ACA', 'ACG', 'AAT', 'AAC', 'AAA', 'AAG', 'AGT', 'AGC', 'AGA', 'AGG', 'GTT', 'GTC', 'GTA', 'GTG', 'GCT', 'GCC', 'GCA', 'GCG', 'GAT', 'GAC', 'GAA', 'GAG', 'GGT', 'GGC', 'GGA', 'GGG')
    elevaminoacid = ('F','F','L','L','S','S','S','S','Y','Y','X','X','C','C','X','W','L','L','L','L','P','P','P','P','H','H','Q','Q','R','R','R','R','I','I','I','M','T','T','T','T','N','N','K','K','S','S','R','R','V','V','V','V','A','A','A','A','D','D','E','E','G','G','G','G')
    fouraminoacid = ()
    global elevtable, fourtable
    elevtable = dict(zip(codon, elevaminoacid))
    fourtable = dict(zip(codon, fouraminoacid))

    # Writing in dictionary
    with open(gff, 'r') as gfile:
        gdata = gfile.readlines()
        for line in gdata:
            gwords = line.split(None, 8)
            if len(gwords) == 9:
                gID = gwords[8].split('=')[1]
                gscaff = gwords[0]
                if gwords[6] == '+':
                    gdxn = '1'
                if gwords[6] == '-':
                    gdxn = '2'
                gstart = gwords[3]
                gend = gwords[4]
                if gwords[2] == 'tRNA':
                    features[gID] = gID + ';' + gdxn + ';' + gscaff + ';' + gstart + ';' + gend + ';'

    global fkey, fvalue, rvalue, reversenc
    fkey = ''
    fvalue = ''
    rvalue = ''
    reversenc = {'T':'A', 'C':'G', 'A':'T', 'G':'C', 'N':'N', 'n':'n', 'Y':'R', 'R':'Y','S':'S', 'M':'K', 'K':'M','W':'W'}
    
    with open(fasta, 'r') as ffile:
        fdata = ffile.readlines()
        for line in fdata:
            if re.search('>', line) != None:
                fvalue = ''
                rvalue = ''
                fkey = line.split('>')[1].split()[0]
            if re.search('>', line) == None:
                fvalue += line.split('\n')[0]
                rstrand = ''
                for x in line.split('\n')[0]:
                    rstrand += reversenc[x]
                rvalue += rstrand
            contigs[fkey] = [fvalue, rvalue]

    # Translation
    for gkey in features:
        for fkey in contigs:
            if features[gkey].split(';')[2] == fkey:
                if features[gkey].split(';')[1] == '1':
                    features[gkey] += translate(1, fkey, features[gkey].split(';')[3], features[gkey].split(';')[4])
                elif features[gkey].split(';')[1] == '2':
                    features[gkey] += translate(2, fkey, features[gkey].split(';')[3], features[gkey].split(';')[4])

    # Write in output file
    output = open('protein_output.fasta', 'w')
    for x in features:
        if not features[str(x)].split(';')[5] == '':
            output.write('>' + str(x) + '\n')
            ptnseq = features[str(x)].split(';')[5]
            while len(ptnseq) > 70:
                output.write(ptnseq[0:70] + '\n')
                ptnseq = ptnseq[70:]
            output.write(ptnseq + '\n')


def translate(tldxn, tlscaff, tlstart, tlend):
    if tldxn == 1:
        tlnuc = contigs[fkey][0][int(tlstart)-1:int(tlend)]
    elif tldxn == 2:
        tlnuc = contigs[fkey][1][int(tlstart)-1:int(tlend)]
        tlnuc = tlnuc[::-1]
    tli = 1
    tlcodon = ''
    tlptnseq = ''
    while tli < int(tlend)-int(tlstart):
        tlcodon += tlnuc[tli-1:tli+2] + ';'
        tli += 3
    tlcodon = tlcodon.split(';')
    for codon in tlcodon:
        if codon in elevtable.keys():
            tlptnseq += elevtable[codon]
        else:
            tlptnseq += 'X'
    if tlptnseq[0] == 'V' or tlptnseq[0] == 'L' or tlptnseq[0] == 'I':
        tlptnseq = 'M' + tlptnseq[1:]
    tlptnseq = tlptnseq[::-1][1:][::-1]
    if len(tlptnseq) > 1:
        if tlptnseq[::-1][0] == 'X':
            tlptnseq = tlptnseq[::-1][1:][::-1]
    return(tlptnseq)        

if __name__ == "__main__":
    main(sys.argv[1:])
