#!/bin/bash

PID=$1
EMAILADDR=$2
PYTHON_PATH="/home/pCAPS/scripts/others"

$PYTHON_PATH/mail_messege.sh $PID | mail -s "Announcement from P-CAPS" $EMAILADDR

