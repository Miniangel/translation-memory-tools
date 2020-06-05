#!/bin/bash
DIR="$1" # root /srv/dev
DIR_TMT_GIT="$2" # /srv/dev/tm-git - working directory
PUBLISH_WEBDOCKER=/srv/web-docker
PRESERVE_CROSSEXECS=/srv/tmt-files
PUBLIC=/srv/public-data

# Run unit tests
#cd $DIR_TMT_GIT
#nosetests
#RETVAL=$?
#if [ $RETVAL -ne 0 ]; then
#    echo "Aborting deployment. Unit tests did not pass"
#    exit
#fi


# RSA key
mkdir -p ~/.ssh && chmod 0700 ~/.ssh

if [[ -n "${PRIVATE_KEY}" ]]; then
    echo "$PRIVATE_KEY" > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
else
    echo "No private key found"
fi

eval `ssh-agent -s` && ssh-add -k ~/.ssh/id_rsa
ssh-keyscan -p 3333 -H gitlab.softcatala.org >> ~/.ssh/known_hosts 
git config --global user.email "jmas@softcatala.org"
git config --global user.name "TMT builder"

git clone ssh://git@gitlab.softcatala.org:3333/github/translation-memory-tools-files.git $PRESERVE_CROSSEXECS

# Copy cross execs
cp $PRESERVE_CROSSEXECS/glossary.db3 $DIR_TMT_GIT/src/glossary.db3
cp $PRESERVE_CROSSEXECS/statistics.db3 $DIR_TMT_GIT/src/statistics.db3

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
/bin/bash generate-tm.sh $DIR $PRESERVE_CROSSEXECS 2> $DIR_TMT_GIT/generate-errors.log
echo Generate terminology
/bin/bash generate-terminology.sh $DIR 2> $DIR_TMT_GIT/terminology-errors.log
echo Generate Iso lists
/bin/bash generate-isolists.sh $DIR 2> $DIR_TMT_GIT/iso-lists-errors.log
echo Generate Quality
/bin/bash generate-quality.sh $DIR 2> $DIR_TMT_GIT/quality-errors.log
/bin/bash deploy-docker.sh $DIR $PUBLISH_WEBDOCKER

# Copy cross execs
cp $DIR_TMT_GIT/src/glossary.db3 $PRESERVE_CROSSEXECS/glossary.db3 
cp $DIR_TMT_GIT/src/statistics.db3 $PRESERVE_CROSSEXECS/statistics.db3 


# Deploy
cd $PRESERVE_CROSSEXECS
git add *
git commit -a -m "File update"
git push
echo Completed!
