#!/bin/bash

FOLDER_PATH=$1
BUSCO_DB=$2
BUSCO_PATH="/YOURTOOLPATH/BUSCO_v2.0"

function HELP {
    echo -e "Please input proper input. Example:"
    exit 1
}

#Counting args
numargs=$#
echo -e \\n"Number of arguments: $numargs"
if [ $numargs -eq 0 ]; then
    HELP
fi

#Test inputs
if test -d $FOLDER_PATH
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi

if test -d $BUSCO_PATH/dataset/$BUSCO_DB
then
    echo -e "BUSCO Database check ... OK"
else
    echo -e \\n"This database is not exist. Please provide proper database file."
    HELP
fi

#Test faa file

if test -f $FOLDER_PATH/gff/re_tagged.faa
then
    echo -e "Protein sequence file check ... OK"
else
    echo -e \\n"Protein sequence file is not exist. Please provide proper sequence file."
    HELP
fi

#Run BUSCO

now=$(date)
echo -e \\n"START : BUSCO ver.2"
echo -e "TIME  : $now\n"

cd $FOLDER_PATH

python $BUSCO_PATH/BUSCO.py -o busco -i $FOLDER_PATH/gff/re_tagged.faa -m prot -l $BUSCO_PATH/dataset/$BUSCO_DB -c 4
mv $FOLDER_PATH/run_busco $FOLDER_PATH/busco

now=$(date)
echo -e \\n"END   : BUSCO ver.2"
echo -e "TIME  : $now\n"


