#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# liboqs
cd $WORKSPACE
git clone https://github.com/open-quantum-safe/liboqs
cd liboqs
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local/liboqs -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=ON -DOQS_ENABLE_KEM_HQC=ON ..
ninja
ninja install

# liboqs_openssh
cd $WORKSPACE
git clone -b OQS-v10 https://github.com/open-quantum-safe/openssh.git
cd openssh
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/systemd-socket-activation.patch | patch -p1
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/user-group-modes.patch | patch -p1
export LDFLAGS="${LDFLAGS} -Wl,-rpath,/usr/local/liboqs/lib"
export PKG_CONFIG_PATH=/usr/local/liboqs/lib/pkgconfig:$PKG_CONFIG_PATH
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -Wno-implicit-function-declaration"
autoreconf -i
./configure --prefix=/usr/local/liboqs_openssh --with-pam --with-selinux --with-privsep-path=/var/lib/sshd/ \
  --sysconfdir=/etc/ssh --with-libedit --with-liboqs-dir=/usr/local/liboqs --with-pid-dir=/var/run/liboqs/
make
useradd --system --shell /usr/sbin/nologin --comment="Privilege separated SSH User" --home=/run/sshd sshd
make install

# HPN_SSH openssh
cd $WORKSPACE
git clone https://github.com/rapier1/hpn-ssh
cd hpn-ssh
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/systemd-socket-activation.patch | patch -p1
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/user-group-modes.patch | sed -e "s@ssh.1@hpnssh.1@g" | sed -e "s@ssh_config.5@hpnssh_config.5@g" | patch -p1
autoreconf -f -i
./configure --prefix=/usr/local/hpnssh --with-pam --with-selinux --with-privsep-path=/var/lib/sshd/ --sysconfdir=/etc/ssh --with-libedit
make
useradd --system --shell /usr/sbin/nologin --comment="Privilege separated HPNSSH User" --home=/run/hpnsshd hpnsshd
make install
