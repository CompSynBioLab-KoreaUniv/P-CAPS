#!/bin/bash

KINGDOM=$1
FOLDER_PATH=$2
FILE_f="$FOLDER_PATH/inputseq.fna"
TOOL_PATH="/YOURTOOLPATH/rnammer-1.2.src/rnammer"
TOOL_PATH2="/home/pCAPS/scripts/others"

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

if test -f $FILE_f
then
    echo -e "Assembly fna check ... OK"
else
    echo -e \\n"Assembly fna is not exist. Please provide proper assembly fna file."
    HELP
fi

#Test querydir
if test -d $FOLDER_PATH/rnammer
then
    echo -e "RNAmmer directory already exists."
else
    mkdir $FOLDER_PATH/rnammer
    echo -e "RNAmmer directory was generated."
fi

#Test RNAmmer1.2
if test -f $TOOL_PATH
then
    echo -e "RNAmmer1.2 is exists."
else
    echo -e \\n"RNAmmer1.2 is not exist. Please provide proper RNAmmer1.2 path."
    HELP
fi

#Run RNAmmer1.2

now=$(date)
echo -e \\n"START : RNAmmer1.2"
echo -e "TIME  : $now\n"

cd $FOLDER_PATH/rnammer

$TOOL_PATH -S $KINGDOM -m lsu,ssu,tsu -xml $FOLDER_PATH/rnammer/rnammer_output.xml -gff $FOLDER_PATH/rnammer/rnammer_output_gff2.gff -h $FOLDER_PATH/rnammer/rnammer_output.hmmreport < $FILE_f

$TOOL_PATH2/convert_RNAmmer_to_gff3.pl --input $FOLDER_PATH/rnammer/rnammer_output_gff2.gff > $FOLDER_PATH/rnammer/rnammer_output.gff

cd $FOLDER_PATH/rnammer
python $TOOL_PATH2/translate_r.py -g $FOLDER_PATH/rnammer/rnammer_output.gff -f $FILE_f

now=$(date)
echo -e \\n"END   : RNAmmer1.2"
echo -e "TIME  : $now\n"


