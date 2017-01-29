#!/bin/bash

cd /home/pCAPS/scripts/kegganno

wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz

gunzip idmapping.dat.gz

grep $'\tKO\t' idmapping.dat > keggmapping.dat

grep "UniRef90_" idmapping.dat > uni90mapping.dat


