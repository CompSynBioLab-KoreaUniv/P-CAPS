import os
import sys
import subprocess
import time

folder_name = sys.argv[1]
folder_path = "/home/pCAPS/" + folder_name
fna_file = folder_path + "/inputseq.fna"
gff_path = folder_path + "/fully_decorated.gff"
annoinfo_path = folder_path + "/temp/annoinfo.txt"
feature_path = folder_path + "/temp/feature.txt"
script_path = "/home/pCAPS/scripts/others/"

command_1 = "awk -F '\t' '{print $3}' " + gff_path
rawfeature = subprocess.check_output(command_1, shell=True)
feature = open(feature_path, 'w')
feature.write(rawfeature)
feature.close()

command_2 = "python " + script_path + "count_base.py " + folder_path + " " + fna_file
command_3 = "grep -c 'CDS' " + feature_path
command_4 = "grep -c 'rRNA' " + feature_path
command_5 = "grep -c 'tRNA' " + feature_path
command_6 = "python " + script_path + "cal_gc.py " + folder_name + " " + fna_file
command_7 = "cat " + folder_path + "/busco/short_summary_busco.txt"

rawgc = subprocess.check_output(command_6, shell=True)
rawbase = subprocess.check_output(command_2, shell=True)
checkcds = os.system(command_3)
checkrrna = os.system(command_4)
checktrna = os.system(command_5)

if checkcds == 0:
    rawcds = subprocess.check_output(command_3, shell=True)
    cds = rawcds.rstrip('\n')
else :
    cds = 0

if checkrrna == 0:
    rawrrna = subprocess.check_output(command_4, shell=True)
    rrna = rawrrna.rstrip('\n')
else :
    rrna = 0

if checktrna == 0:
    rawtrna = subprocess.check_output(command_5, shell=True)
    trna = rawtrna.rstrip('\n')
else :
    trna = 0

gc = rawgc.rstrip('\n')
base = rawbase.rstrip('\n')

gene = int(cds) + int(rrna) + int(trna)

str_gene = str(gene)

now = time.localtime()
whattime = "%04d-%02d-%02d %02d:%02d:%02d" % (now.tm_year, now.tm_mon, now.tm_mday, now.tm_hour, now.tm_min, now.tm_sec)

checkbusco = os.system(command_7)

if checkbusco == 0 :
    busco_result = subprocess.check_output(command_7, shell=True)
else :
    busco_result = "Error was occured in running BUSCO"

reportinfo = open(folder_path + "/temp/reportinfo.txt", 'a')

reportinfo.write(base)
reportinfo.write('\n')
reportinfo.write(str(cds))
reportinfo.write('\n')
reportinfo.write(str(rrna))
reportinfo.write('\n')
reportinfo.write(str(trna))
reportinfo.write('\n')
reportinfo.write(str_gene)
reportinfo.write('\n')
reportinfo.write(gc)

reportinfo.close()

anno = open(annoinfo_path, 'a')
anno.write("# P-CAPS annotation summary report" + "\n" + "# (" + whattime  + ")\n")
anno.write('\n')
anno.write("  Project ID : " + folder_name)
anno.write('\n')
anno.write("  GCratio : " + gc)
anno.write('\n')
anno.write("  The number of base : " + base)
anno.write('\n')
anno.write("  The number of CDS : " + str(cds))
anno.write('\n')
anno.write("  The number of rRNA : " + str(rrna))
anno.write('\n')
anno.write("  The number of tRNA : " + str(trna))
anno.write('\n')
anno.write("  The number of gene : " + str_gene)
anno.write('\n\n')
anno.write('--------------------------------------------------------')
anno.write('\n\n')
anno.write(busco_result)

anno.close()



