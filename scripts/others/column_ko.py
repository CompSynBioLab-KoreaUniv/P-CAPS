import os, sys, subprocess

folder_path = sys.argv[1]

temp_path = folder_path + "/temp"

command_2 = "grep -n '#### B level ####' " + folder_path + "/keggmap/ko_summary.txt > " + temp_path + "/start.txt"
command_3 = "sed -i s/':#### B level ####'//g  " + temp_path + "/start.txt"
command_4 = "grep -n '#### C level ####' " + folder_path + "/keggmap/ko_summary.txt > " + temp_path + "/end.txt"
command_5 = "sed -i s/':#### C level ####'//g " + temp_path + "/end.txt"

os.system(command_2)
os.system(command_3)
os.system(command_4)
os.system(command_5)

command_6 = "cat " + temp_path + "/start.txt"
command_7 = "cat " + temp_path + "/end.txt"

sp = subprocess.check_output(command_6, shell=True)
ep = subprocess.check_output(command_7, shell=True)

i_sp = int(sp)
i_ep = int(ep)

command_8 = "rm " + temp_path + "/start.txt " + temp_path + "/end.txt"

os.system(command_8)

num_a = i_ep - 1
num_b = i_ep - i_sp - 1
num_c = i_sp - 1
num_d = i_sp - 2

command_9 = "head -" + str(num_c) + " " + folder_path + "/keggmap/ko_summary.txt > " + temp_path + "/a_level_pre.txt"
command_10 = "tail -" + str(num_d) + " " + temp_path + "/a_level_pre.txt > " + temp_path + "/a_level.txt"
command_11 = "head -" + str(num_a) + " " + folder_path + "/keggmap/ko_summary.txt > " + temp_path + "/b_level_pre.txt"
command_12 = "tail -" + str(num_b) + " " + temp_path + "/b_level_pre.txt > " + temp_path + "/b_level.txt"

os.system(command_9)
os.system(command_10)
os.system(command_11)
os.system(command_12)

command_13 = "rm " + temp_path + "/a_level_pre.txt " + temp_path + "/b_level_pre.txt"

os.system(command_13)

command_14 = "awk -F '\t' '{print $1}' " + temp_path + "/a_level.txt > " + temp_path + "/a_name.txt"
command_15 = "awk -F '\t' '{print $2}' " + temp_path + "/a_level.txt > " + temp_path + "/a_num.txt"
command_16 = "awk -F '\t' '{print $2}' " + temp_path + "/b_level.txt > " + temp_path + "/b_name.txt"
command_17 = "awk -F '\t' '{print $3}' " + temp_path + "/b_level.txt > " + temp_path + "/b_num.txt"

os.system(command_14)
os.system(command_15)
os.system(command_16)
os.system(command_17)

command_18 = "rm " + temp_path + "/a_level.txt " + temp_path + "/b_level.txt"

os.system(command_18)

 

