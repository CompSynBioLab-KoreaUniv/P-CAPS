#!/bin/bash

PROJECT_PATH=$1
FNA_FILE=$2
HOME_PATH="/home/pCAPS"
PROBUILD_PATH="/YOURTOOLPATH/gmsuite/probuild"
TEMP_PATH="$HOME_PATH/docs/temp"

$PROBUILD_PATH --gc --seq $PROJECT_PATH/$FNA_FILE > $TEMP_PATH/gc.txt

GC=$(awk -F ' ' '{print $3}' $TEMP_PATH/gc.txt)

rm $TEMP_PATH/gc.txt

echo $GC
