import os, sys, subprocess

folder_path = sys.argv[1]
fna_file = sys.argv[2]
home_path = "/home/pCAPS"
probuild_path = "/YOURTOOLPATH/gmsuite/probuild"

command_1 = probuild_path + " --gc --seq " + fna_file + " > " + home_path + "/" + folder_path + "/temp/gc.txt"

os.system(command_1)

command_2 = "awk -F ' ' '{print $3}' " + home_path + "/" + folder_path + "/temp/gc.txt"

gc = subprocess.check_output(command_2, shell=True)
gcratio = gc.rstrip('\n') + "%"

print gcratio
