#!/bin/bash

#Initialize variables to default values
opt_rootdir=opt_r
opt_faa=opt_f
tool_path=/YOURTOOLPATH/interproscan-5.21-60.0/interproscan.sh

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
            opt_faa=$OPTARG
            ;;
        h)  #show help
            HELP
            ;;
        \?) #unrecognized option - show hlep
            echo -e \\n"Option -$OPTARG not allowed."
            HELP
    esac
done

#Protein file selection

selected_faa=sel_f
if [ $opt_faa = opt_f ]
then
    echo -e "-Protein sequence file is not selected. Detecting default protein faa file ..."
    default_faa=$(readlink -f $opt_rootdir)/gff/re_tagged.faa
    if test -f $default_faa
    then
        echo "-Detected default protein faa: $default_faa"
        selected_faa=$default_faa
    else
        echo "-Cannot found default protein faa file."
        echo "-Please provide proper protein faa file."
        HELP
    fi
else
    echo -e "-Protein file is selected."
    selected_faa=$opt_faa
fi
echo "-Used protein faa: $selected_faa"

#Convert to absolute path
abs_rootdir=$(readlink -f $opt_rootdir)
abs_faa=$(readlink -f $selected_faa)

#Test inputs
if test -d $abs_rootdir
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi            
if test -f $abs_faa
then
    echo -e "Protein faa check ... OK"
else
    echo -e \\n"Protein faa is not exist. Please provide proper protein faa file."
    HELP
fi

#Test querydir
if test -d $abs_rootdir/iprscan
then
    echo -e "IPRscan direcotry already exists."
else
    mkdir $abs_rootdir/iprscan
    echo -e "IPRscan directory was generated."
fi

#Test IPRscan
if test -f $tool_path
then
    echo -e "IPRscan is exists."
else
    echo -e \\n"IPRscan is not exist. Please provide proper IPRscan path."
    HELP
fi

#Run IPRscan

now=$(date)
echo -e \\n"START : IPRscan"
echo -e "TIME  : $now\n"

cd $abs_rootdir/iprscan/

$tool_path -i $abs_faa -appl Pfam,phobius,tmhmm,signalp -f gff3 -o $abs_rootdir/iprscan/iprscan_output.gff 

now=$(date)
echo -e \\n"END   : IPRscan"
echo -e "TIME  : $now\n"


