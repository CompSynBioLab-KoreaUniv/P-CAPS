#!/bin/bash

FOLDER_PATH=$1
G_CODE=$2

FNA_PATH=$FOLDER_PATH/inputseq.fna
TOOL_PATH=/YOURTOOLPATH/Prodigal-2.6.3/prodigal

function HELP {
	echo -e "Please check project folder path and genetic code."
	exit 1
}

if test -f $FNA_PATH
then
	echo "-Detected assembly fna: $FNA_PATH"
	echo "-Assembly file is selected."
else
	echo "-Cannot found assembly fna file."
	echo "-Please provide proper assembly fna file."
	HELP
fi
echo "-Used assembly fna: $FNA_PATH"

if test -d $FOLDER_PATH
then
	echo -e \\n"Root directory check ... OK"
else
	echo -e \\n"Root directory is not exist. Please provide proper root directory."
	HELP
fi

if test -f $FNA_PATH
then
	echo -e "Assembly fna check ... OK"
else
	echo -e \\n"Assembly fna is not exist. Please provide proper assembly fna file."
	HELP
fi

if test -d $FOLDER_PATH/prodigal
then
	echo -e "Prodigal directory already exists."
else
	mkdir $FOLDER_PATH/prodigal
	echo -e "Prodigal directory was generated."
fi

if test -f $TOOL_PATH
then
	echo -e "Prodigal is exists."
else
	echo -e \\n"Prodigal is not exist. Please provide proper Prodigal path."
	HELP
fi

now=$(date)
echo -e \\n"START : Prodigal"
echo -e "TIME  : $now\n"

cd $FOLDER_PATH/prodigal
$TOOL_PATH -g $G_CODE -m -f gff -i $FNA_PATH -o $FOLDER_PATH/prodigal/Prodigal_output.gff

now=$(date)
echo -e \\n"END   : Prodigal"
echo -e "TIME  : $now\n"



