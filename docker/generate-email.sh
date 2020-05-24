#!/bin/bash
ROOT="$1"
TARGET_DIR="$2"

INTERMEDIATE_PO=$PUBLIC/translation-memories/po
BACKUP_DIR=$PUBLIC/previous
cd $ROOT/tm-git/src
python compare_sets.py -s  $BACKUP_DIR -t $INTERMEDIATE_PO > report.txt
ls -h -s -S  $TARGET_DIR/quality/*.html >> report.txt
cd $ROOT/tm-git/src
cat builder-error.log >> report.txt


