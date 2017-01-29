import os
import sys

folder_path= sys.argv[1]
proj_name = sys.argv[2]
jbr_path =  "/var/www/jbrowse/JBrowse-1.11.6/myanno/json"

command_1 = "cp -r " + folder_path + "/" + proj_name + " " + jbr_path

checkcopy = os.system(command_1)

if checkcopy == 0:
	print("JBrowse archive file is copied to JBrowse folder.")
	print("JBrowse successfully launched!\nThis project's JBrowse address is\nhttp://[yourservername]/jbrowse/JBrowse-1.11.6/index.html?data=myanno/json/" + proj_name)

