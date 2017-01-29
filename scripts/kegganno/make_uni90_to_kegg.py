import sys
import os
import re
from collections import defaultdict

def main(keggmap_file, uni90map_file, komap_file, bltp_file):
    
    kegg_dict = defaultdict(str)
    with open(keggmap_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            uni = line.split()[0]
            knum = line.split()[2]
            kegg_dict[uni] = knum

    uni90_dict = defaultdict(list)
    with open(uni90map_file, 'r') as g:
        lines = g.readlines()
        for line in lines:
            uni90 = line.split()[2]
            uni = line.split()[0]
            if kegg_dict[uni] != '':
                query_kegg = kegg_dict[uni]
                if not query_kegg in uni90_dict[uni90]:
                    uni90_dict[uni90] += [query_kegg]

    ko_dict = defaultdict(list)
    A_dict = defaultdict(int)
    B_dict = defaultdict(int)
    C_dict = defaultdict(int)

    Enable_set = ['Metabolism', 'Genetic Information Processing', 'Environmental Information Processing', 'Cellular Processes']
    with open(komap_file, 'r') as h:
        lines = h.readlines()
        for line in lines:
            if 'A<b>' in line:
                query_A = line.split('A<b>')[1].split('</b>')[0]
                A_dict[query_A] = 0
            if 'B  <b>' in line:
                query_B = line.split('B  <b>')[1].split('</b>')[0]
                B_key = query_A + '\t' + query_B
                B_dict[B_key] = 0
            if 'C    ' in line:
                query_C = line.split('C    ')[1].split(' [')[0].split(None,1)[1]
                kpnumber = 'ko' + line.split(':ko')[1].split(']')[0]
                C_key = query_A + '\t' + query_B + '\t' + query_C
                C_dict[C_key] = 0
            if 'D      ' in line:
                query_ko = line.split()[1]
                if query_A in Enable_set:
                    if query_ko in ko_dict.keys():
                        ko_dict[query_ko] += [[query_A, B_key, C_key, kpnumber]]
                    if not query_ko in ko_dict.keys():
                        ko_dict[query_ko] = [[query_A, B_key, C_key, kpnumber]]


    kegg_annodict = defaultdict(dict)
    with open(bltp_file, 'r') as i:
        lines = i.readlines()
        for line in lines:
            query = line.split()[0]
            uni90 = line.split()[1]
            if not uni90_dict[uni90] == []:
                if not 'first' in kegg_annodict[query].keys():
                    if kegg_annodict[query] == {}:
                        if len(uni90_dict[uni90]) == 1:
                            query_ko = uni90_dict[uni90][0]
                            if not ko_dict[query_ko] == []:
                                kegg_annodict[query]['first'] = uni90_dict[uni90][0]
                        if not len(uni90_dict[uni90]) == 1:
                            query_ko_list = uni90_dict[uni90]
                            for query_ko in query_ko_list:
                                if not ko_dict[query_ko] == []:
                                    if not 'list' in kegg_annodict[query].keys():
                                        kegg_annodict[query]['list'] = [query_ko]
                                    if 'list' in kegg_annodict[query].keys():
                                        kegg_annodict[query]['list'] += [query_ko]
                    if kegg_annodict[query] != {}:
                        query_ko_list = uni90_dict[uni90]
                        for query_ko in query_ko_list:
                            if not ko_dict[query_ko] == []:
                                if not 'list' in kegg_annodict[query].keys():
                                    kegg_annodict[query]['list'] = [query_ko]
                                if 'list' in kegg_annodict[query].keys():
                                    kegg_annodict[query]['list'] += [query_ko]



    output_file = 'gene_to_ko.tbl'
    output_handle = open(output_file, "w")
    genelist = kegg_annodict.keys()
    genelist.sort()
    for gene in genelist:
        if 'first' in kegg_annodict[gene].keys():
            output_handle.write(gene + '\t' + kegg_annodict[gene]['first'] + '\n')
    output_handle.close()


    for gene in genelist:
        if 'first' in kegg_annodict[gene].keys():
            query_kolist = ko_dict[kegg_annodict[gene]['first']]
            for query_ko in query_kolist:
                A_dict[query_ko[0]] += 1
                B_dict[query_ko[1]] += 1
                C_dict[query_ko[2]] += 1

    output_file = 'ko_summary.txt'
    output_handle = open(output_file, "w")
    output_handle.write('#### A level ####\n')
    A_keylist = A_dict.keys()
    A_keylist.sort()
    for key in A_keylist:
        if not A_dict[key] == 0:
            output_handle.write(key + '\t' + str(A_dict[key]) + '\n')
    output_handle.write('#### B level ####\n')
    B_keylist = B_dict.keys()
    B_keylist.sort()
    for key in B_keylist:
        if not B_dict[key] == 0:
            output_handle.write(key + '\t' + str(B_dict[key]) + '\n')
    output_handle.write('#### C level ####\n')
    C_keylist = C_dict.keys()
    C_keylist.sort()
    for key in C_keylist:
        if not C_dict[key] == 0:
            output_handle.write(key + '\t' + str(C_dict[key]) + '\n')
    output_handle.close()

if __name__ == "__main__":
    main(*sys.argv[1:])
