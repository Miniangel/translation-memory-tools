#!/bin/bash
DIR="$1" # root /srv/dev
DIR_TMT_GIT="$2" # /srv/dev/tm-git - working directory
PUBLISH_WEBDOCKER=/srv/web-docker
PRESERVE_CROSSEXECS=/srv/tmt-files

# Run unit tests
#cd $DIR_TMT_GIT
#nosetests
#RETVAL=$?
#if [ $RETVAL -ne 0 ]; then
#    echo "Aborting deployment. Unit tests did not pass"
#    exit
#fi

ls $PRESERVE_CROSSEXECS

# Copy cross execs
cp $PRESERVE_CROSSEXECS/statistics.db3 $DIR_TMT_GIT/src/statistics.db3
if [[ -e  $PRESERVE_CROSSEXECS/translation-memories/ ]]; then
    mkdir -p $DIR/translation-memories/
    cp -r $PRESERVE_CROSSEXECS/translation-memories/* $DIR/translation-memories/
fi

if [[ -n "${TRANSIFEX_USER}" && -n "${TRANSIFEX_PASSWORD}" ]]; then
    python $DIR_TMT_GIT/docker/credentials/transifex.py
else
    echo "Removing Transifex projects"
    grep -l "type.*transifex" cfg/projects/*.json  | xargs rm -f
fi

if [[ -n "${ZANATA_PROJECT_1}" && -n "${ZANATA_USER_1}"  && -n "${ZANATA_TOKEN_1}" ]]; then
    python $DIR_TMT_GIT/docker/credentials/zanata.py $DIR_TMT_GIT/cfg/credentials/
else
    echo "Removing Zenata projects"
    grep -l "type.*zanata" cfg/projects/*.json  | xargs rm -f
fi

# Build
cd $DIR_TMT_GIT/deployment 
echo Generate memories
/bin/bash generate-tm.sh $DIR $DIR 2> $DIR_TMT_GIT/generate-errors.log
echo Generate terminology
/bin/bash generate-terminology.sh $DIR 2> $DIR_TMT_GIT/terminology-errors.log
echo Generate Iso lists
/bin/bash generate-isolists.sh $DIR 2> $DIR_TMT_GIT/iso-lists-errors.log
echo Generate Quality
/bin/bash generate-quality.sh $DIR 2> $DIR_TMT_GIT/quality-errors.log
/bin/bash deploy-docker.sh $DIR $PUBLISH_WEBDOCKER

# Copy cross execs
cp $DIR_TMT_GIT/src/statistics.db3 $PRESERVE_CROSSEXECS/statistics.db3 
mkdir -p $PRESERVE_CROSSEXECS/translation-memories
cp -r $DIR/translation-memories/* $PRESERVE_CROSSEXECS/translation-memories

