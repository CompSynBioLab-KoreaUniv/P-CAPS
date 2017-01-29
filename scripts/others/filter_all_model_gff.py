import getopt, sys, glob, os, re, subprocess, time

def usage():
    print ''

def main(argv):

    # Get argument
    global Agff, fasta
    Agff = ''
    fasta = ''

    try:
        opts, args = getopt.getopt(argv, "ha:f:", ['help'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt == '-a':
            Agff = arg
        elif opt == '-f':
            fasta = arg

    # Make dict
    global IDdict
    IDdict = {}

    # Writing in dict
    with open(Agff, 'r') as Afile:
        Adata = Afile.readlines()
        for line in Adata:
            Awords = line.split(None, 8)
            if len(Awords) >= 9:
                Acode = int(Awords[8].split(';')[0].split('=')[1])
                IDdict[Acode] = Awords

    IDlist = IDdict.keys()
    IDlist.sort()

    print 'Before filtering: ' + str(len(IDlist))

    global fkey, fvalue, rvalue, reversenc
    fkey = ''
    fvalue = ''
    rvalue = ''
    reversenc = {'t':'A', 'c':'G', 'a':'T', 'g':'C', 'T':'A', 'C':'G', 'A':'T', 'G':'C', 'N':'N', 'n':'n', 'Y':'R', 'R':'Y','S':'S', 'M':'K', 'K':'M', 'W':'W'}


    contigs = {}
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

    # Endcodon filtering
    codonparsedIDlist = []
    for x in IDdict:
        for fkey in contigs:
            if IDdict[x][0] == fkey:
                if IDdict[x][6] == '+':
                    tlnuc = contigs[fkey][0][int(IDdict[x][4])-3:int(IDdict[x][4])]
                if IDdict[x][6] == '-':
                    tlnuc = contigs[fkey][1][int(IDdict[x][3])-1:int(IDdict[x][3])+2]
                    tlnuc = tlnuc[::-1]
        
                normalend = ['TGA', 'TAA', 'TAG']
                if tlnuc in normalend:
                    codonparsedIDlist += [x]
            
    print 'After Endcodon_filtering: ' + str(len(codonparsedIDlist))

    filteredIDlist = codonparsedIDlist

    # Endpoint parsing
    global enddict, endparsedIDlist
    enddict = {}
    endparsedIDlist = []

    for x in filteredIDlist:
        if IDdict[x][6] == '+':
            endpoint = '+;' + IDdict[x][0] + ';' + IDdict[x][4]
        elif IDdict[x][6] == '-':
            endpoint = '-;' + IDdict[x][0] + ';' + IDdict[x][3]
        if enddict.get(endpoint) == None:
            enddict[endpoint] = [x]
        elif enddict.get(endpoint) != None:
            enddict[endpoint] += [x]

    for key in enddict:
        if key.split(';')[0] == '+':
            for x in enddict[key]:
                if type(x) is int:
                    enddict[key].remove(x)
                    enddict[key][:0] = ['ID=' + str(x) + ';' + IDdict[x][3]]
        elif key.split(';')[0] == '-':
            for x in enddict[key]:
                if type(x) is int:
                    enddict[key].remove(x)
                    enddict[key][:0] = ['ID=' + str(x) + ';' + IDdict[x][4]]            

    # Endpoint filtering        
    for key in enddict:
        if len(enddict[key]) == 1:
            endparsedIDlist += [enddict[key][0].split(';')[0].split('=')[1]]
        if len(enddict[key]) != 1:
            no1end = []
            for x in enddict[key]:
                if len(no1end) == 0:
                    no1end = [x]
                if len(no1end) > 0:
                    if IDdict[int(x.split(';')[0].split('=')[1])][8].count('source=') > IDdict[int(no1end[0].split(';')[0].split('=')[1])][8].count('source='):
                        no1end = [x]
                    if not x in no1end:
                        if IDdict[int(x.split(';')[0].split('=')[1])][8].count('source=') == IDdict[int(no1end[0].split(';')[0].split('=')[1])][8].count('source='):
                            no1end += [x]

            if len(no1end) == 1:
                endparsedIDlist += [no1end[0].split(';')[0].split('=')[1]]

            elif len(no1end) > 1:
                endnote = {}
                for x in no1end:
                    endnote[int(x.split(';')[1])] = [x.split(';')[0].split('=')[1]]
                    if IDdict[int(x.split(';')[0].split('=')[1])][8].count('Blast_hit') != 0:
                        endnote[int(x.split(';')[1])] += [IDdict[int(x.split(';')[0].split('=')[1])][8].split('Blast_hit_')[1].split(';')[0]]

                # Length
                if max(endnote.keys()) - min(endnote.keys()) < 10:
                    if key.split(';')[0] == '+':
                        endparsedIDlist += [endnote[min(endnote.keys())][0]]
                    elif key.split(';')[0] == '-':
                        endparsedIDlist += [endnote[max(endnote.keys())][0]]

                # IPR number
                elif key.split(';')[0] == '+' and len(endnote[min(endnote.keys())]) == 2:
                    endparsedIDlist += [endnote[min(endnote.keys())][0]]
                elif key.split(';')[0] == '-' and len(endnote[max(endnote.keys())]) == 2:
                    endparsedIDlist += [endnote[max(endnote.keys())][0]]

                # Overlap: Same
                elif key.split(';')[0] == '+' and IDdict[int(endnote[min(endnote.keys())][0])][8].count('overlapped') == IDdict[int(endnote[max(endnote.keys())][0])][8].count('overlapped'):
                    endparsedIDlist += [endnote[min(endnote.keys())][0]]
                elif key.split(';')[0] == '-' and IDdict[int(endnote[max(endnote.keys())][0])][8].count('overlapped') == IDdict[int(endnote[min(endnote.keys())][0])][8].count('overlapped'):
                    endparsedIDlist += [endnote[max(endnote.keys())][0]]

                # Overlap: Diff
                elif key.split(';')[0] == '+' and IDdict[int(endnote[min(endnote.keys())][0])][8].count('overlapped') > IDdict[int(endnote[max(endnote.keys())][0])][8].count('overlapped'):
                    overlapnote = {}
                    for y in endnote:
                        overlapnote[IDdict[int(endnote[y][0])][8].count('overlapped')] = [y, endnote[y]]
                    for z in endnote:
                        if IDdict[int(endnote[z][0])][8].count('overlapped') != min(overlapnote.keys()):
                            endnote[z] == ''
                    endparsedIDlist += [endnote[min(endnote.keys())][0]]
                elif key.split(';')[0] == '-' and IDdict[int(endnote[max(endnote.keys())][0])][8].count('overlapped') > IDdict[int(endnote[min(endnote.keys())][0])][8].count('overlapped'):
                    overlapnote = {}
                    for y in endnote:
                        overlapnote[IDdict[int(endnote[y][0])][8].count('overlapped')] = [y, endnote[y]]
                    for z in endnote:
                        if IDdict[int(endnote[z][0])][8].count('overlapped') != min(overlapnote.keys()):
                            endnote[z] == ''
                    endparsedIDlist += [endnote[max(endnote.keys())][0]]


    for k in endparsedIDlist:
        endparsedIDlist.remove(k)
        endparsedIDlist[:0] = [int(k)]
    endparsedIDlist.sort()
    
    filteredIDlist = endparsedIDlist

    print 'After Endpoint_filtering: ' + str(len(endparsedIDlist))



    # Tinygene filtering

    #################
    nuccutvalue = 0
    #################

    for k in filteredIDlist:
        nuclength = int(IDdict[k][4])-int(IDdict[k][3])
        if nuclength < nuccutvalue:
            if IDdict[k][8].count('Blast_hit') == 0:
                if IDdict[k][8].count('source') == 1:
                    filteredIDlist.remove(k)

    print 'After Tinygene_filtering: ' + str(len(filteredIDlist))



    # Overlap parsing    
    overlapcount = []
    for k in filteredIDlist:
        if k in IDdict.keys():
            if not IDdict[k][8].count('overlapped') in overlapcount:
                overlapcount += [IDdict[k][8].count('overlapped')]
    overlapcount.sort()
    overlapcount.reverse()

    for y in overlapcount:
        for x in filteredIDlist:
            if IDdict[x][8].count('overlapped') == y:
                if y > 10:
                    filteredIDlist.remove(x)


    #################
    overlapvalue = 0 
    #################


    overlapdict = {}
    for x in filteredIDlist:
        for y in filteredIDlist:
            if IDdict[x][6] == IDdict[y][6] and IDdict[x][0] == IDdict[y][0]:

                newxst = int(IDdict[x][3]) + overlapvalue
                newxed = int(IDdict[x][4]) - overlapvalue
                newyst = int(IDdict[y][3]) + overlapvalue
                newyed = int(IDdict[y][4]) - overlapvalue

                stvalue = (newxst - newyst)*(newxst - newyed)
                edvalue = (newxed - newyst)*(newxed - newyed)
                if stvalue < 0 or edvalue < 0:
                    if not x in overlapdict.keys():
                        overlapdict[x] = [y]
                    if not y in overlapdict[x]:
                        overlapdict[x] += [y]
                    if not y in overlapdict.keys():
                        overlapdict[y] = [x]
                    if not x in overlapdict[y]:
                        overlapdict[y] += [x]


    overlapIDset = overlapdict.keys()

    for x in overlapdict:
        for y in overlapdict[x]:
            if len(overlapdict[x]) == 1 and len(overlapdict[y]) == 1:
                xblasthit = IDdict[x][8].count('Blast_hit')
                yblasthit = IDdict[x][8].count('Blast_hit')
                if xblasthit < yblasthit:
                    filteredIDlist.remove(y)
                    overlapIDset.remove(y)
                if yblasthit > xblasthit:
                    filteredIDlist.remove(x)
                    overlapIDset.remove(x)



    # glimmer filtering

    for k in IDlist:
        if IDdict[k][8].count('source') == 1:
            if IDdict[k][1].count('glimmer') == 1:
                if IDdict[k][8].count('Blast_hit') == 0:
                    if k in filteredIDlist:
                        filteredIDlist.remove(k)
                    


    # Making output.gff
    outputgffname = Agff.split('.g')[0] + '_filtered.gff'

    with open(outputgffname, 'w') as Ofile:
        Ofile.write('##gff-version 3\n')
        for line in Adata:
            if len(line.split(None, 8)) >= 9:
                if int(line.split(None, 8)[8].split(';')[0].split('=')[1]) in filteredIDlist:
                    Ofile.write(line)



    
if __name__ == "__main__":
    main(sys.argv[1:])
