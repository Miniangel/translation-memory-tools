pushd ../
docker build -t tmt-builder . -f docker/dockerfile-builder
popd

