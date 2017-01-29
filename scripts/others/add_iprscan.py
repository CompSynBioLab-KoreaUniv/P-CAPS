import sys, os, re
from Bio import SeqIO
from Bio.Alphabet import generic_dna
from BCBio import GFF
from collections import defaultdict
from BCBio.GFF import GFF3Writer

global signalp_tax
signalp_tax = 'SignalP_GRAM_NEGATIVE'

def main(gff_file, ipr_file):
    ipr_dict = defaultdict(dict)
    with open(ipr_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            items = line.split('\t')
            name = items[0]
            tool = items[3]
            title = items[4]
            desc = items[5]
            start = items[6]
            end = items[7]
            if desc == "":
                query_desc = '\'[%s:%s]%s\'' %(start, end, title)
            else:
                query_desc = '\'[%s:%s]%s: %s\'' %(start, end, title, desc)
            if not 'SignalP' in tool:
                if not tool in ipr_dict[name].keys():
                    ipr_dict[name][tool] = []            
                ipr_dict[name][tool] += [query_desc]
            else:
                if tool == signalp_tax:
                    if not tool in ipr_dict[name].keys():
                        ipr_dict[name][tool] = []
                    ipr_dict[name][tool] += [query_desc]

    out_gff = ''
    with open(gff_file, 'r') as g:
        lines = g.readlines()
        for line in lines:
            query_line = line.split('\n')[0]
            if line.split('\t')[2] == "CDS":                
                feature_list = line.split('\t')[-1].split(';')
                for item in feature_list:
                    if 'locus_tag=' in item:
                        name = item.split('locus_tag=')[1]
                for key_tool in ipr_dict[name].keys():
                    if len(ipr_dict[name][key_tool]) == 1:
                        desc = ipr_dict[name][key_tool][0]
                    else:
                        desc = "/".join(ipr_dict[name][key_tool])
                    query_line += ';' + key_tool + '=' + desc
                    
            out_gff += query_line + '\n'


    output_file = gff_file.split('.gff')[0] + '_anno_iprscan.gff'
    output_handle = open(output_file, "w")
    output_handle.write(out_gff)
    output_handle.close()


if __name__ == "__main__":
    main(*sys.argv[1:])
