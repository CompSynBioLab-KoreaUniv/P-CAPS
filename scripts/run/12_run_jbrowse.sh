#!/bin/bash

PROJECT_PATH=$1
FILE_f="inputseq.fna"
PROJECT_NAME=$2
FILE_g="fully_decorated.gff"
JBROWSE_PATH="/var/www/jbrowse/JBrowse-1.11.6"
JBROWSE_FOLDER_PATH=$PROJECT_PATH/$PROJECT_NAME
PYTHON_PATH="/home/pCAPS/scripts/others"

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

if test -d $PROJECT_PATH
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi

#Test querydir

if test -d $JBROWSE_FOLDER_PATH
then
    echo -e "JBrowse directory already exists."
else
    mkdir $JBROWSE_FOLDER_PATH
    echo -e "JBrowse directory was generated."
fi 

#Test gff file

if test -f $PROJECT_PATH/$FILE_g
then
    echo -e "GFF file check ... OK"
else
    echo -e \\n"GFF file is not exist. Please provide proper GFF file."
    HELP
fi

#Test JBrowse
if test -d $JBROWSE_PATH
then
    echo -e "JBrowse is exists."
else
    echo -e \\n"JBrowse is not exist. Please provide proper JBrowse path."
    HELP
fi

#Run JBrowse

now=$(date)
echo -e \\n"START : Launching JBrowse"
echo -e "TIME  : $now\n"

echo "Preparing.................."
$JBROWSE_PATH/bin/prepare-refseqs.pl --fasta $PROJECT_PATH/$FILE_f --out $PROJECT_PATH/$PROJECT_NAME
echo ""

echo "Making CDS track.................."
$JBROWSE_PATH/bin/flatfile-to-json.pl --gff $PROJECT_PATH/$FILE_g --type CDS --trackLabel CDS --out $PROJECT_PATH/$PROJECT_NAME
echo ""

echo "Making tRNA track.................."
$JBROWSE_PATH/bin/flatfile-to-json.pl --gff $PROJECT_PATH/$FILE_g --type tRNA --trackLabel tRNA --out $PROJECT_PATH/$PROJECT_NAME
echo ""

echo "Making rRNA track.................."
$JBROWSE_PATH/bin/flatfile-to-json.pl --gff $PROJECT_PATH/$FILE_g --type rRNA --trackLabel rRNA --out $PROJECT_PATH/$PROJECT_NAME
echo ""

echo "Generating names.................."
$JBROWSE_PATH/bin/generate-names.pl --verbose --out $PROJECT_PATH/$PROJECT_NAME

echo "Launching jbrowser.................."

python $PYTHON_PATH/launch_jbrowser.py $PROJECT_PATH $PROJECT_NAME

now=$(date)
echo -e \\n"END   : Launching JBrowse"
echo -e "TIME  : $now\n"



