pushd ../
docker build -t tmt-webapp . -f dockerfile-webapp
popd
docker image ls | grep tmt-webapp



