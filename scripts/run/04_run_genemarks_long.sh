#!/bin/bash

#Initialize variables to default values
opt_rootdir=opt_r
opt_fna=opt_f
opt_gcode=opt_g
tool_path_1=/YOURTOOLPATH/genemark_suite_linux_64/gmsuite/gmsn.pl
tool_path_2=/YOURTOOLPATH/genemark_suite_linux_64/gmsuite/gmhmmp
db_dir=/home/pCAPS/db
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
while getopts :r:f::g:h FLAG; do
    case $FLAG in
        r)  #set option "r"
            opt_rootdir=$OPTARG
            echo "-Used root directory: $OPTARG"
            ;;
        f)  #set option "f"
            opt_fna=$OPTARG
            ;;
   	g)  #set option "g"
	    opt_gcode=$OPTARG
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
if test -d $abs_rootdir/genemarks
then
    echo -e "Genemarks direcotry already exists."
else
    mkdir $abs_rootdir/genemarks
    echo -e "Genemarks directory was generated."
fi

#Test Geneamrks
if test -f $tool_path_1
then
    echo -e "Genemarks_gmsn.pl is exists."
else
    echo -e \\n"Genemarks_gmsn.pl is not exist. Please provide proper gmsn.pl path."
    HELP
fi
if test -f $tool_path_2
then
    echo -e "Genemarks_gmhmmp is exists."
else
    echo -e \\n"Genemarks_gmhmmp is not exist. Please provide proper gmhmmp path."
    HELP
fi

#Run Genemarks

now=$(date)
echo -e \\n"START : GeneMarkS"
echo -e "TIME  : $now\n"

cd $abs_rootdir/genemarks/

cp $abs_fna $abs_rootdir/genemarks.fna

sed -i s/">"/""/g $abs_rootdir/genemarks.fna

seqname=$(sed -n '1p' $abs_rootdir/genemarks.fna)

rm $abs_rootdir/genemarks.fna

$tool_path_1 --prok --format GFF3 --gcode $opt_gcode --output $abs_rootdir/genemarks/GeneMarkS_output.gff --name query $abs_fna > $abs_rootdir/genemarks/gmsn.log

mod_check=$(ls | grep -c "query_hmm_heuristic.mod")
if [ $mod_check = 1 ]
then
    echo "Query hmm.mod file was generated."
else
    echo "Query hmm.mod file was not generated. Default hmm.mod file will be used."
    cp $db_dir/default_hmm.mod $abs_rootdir/genemarks/query_hmm.mod
fi

#perl $python_code_dir/genemark2gff.pl -i $abs_rootdir/genemarks/query.lst -o $abs_rootdir/genemarks/genemarks_output_gff2.gff -n $seqname

#python $python_code_dir/genemark2gff3.py -i $abs_rootdir/genemarks/genemarks_output_gff2.gff

now=$(date)
echo -e \\n"END   : GeneMarkS"
echo -e "TIME  : $now\n"


