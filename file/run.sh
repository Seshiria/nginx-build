#!/bin/bash
if [ -f /file/install.so ];then
    printf 镜像开始初始化
    source /file/install.so
    mv /file/install.so /file/install
    exit 0
fi
mkdir -p ~/build/
cd ~/build/
rm -rf ~/build/*
#获取nginx源码
apt update
NGINX_VERSION=$(apt list nginx |grep nginx |awk -F ' ' '{print $2}'|awk -F '~' '{print $1}')
NGINX_VERSION_MAIN=$(echo "$NGINX_VERSION" |awk -F '-' '{print $1}')
apt source nginx
cd nginx-"${NGINX_VERSION_MAIN}"

. /file/configure

dpkg-buildpackage -uc -b
#发布文件
cd ~/build/
mkdir release
mv *.deb release/
