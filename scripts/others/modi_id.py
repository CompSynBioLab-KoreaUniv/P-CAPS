import os
import sys

folder_path = sys.argv[1]
file_name = sys.argv[2]
file_path = folder_path + "/" + file_name
modi_file_path = folder_path + "/inputseq.fna"
real_id_file_path = folder_path + "/real_id.txt"

origin_fna = open(file_path, "r")
fna_modi = open(modi_file_path, "a")
real_id = open(real_id_file_path, "a")

fnalines = origin_fna.readlines()
fna = []
modi_fna = []
real_scaffold = []

for line in fnalines:
	fna.append(line)

length_fna = len(fna)

s = 1

for i in range(0, length_fna):
	temp = fna[i]
	checkid = temp.find('>')
	if checkid == -1:
		upperbase = temp.upper()
		modi_fna.append(upperbase)
	elif checkid == 0:
		identifier = ">scaffold" + str(s) + "\n"
		real_scaffold.append(">scaffold" + str(s) + "\t=>\t" + temp)
		modi_fna.append(identifier)
		s = s + 1
	else:
		modi_fna.append(temp + "\n")

length_real = len(real_scaffold)

for i2 in range(0, length_fna):
	fna_modi.write(modi_fna[i2])

for i3 in range(0, length_real):
	real_id.write(real_scaffold[i3])

origin_fna.close()
fna_modi.close()
real_id.close()

