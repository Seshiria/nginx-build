#/bin/bash
set -ex
cd ${GITHUB_WORKSPACE}
docker build -t nginx-build .
docker run --name nginx-build nginx-build bash -x /file/run.sh
docker cp nginx-build:/root/build/release/ ./