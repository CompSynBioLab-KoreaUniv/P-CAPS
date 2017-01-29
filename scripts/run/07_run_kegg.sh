#!/bin/bash

FOLDER_PATH=$1
KEGG_PYTHON="/home/pCAPS/scripts/kegganno/make_uni90_to_kegg.py"
KEGG_MAPPING="/home/pCAPS/scripts/kegganno/keggmapping.dat"
UNIREF_MAPPING="/home/pCAPS/scripts/kegganno/uni90mapping.dat"
KO_KEG="/home/pCAPS/scripts/kegganno/ko00001.keg"
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

if test -d $FOLDER_PATH
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi

#Test querydir
if test -d $FOLDER_PATH/keggmap
then
    echo -e "KEGG mapping directory already exists."
else
    mkdir $FOLDER_PATH/keggmap
    echo -e \\n"KEGG mapping directory was generated."
fi

#Test python code
if test -f $KEGG_PYTHON
then
    echo -e "Python code is exists."
else
    echo -e \\n"Python code is not exist. Please provide proper python code path."
    HELP
fi

#Test kegg mapping data
if test -f $KEGG_MAPPING
then
    echo -e "KEGG mapping data is exists."
else
    echo -e \\n"KEGG mapping data is not exist. Please provide proper data file path."
    HELP
fi 

#Test uni90 mapping data
if test -f $UNIREF_MAPPING
then
    echo -e "UNI90 mapping data is exists."
else
    echo -e \\n"UNI90 mapping data is not exist. Please provide proper data file path."
    HELP
fi

#Test keg file
if test -f $KO_KEG
then
    echo -e "KEGG file is exists."
else
    echo -e \\n"KEGG file is not exist. Please provide proper KEGG file path."
    HELP
fi

#Run KEGG mapping

now=$(date)
echo -e \\n"START : KEGG ortholog analysis"
echo -e "TIME  : $now\n"


cd $FOLDER_PATH/keggmap

echo "Start KEGG analysis.........."

python $KEGG_PYTHON $KEGG_MAPPING $UNIREF_MAPPING $KO_KEG $FOLDER_PATH/blastp/blastp_output.tbl 

echo "Finish."
echo "Start making special file for annotation report.........."

python $PYTHON_PATH/column_ko.py $FOLDER_PATH 2>> $FOLDER_PATH/annolog/kegg.log

echo "Finish."

now=$(date)
echo -e \\n"END   : KEGG ortholog analysis"
echo -e "TIME  : $now\n"


