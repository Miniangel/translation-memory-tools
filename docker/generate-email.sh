#!/bin/bash
ROOT="$1"
TARGET_DIR="$2"
secs="$3"


INTERMEDIATE_PO=$PUBLIC/translation-memories/po
BACKUP_DIR=$PUBLIC/previous
cd $ROOT/tm-git/src
python compare_sets.py -s  $BACKUP_DIR -t $INTERMEDIATE_PO > report.txt
ls -h -s -S  $TARGET_DIR/quality/*.html >> report.txt
cat builder-error.log >> report.txt
printf 'TIME. Total execution time %dh:%dm:%ds\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) >> report.txt
python ../docker/send-email.py
