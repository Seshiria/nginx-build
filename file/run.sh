#!/bin/bash
if [ -x /file/install.so ];then
    printf 镜像开始初始化
    source /file/install.so
    mv /file/install.so /file/install
    exit 0
fi
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
cd ~/rpmbuild/SOURCES/
rm -rf ~/rpmbuild/SOURCES/*
#获取nginx源码
NGINX_VERSION=$(yum list nginx |grep nginx |awk -F ':' '{print $2}'|awk -F '-' '{print $1}')
cp /file/nginx-${NGINX_VERSION}-1.el7.ngx.src.rpm ./
#curl -O http://nginx.org/packages/centos/7/SRPMS/nginx-${NGINX_VERSION}-1.el7.ngx.src.rpm
rpm2cpio nginx-${NGINX_VERSION}-1.el7.ngx.src.rpm |cpio -dvi
#hook nginx.spec 文件
#hook %setup宏
#sed -i '/cp %{SOURCE2} ./a\. /file/hook.sh' nginx.spec
sed -i -e '/cp %{SOURCE2} ./a\mv ./configure ./configured \ncp /file/configure ./configure \nchmod +x ./configure' \
        -e '/%build/a\export BASE_CONFIGURE_ARGS=%{BASE_CONFIGURE_ARGS} \nexport WITH_CC_OPT="\%{WITH_CC_OPT}\" \nexport WITH_LD_OPT=\"%{WITH_LD_OPT}\"' \
            nginx.spec
rpmbuild -ba nginx.spec