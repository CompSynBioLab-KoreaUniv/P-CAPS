#!/bin/bash

#Initialize variables to default values
opt_rootdir=opt_r
opt_in_gff_1=not_selected
opt_in_gff_2=not_selected
python_code_dir=/home/pCAPS/scripts/others
first_tag=First
second_tag=Second

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

#Get options
while getopts :r:f:g:h FLAG; do
    case $FLAG in
        r)  #set option "r"
            opt_rootdir=$OPTARG
            echo "-Used root directory: $OPTARG"
            ;;
        f)  #set option "f"
            opt_in_gff_1=$OPTARG
            ;;
        g)  #set option "g"
            opt_in_gff_2=$OPTARG
            ;;
        h)  #show help
            HELP
            ;;
        \?) #unrecognized option - show hlep
            echo -e \\n"Option -$OPTARG not allowed."
            HELP
    esac
done

#GFF file selection

selected_gff_1=sel_gff_1
if [ $opt_in_gff_1 = not_selected ]
then
    echo -e "-First gff file is not selected. Detecting default genemarks gff file ..."
    default_gff_1=$(readlink -f $opt_rootdir)/genemarks/GeneMarkS_output.gff
    if test -f $default_gff_1
    then
        echo "-Detected default genemarks gff: $default_gff_1"
        selected_gff_1=$default_gff_1
        first_tag="GeneMarkS"
    else
        echo "-Cannot found default gene prediction gff file."
        echo "-Please provide proper gene prediction gff file."
        HELP
    fi
else
    echo -e "-First gff file is selected."
    selected_gff_1=$opt_in_gff_1
fi

selected_gff_2=sel_gff_2
if [ $opt_in_gff_2 = not_selected ]
then
    echo -e "-Second gff file is not selected. Detecting default prodigal gff file ..."
    default_gff_2=$(readlink -f $opt_rootdir)/prodigal/Prodigal_output.gff
    if test -f $default_gff_2
    then
        echo "-Detected default prodigal gff: $default_gff_2"
        selected_gff_2=$default_gff_2
        second_tag="Prodigal"
    else
        echo "-Cannot found default gene prediction gff file."
        echo "-Please provide proper gene prediction gff file."
        HELP
    fi
else
    echo -e "-Second gff file is selected."
    selected_gff_2=$opt_in_gff_2
fi

echo "-Used first gff file: $selected_gff_1"
echo "-Used second gff file: $selected_gff_2"

#Convert to absolute path
abs_rootdir=$(readlink -f $opt_rootdir)
abs_gff_1=$(readlink -f $selected_gff_1)
abs_gff_2=$(readlink -f $selected_gff_2)

#Test inputs
if test -d $abs_rootdir
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi            
if test -f $abs_gff_1
then
    echo -e "First gff check ... OK"
else
    echo -e \\n"First gff is not exist. Please provide proper gene prediction gff file."
    HELP
fi
if test -f $abs_gff_2
then
    echo -e "Second gff check ... OK"
else
    echo -e \\n"Second gff is not exist. Please provide proper gene prediction gff file."
    HELP
fi

#Test querydir
if test -d $abs_rootdir/gff
then
    echo -e "GFF direcotry already exists."
else
    mkdir $abs_rootdir/gff
    echo -e "GFF directory was generated."
fi

#Test python code dir
if test -d $python_code_dir
then
    echo -e "python code directory is exists."
else
    echo -e \\n"python code directory is not exist. Please provide proper python code directory."
    HELP
fi

#Compound gff
now=$(date)
echo -e \\n"START : Filtering gffs from gene prediction"
echo -e "TIME  : $now\n"

cd $abs_rootdir/gff
python $python_code_dir/compound_gff.py -z new -a $abs_gff_1 -x $first_tag -b $abs_gff_2 -y $second_tag
python $python_code_dir/filter_all_model_gff.py -a Merged_CDS.gff -f $abs_rootdir/inputseq.fna
python $python_code_dir/translate.py -g Merged_CDS_filtered.gff -f $abs_rootdir/inputseq.fna
python $python_code_dir/re_tag.py -g Merged_CDS_filtered.gff -f protein_output.fasta -t QUERY

now=$(date)
echo -e \\n"END   : Filtering gffs from gene prediction"
echo -e "TIME  : $now\n"


