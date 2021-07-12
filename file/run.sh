#!/bin/bash
if [ -f /file/install.so ];then
    printf 镜像开始初始化
    source /file/install.so
    mv /file/install.so /file/install
    exit 0
fi
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
cd ~/rpmbuild/SOURCES/
rm -rf ~/rpmbuild/SOURCES/*
#获取nginx源码
NGINX_VERSION=$(yum list nginx |grep nginx |awk -F ':' '{print $2}'|awk -F ' ' '{print $1}')
if [ -f /file/nginx-${NGINX_VERSION}.src.rpm ];then
    cp /file/nginx-${NGINX_VERSION}.src.rpm ./
else
    curl -O http://nginx.org/packages/centos/7/SRPMS/nginx-${NGINX_VERSION}.src.rpm
fi
rpm2cpio nginx-${NGINX_VERSION}.src.rpm |cpio -dvi
#hook nginx.spec 文件
#hook %setup宏
#sed -i '/cp %{SOURCE2} ./a\. /file/hook.sh' nginx.spec
if `grep -q "%autosetup" nginx.spec` ;then
    #nginx version 1.20.0 and up
    sed -i -e '/%autosetup -p1/a\mv ./configure ./configured \ncp /file/configure ./configure \nchmod +x ./configure\n#hockpoint' \
            -e '/%build/a\export BASE_CONFIGURE_ARGS=%{BASE_CONFIGURE_ARGS} \nexport WITH_CC_OPT="\%{WITH_CC_OPT}\" \nexport WITH_LD_OPT=\"%{WITH_LD_OPT}\"' \
                nginx.spec
elif `grep -q "%setup" nginx.spec ` ;then
    #nginx version 1.18.0 and lower
    sed -i -e '/cp %{SOURCE2} ./a\mv ./configure ./configured \ncp /file/configure ./configure \nchmod +x ./configure\n#hockpoint' \
        -e '/%build/a\export BASE_CONFIGURE_ARGS=%{BASE_CONFIGURE_ARGS} \nexport WITH_CC_OPT="\%{WITH_CC_OPT}\" \nexport WITH_LD_OPT=\"%{WITH_LD_OPT}\"' \
            nginx.spec
else
    echo "error:Unsupported nginx.spec, the following information may be useful"
    echo "--------------------------------------------"
    #cat nginx.spec
    echo "--------------------------------------------"
    exit 1
fi
#check
if `grep -q "#hockpoint" nginx.spec` ;then
    echo "hock point check is ok"
else
    echo "error: hock point not written"
    echo "Please check nginx.spec,the following information may be useful"
    echo "--------------------------------------------"
    cat nginx.spec
    echo "--------------------------------------------"
    exit 1
fi
rpmbuild -ba nginx.spec