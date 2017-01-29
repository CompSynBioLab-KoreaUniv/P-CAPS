import os
import sys
import subprocess

folder_path = sys.argv[1]
fna_file = sys.argv[2]

command_1 = "sed '/>/d' " + fna_file + " > " + folder_path + "/delete_id.fna"

os.system(command_1)

fna = open(folder_path + "/delete_id.fna", 'r')

fna_data = fna.read()
fna_len = len(fna_data)

countA = 0
countG = 0
countC = 0
countT = 0
countX = 0
countN = 0

for i in range(0, fna_len):
	if fna_data[i]=='A':
		countA = countA + 1
	elif fna_data[i] == 'G':
		countG = countG + 1
	elif fna_data[i] == 'C':
		countC = countC + 1
	elif fna_data[i] == 'T':
		countT = countT + 1	
	elif fna_data[i] == 'X':
		countX = countX + 1
	elif fna_data[i] == 'N':
		countN = countN + 1
	elif fna_data[i] == 'a':
		countA = countA + 1
	elif fna_data[i] == 'g':
		countG = countG + 1
	elif fna_data[i] == 'c':
		countC = countC + 1
	elif fna_data[i] == 't':
		countT = countT + 1
	elif fna_data[i] == 'x':
		countX = countX + 1
	elif fna_data[i] == 'n':
		countN = countN + 1

total_base = countA + countT + countG + countC + countX + countN
result = str(total_base) + "bp"

print result

fna.close()

command1 = 'rm ' + folder_path + '/delete_id.fna'

os.system(command1)

