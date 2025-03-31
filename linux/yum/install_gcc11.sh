#!/bin/bash


install_gcc11() {
    echo_log_info "安装gcc11..."
    cat > /etc/yum.repos.d/CentOS-SCLo-scl.repo <<'EOF'
[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo
#baseurl=http://mirror.centos.org/centos/7/sclo/$basearch/rh/
#mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-sclo
baseurl=http://mirrors.aliyun.com/centos/7/sclo/x86_64/rh/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
EOF

    yum clean all && yum makecache && yum install -y devtoolset-11-gcc*
    mv /usr/bin/gcc /usr/bin/gcc-4.8.5
    ln -s /opt/rh/devtoolset-11/root/bin/gcc /usr/bin/gcc
    mv /usr/bin/g++ /usr/bin/g++-4.8.5
    ln -s /opt/rh/devtoolset-11/root/bin/g++ /usr/bin/g++

    gcc --version
}


install_gcc11