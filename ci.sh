#/bin/bash
set -ex
cd ${GITHUB_WORKSPACE}
docker pull centos:7
docker build -t nginx-build .
docker run --name nginx-build nginx-build sh -x /file/run.sh
docker cp nginx-build:/root/rpmbuild/RPMS/x86_64/ ./