#!/bin/bash

FOLDER_PATH=$1
FILE_f=$2
G_CODE=$3
KINGDOM=$4
FOLDER_NAME=$5
PROJECT_NAME=$6
BUSCO_DB=$7
EMAILADDR=$8
R_HOME="/home/pCAPS/scripts/run"

echo "Ribosomal RNA prediction [1/12]" >> $FOLDER_PATH/temp/process.log

echo "********** RNAmmer **********" >> $FOLDER_PATH/annolog/rnammer.log
$R_HOME/01_run_rnammer.sh $KINGDOM $FOLDER_PATH &>> $FOLDER_PATH/annolog/rnammer.log

echo "Transfer RNA prediction [2/12]" >> $FOLDER_PATH/temp/process.log

echo "********** tRNAscan-SE **********" >> $FOLDER_PATH/annolog/trnascan.log
$R_HOME/02_run_trnascanse.sh -r $FOLDER_PATH &>> $FOLDER_PATH/annolog/trnascan.log

echo "Gene Prediction 1 [3/12]" >> $FOLDER_PATH/temp/process.log

echo "********** Prodigal **********" >> $FOLDER_PATH/annolog/prodigal.log
$R_HOME/03_run_prodigal_single.sh $FOLDER_PATH $G_CODE&>> $FOLDER_PATH/annolog/prodigal.log

echo "Gene Prediction 2 [4/12]" >> $FOLDER_PATH/temp/process.log

echo "********** GenemarkS **********" >> $FOLDER_PATH/annolog/genemarks.log
$R_HOME/04_run_genemarks_long.sh -r $FOLDER_PATH -g $G_CODE &>> $FOLDER_PATH/annolog/genemarks.log

echo "Filtering CDS [5/12]" >> $FOLDER_PATH/temp/process.log

echo "********** Filtering **********" >> $FOLDER_PATH/annolog/filtering.log
$R_HOME/05_filtering_cds.sh -r $FOLDER_PATH &>> $FOLDER_PATH/annolog/filtering.log

echo "Gene annotation [6/12]" >> $FOLDER_PATH/temp/process.log

echo "********** BLASTp(DB:Uniref90) **********" >> $FOLDER_PATH/annolog/blastp.log
$R_HOME/06_run_blastp.sh -r $FOLDER_PATH &>> $FOLDER_PATH/annolog/blastp.log

echo "KEGG Ortholog analysis [7/12]" >> $FOLDER_PATH/temp/process.log

echo "********** KEGG Ortholog analysis **********" >> $FOLDER_PATH/annolog/kegg.log

$R_HOME/07_run_kegg.sh $FOLDER_PATH &>> $FOLDER_PATH/annolog/kegg.log

echo "Protein domain analysis [8/12]" >> $FOLDER_PATH/temp/process.log

echo "********** InterProScan **********" >> $FOLDER_PATH/annolog/iprscan.log
$R_HOME/08_run_iprscan.sh -r $FOLDER_PATH -f $FOLDER_PATH/gff/re_tagged.faa &>> $FOLDER_PATH/annolog/iprscan.log

echo "Making result file [9/12]" >> $FOLDER_PATH/temp/process.log

echo "********** Annotation **********" >> $FOLDER_PATH/annolog/makegff.log
$R_HOME/09_annotate_gff.sh -r $FOLDER_PATH $FILE_f &>> $FOLDER_PATH/annolog/makegff.log

echo "Genome completeness test [10/12]" >> $FOLDER_PATH/temp/process.log

echo "********** BUSCO_v1.22 **********" >> $FOLDER_PATH/annolog/busco.log
$R_HOME/10_run_busco.sh $FOLDER_PATH $BUSCO_DB &>> $FOLDER_PATH/annolog/busco.log

echo "Make annotation report [11/12]" >> $FOLDER_PATH/temp/process.log

echo "********** Write annotation report **********" >> $FOLDER_PATH/annolog/writereport.log
python $R_HOME/11_make_info.py $FOLDER_NAME 2>> $FOLDER_PATH/annolog/writereport.log

echo "Launching JBrowser [12/12]" >> $FOLDER_PATH/temp/process.log

echo "********** JBrowse for visualization **********" >> $FOLDER_PATH/annolog/jbrowse.log
$R_HOME/12_run_jbrowse.sh $FOLDER_PATH $PROJECT_NAME &>> $FOLDER_PATH/annolog/jbrowse.log

echo "********** Send alert mail to user **********" &>> $FOLDER_PATH/annolog/mailing.log
$R_HOME/13_send_mail.sh $FOLDER_NAME $EMAILADDR &>> $FOLDER_PATH/annolog/mailing.log

echo "You can download result files!" >> $FOLDER_PATH/temp/process.log
