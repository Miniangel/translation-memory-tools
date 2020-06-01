#!/bin/bash
DIR="$1"
DIR_TMT_GIT="$2"
PUBLIC=/srv/public-data
#DEPLOY_DIR=/srv/web/recursos-dev
#PREPROD_DEPLOY_DIR=/web/recursos-preprod

echo $PRIVATE_KEY
mkdir -p ~/.ssh && chmod 0700 ~/.ssh
echo $PRIVATE_KEY > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
eval `ssh-agent -s` && ssh-add -k ~/.ssh/id_rsa
ssh-keyscan -p 3333 -H gitlab.softcatala.org >> ~/.ssh/known_hosts 
git config --global user.email "jmas@softcatala.org"
git config --global user.name "TMT builder"


cd /srv
git clone ssh://git@gitlab.softcatala.org:3333/github/translation-memory-tools-files.git public-data

cd public-data
if [[ -n "${TRANSIFEX_USER}" && -n "${TRANSIFEX_PASSWORD}" ]]; then
    python $DIR_TMT_GIT/docker/credentials/transifex.py
else
    echo "Removing Transifex projects"
    grep -l "type.*transifex" cfg/projects/*.json  | xargs rm -f
fi

if [[ -n "${ZANATA_PROJECT_1}" && -n "${ZANATA_USER_1}"  && -n "${ZANATA_TOKEN_1}" ]]; then
    python $DIR_TMT_GIT/docker/credentials/zanata.py $DIR_TMT_GIT/cfg/credentials/
else
    echo "Removing Zentata projects"
    grep -l "type.*zanata" cfg/projects/*.json  | xargs rm -f


# Build
cd $DIR_TMT_GIT/deployment 
echo Generate memories
/bin/bash generate-tm.sh $DIR $PUBLIC 2> $DIR_TMT_GIT/generate-errors.log
echo Generate terminology
/bin/bash generate-terminology.sh $DIR 2> $DIR_TMT_GIT/terminology-errors.log
/bin/bash generate-isolists.sh $DIR 2> $DIR_TMT_GIT/iso-lists-errors.log
echo Generate Quality
/bin/bash generate-quality.sh $DIR 2> $DIR_TMT_GIT/quality-errors.log
/bin/bash deploy-docker.sh $DIR $PUBLIC

# Deploy
cd $PUBLIC
git add *
git commit -a -m "File update"
git push
echo Completed!
