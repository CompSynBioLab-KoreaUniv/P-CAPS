#!/bin/bash

#Initialize variables to default values
opt_rootdir=opt_r
opt_in_gff=not_selected
opt_in_faa=not_selected
opt_in_blt=not_selected
python_code_dir=/home/pCAPS/scripts/others
uniref_path=/home/pCAPS/db/uniref90.fasta

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
while getopts :r:f:b:g:h FLAG; do
    case $FLAG in
        r)  #set option "r"
            opt_rootdir=$OPTARG
            echo "-Used root directory: $OPTARG"
            ;;
        f)  #set option "f"
            opt_in_faa=$OPTARG
            ;;
        g)  #set option "g"
            opt_in_gff=$OPTARG
            ;;
        b)  #set option "b"
            opt_in_blt=$OPTARG
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

selected_gff=sel_gff
if [ $opt_in_gff = not_selected ]
then
    echo -e "-Gene prediction gff file is not selected. Detecting default gff file ..."
    default_gff=$(readlink -f $opt_rootdir)/gff/re_tagged.gff
    if test -f $default_gff
    then
        echo "-Detected default gff: $default_gff"
        selected_gff=$default_gff
    else
        echo "-Cannot found default gene prediction gff file."
        echo "-Please provide proper gene prediction gff file."
        HELP
    fi
else
    echo -e "-GFF file is selected."
    selected_gff=$opt_in_gff
fi

selected_faa=sel_faa
if [ $opt_in_faa = not_selected ]
then
    echo -e "-Protein faa file is not selected. Detecting default faa file ..."
    default_faa=$(readlink -f $opt_rootdir)/gff/re_tagged.faa
    if test -f $default_faa
    then
        echo "-Detected default faa: $default_faa"
        selected_faa=$default_faa
    else
        echo "-Cannot found default protein faa file."
        echo "-Please provide proper protein faa file."
        HELP
    fi
else
    echo -e "-Protein faa file is selected."
    selected_faa=$opt_in_faa
fi

selected_blt=sel_blt
if [ $opt_in_blt = not_selected ]
then
    echo -e "-Blastp output file is not selected. Detecting default output file ..."
    default_blt=$(readlink -f $opt_rootdir)/blastp/blastp_output.tbl
    if test -f $default_blt
    then
        echo "-Detected default blastp output: $default_blt"
        selected_blt=$default_blt
    else
        echo "-Cannot found default blastp output file."
        echo "-Please provide proper blastp output file."
        HELP
    fi
else
    echo -e "-Blastp output file is selected."
    selected_blt=$opt_in_blt
fi

echo "-Used gff file: $selected_gff"
echo "-Used faa file: $selected_faa"
echo "-Used blastp output file: $selected_blt"

#Convert to absolute path
abs_rootdir=$(readlink -f $opt_rootdir)
abs_gff=$(readlink -f $selected_gff)
abs_faa=$(readlink -f $selected_faa)
abs_blt=$(readlink -f $selected_blt)

#Test inputs
if test -d $abs_rootdir
then
    echo -e \\n"Root directory check ... OK"
else
    echo -e \\n"Root directory is not exist. Please provide proper root directory."
    HELP
fi            
if test -f $abs_gff
then
    echo -e "Gene prediction gff check ... OK"
else
    echo -e \\n"Gene prediction gff is not exist. Please provide proper gene prediction gff file."
    HELP
fi
if test -f $abs_faa
then
    echo -e "Protein faa check ... OK"
else
    echo -e \\n"Protein faa is not exist. Please provide proper protein faa file."
    HELP
fi
if test -f $abs_blt
then
    echo -e "Blastp output check ... OK"
else
    echo -e \\n"Blastp output file is not exist. Please provide proper blastp output file."
    HELP
fi

#Test querydir
if test -d $abs_rootdir/gff
then
    echo -e "gff direcotry already exists."
else
    mkdir $abs_rootdir/gff
    echo -e "gff directory was generated."
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
echo -e \\n"START : Annotate gffs from gene prediction and blastp output"
echo -e "TIME  : $now\n"

cd $abs_rootdir/blastp
python $python_code_dir/annotate_gff.py -r $abs_rootdir -g $abs_gff -f $abs_faa -u $uniref_path
python $python_code_dir/decorate_gff.py -r $abs_rootdir -g $abs_rootdir/gff/re_tagged_uniref90_annotated.gff -t $abs_rootdir/trnascanse/tRNAscan_output.gff -u $abs_rootdir/rnammer/rnammer_output.gff
#python $python_code_dir/add_iprscan.py $abs_rootdir/fully_decorated.gff $abs_rootdir/iprscan/iprscan_output.tsv
python $python_code_dir/gff_to_genbank.py $abs_rootdir/fully_decorated.gff $abs_rootdir/inputseq.fna

now=$(date)
echo -e \\n"END   : Annotate gffs from gene prediction and blastp output"
echo -e "TIME  : $now\n"


