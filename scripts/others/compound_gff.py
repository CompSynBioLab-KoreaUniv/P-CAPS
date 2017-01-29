import getopt, sys, glob, os, re, subprocess, time

def usage():
    print 'compound_gff.py -z <A_type("new" or "old")> -a <A_gff3> -x <A_tag> -b <B_gff3> -y <B_tag>'

def main(argv):

    # Get argument
    global Agff, Atag, Bgff, Btag, Atype
    Agff = ''
    Atag = ''
    Bgff = ''
    Btag = ''
    Atype = ''

    try:
        opts, args = getopt.getopt(argv,"h:a:x:b:y:z:", ['help'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt == '-a':
            Agff = arg
        elif opt == '-x':
            Atag = arg
        elif opt == '-b':
            Bgff = arg
        elif opt == '-y':
            Btag = arg
        elif opt == '-z':
            Atype = arg

    # Making dict
    global features
    features = {}

    # Writing in dictionary
    with open(Agff, 'r') as Afile:
        Adata = Afile.readlines()
        for line in Adata:
            Awords = line.split(None, 8)
            if len(Awords) == 9 and Awords[2] == 'CDS':
                if Awords[6] == '+':
                    Adxn = '1'
                elif Awords[6] == '-':
                    Adxn = '2'
                Acode = Awords[0] + '*' + str(int(Awords[4])+int(Awords[3])*1000000000+1000000000000000000) + '/' + Awords[0] + '$' +Adxn
                if Atype == 'new':
                    Awords[8] = 'ID=;' + 'source=' + Atag + ';'
                elif Atype == 'old':
                    if re.search('overlapped', Awords[8]) == None:
                        Awords[8] = 'ID=;' + Awords[8].split(';',1)[1].split('\n',1)[0]
                    else:
                        Awords[8] = 'ID=;' + Awords[8].split(';',1)[1].split('overlapped',1)[0]
                features[Acode] = Awords
    
    with open(Bgff, 'r') as Bfile:
        Bdata = Bfile.readlines()
        for line in Bdata:
            Bwords = line.split(None, 8)
            if len(Bwords) == 9 and Bwords[2] == 'CDS':
                if Bwords[6] == '+':
                    Bdxn = '1'
                elif Bwords[6] == '-':
                    Bdxn = '2'
                Bcode = Bwords[0] + '*' + str(int(Bwords[4])+int(Bwords[3])*1000000000+1000000000000000000) + '/' + Bwords[0] + '$' + Bdxn
                if Bcode in features:
                    if re.search( 'source=' + Btag + ';' ,features[Bcode][8]) == None:
                        features[Bcode][8] = features[Bcode][8] + 'source=' + Btag + ';'
                else:
                    Bwords[8] = 'ID=;' + 'source=' + Btag + ';'
                    features[Bcode] = Bwords

    # Sorting code     
    codelist = features.keys()
    codelist.sort()
    genenumber = 1

    for x in codelist:
        if int(features[x][3]) > int(features[x][4]):
            codelist.remove(x)

    for x in codelist:
        features[x][8] = re.sub('ID=;','ID='+str(genenumber)+';',features[x][8])
        genenumber += 1


    # Overlap parsing
    for key in features:
        for x in codelist:
            Compare(key, x)

    # Writing in gff file
    output = open('Merged_CDS.gff', 'w')
    output.write('##gff-version 3\n')
    for x in codelist:
        output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' % (features[x][0], 'P-CAPS', features[x][2], features[x][3], features[x][4], features[x][5], features[x][6], features[x][7], features[x][8]))

    # Comparing function

def Compare(Ccode, Dcode):
    if Ccode.split('/')[1] == Dcode.split('/')[1]:
        p_Ccode_s = int(Ccode.split('*')[1].split('/')[0][1:10])
        p_Dcode_s = int(Dcode.split('*')[1].split('/')[0][1:10])
        p_Ccode_e = int(Ccode.split('*')[1].split('/')[0][10:19])
        p_Dcode_e = int(Dcode.split('*')[1].split('/')[0][10:19])

        st = (p_Ccode_s-p_Dcode_s)*(p_Dcode_s-p_Ccode_e)
        ed = (p_Ccode_s-p_Dcode_e)*(p_Dcode_e-p_Ccode_e)
        if st > 0 or ed > 0:
            if re.search(features[Dcode][8].split(';',1)[0], features[Ccode][8]) == None:
                features[Ccode][8] += 'overlapped_' + features[Dcode][8].split(';',1)[0] + ';'
            if re.search(features[Ccode][8].split(';',1)[0], features[Dcode][8]) == None:
                features[Dcode][8] += 'overlapped_' + features[Ccode][8].split(';',1)[0] + ';'

if __name__ == "__main__":
    main(sys.argv[1:])
