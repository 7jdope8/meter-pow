#!/bin/bash
PROJECT_NAME=meter-pow
VERSION=1.1.4

DOCKER_TAG=dfinlab/${PROJECT_NAME}:$VERSION
LATEST_TAG=dfinlab/${PROJECT_NAME}:latest
GIT_TAG=v$VERSION
TEMP_CONTAINER_NAME=${PROJECT_NAME}-temp
RELEASE_DIR=release/${PROJECT_NAME}-$VERSION-linux-amd64
RELEASE_TARBALL=${PROJECT_NAME}-$VERSION-linux-amd64.tar.gz
DEPENDENCY_TARBALL=${PROJECT_NAME}-$VERSION-linux-amd64-dependency.tar.gz

docker build -t $DOCKER_TAG .
docker tag $DOCKER_TAG $LATEST_TAG
docker run -d --name $TEMP_CONTAINER_NAME $DOCKER_TAG
echo "Brought up a temporary docker container"
mkdir -p $RELEASE_DIR/bin
docker cp $TEMP_CONTAINER_NAME:/usr/local/bin/bitcoind $RELEASE_DIR/bin/
docker cp $TEMP_CONTAINER_NAME:/usr/local/bin/bitcoin-cli $RELEASE_DIR/bin/
docker cp $TEMP_CONTAINER_NAME:/usr/local/bin/bitcoin-tx $RELEASE_DIR/bin/
docker cp $TEMP_CONTAINER_NAME:/usr/lib $RELEASE_DIR/
docker rm --force $TEMP_CONTAINER_NAME
echo "Removed the temporary docker container"


cd $RELEASE_DIR/bin && tar -zcf ../$RELEASE_TARBALL . && cd -
cd $RELEASE_DIR/lib && rm -R -- */ && tar -zcf ../$DEPENDENCY_TARBALL . && cd -
cp $RELEASE_DIR/$RELEASE_TARBALL release
cp $RELEASE_DIR/$DEPENDENCY_TARBALL release

rm -rf $RELEASE_DIR

github-release release --user dfinlab --repo btcpow \
    --tag ${GIT_TAG} --name "${GIT_TAG}" --pre-release
echo "Created release ${GIT_TAG}"

echo "Start upload release/${RELEASE_TARBALL}"
github-release upload --user dfinlab --repo btcpow \
    --tag ${GIT_TAG} --name "${RELEASE_TARBALL}" \
    --file release/$RELEASE_TARBALL

echo "Start upload release/${DEPENDENCY_TARBALL}"
github-release upload --user dfinlab  --repo btcpow \
    --tag ${GIT_TAG} --name "${DEPENDENCY_TARBALL}" \
    --file release/$DEPENDENCY_TARBALL
echo "Release uploaded, please check https://github.com/dfinlab/btcpow/releases"
