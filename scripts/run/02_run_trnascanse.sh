#!/bin/bash

#Initialize variables to default values
opt_rootdir=opt_r
opt_fna=opt_f
tool_path=/YOURTOOLPATH/trnascan/bin/tRNAscan-SE
tool_bin_path=/YOURTOOLPATH/trnascan/bin
python_code_dir=/home/pCAPS/scripts/others

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
while getopts :r:f:h FLAG; do
    case $FLAG in
        r)  #set option "r"
            opt_rootdir=$OPTARG
            echo "-Used root directory: $OPTARG"
            ;;
        f)  #set option "f"
            opt_fna=$OPTARG
            ;;
        h)  #show help
            HELP
            ;;
        \?) #unrecognized option - show hlep
            echo -e \\n"Option -$OPTARG not allowed."
            HELP
    esac
done

#Assembly file selection

selected_fna=sel_f
if [ $opt_fna = opt_f ]
then
    echo -e "-Assembly file is not selected. Detecting default assembly file ..."
    default_fna=$(readlink -f $opt_rootdir)/inputseq.fna
    if test -f $default_fna
    then
        echo "-Detected default assembly fna: $default_fna"
        selected_fna=$default_fna
    else
        echo "-Cannot found default assembly fna file."
        echo "-Please provide proper assembly fna file."
        HELP
    fi
else
    echo -e "-Assembly file is selected."
    selected_fna=$opt_fna
fi
echo "-Used assembly fna: $selected_fna"

#Convert to absolute path
abs_rootdir=$(readlink -f $opt_rootdir)
abs_fna=$(readlink -f $selected_fna)

#Test inputs
if test -d $abs_rootdir
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi            
if test -f $abs_fna
then
    echo -e "Assembly fna check ... OK"
else
    echo -e \\n"Assembly fna is not exist. Please provide proper assembly fna file."
    HELP
fi

#Test querydir
if test -d $abs_rootdir/trnascanse
then
    echo -e "tRNAscan-SE direcotry already exists."
else
    mkdir $abs_rootdir/trnascanse
    echo -e "tRNAscan-SE directory was generated."
fi

#Test tRNAscan-SE
if test -f $tool_path
then
    echo -e "tRNAscan-SE is exists."
else
    echo -e \\n"tRNAscan-SE is not exist. Please provide proper tRNAscan-SE path."
    HELP
fi

#Run tRNAscan-SE

now=$(date)
echo -e \\n"START : tRNAscan-SE"
echo -e "TIME  : $now\n"

cd $tool_bin_path
$tool_path -B -q -m $abs_rootdir/trnascanse/trnascanse.log -o $abs_rootdir/trnascanse/trnascanse_output.tbl $abs_fna

$python_code_dir/tRNAScan_SE_to_gff3.pl --input=$abs_rootdir/trnascanse/trnascanse_output.tbl > $abs_rootdir/trnascanse/tRNAscan_output.gff

cd $abs_rootdir/trnascanse
python $python_code_dir/translate_t.py -g $abs_rootdir/trnascanse/tRNAscan_output.gff -f $abs_fna

now=$(date)
echo -e \\n"END   : tRNAscan-SE"
echo -e "TIME  : $now\n"


