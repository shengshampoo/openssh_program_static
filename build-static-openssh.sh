
#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# openssh
cd $WORKSPACE
hh=$(curl -s https://www.openssh.org/releasenotes.html | grep -Po '\K[0-9.]{4}p1+' | head -n 1)
curl -s https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$hh.tar.gz | tar x --gzip
cd openssh-$hh
./configure --prefix=/usr/local/opensshmm --sysconfdir=/etc/ssh --without-pam --with-privsep-path=/var/lib/sshd --with-pid-dir=/var/run --with-mantype=man --with-libedit --with-ldns
sed -i 's@LDFLAGS=@LDFLAGS=-static -no-pie -s @g'  ./Makefile
sed -i 's@LIBEDIT=-ledit@LIBEDIT=-ledit -lncurses -ltinfo@g'  ./Makefile
make
make install

# liboqs
cd $WORKSPACE
git clone https://github.com/open-quantum-safe/liboqs
cd liboqs
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF -DOQS_BUILD_ONLY_LIB=ON -DOQS_ENABLE_KEM_HQC=ON ..
ninja
ninja install

# liboqs_openssh
cd $WORKSPACE
git clone -b OQS-v10 https://github.com/open-quantum-safe/openssh.git
cd openssh
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/systemd-socket-activation.patch | patch -p1
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/user-group-modes.patch | patch -p1
autoreconf -i
./configure --prefix=/usr/local/liboqs_opensshmm --sysconfdir=/etc/ssh/oqsssh \
 --without-pam --with-privsep-path=/var/lib/sshd --with-pid-dir=/var/run/liboqs \
 --with-mantype=man --with-libedit --with-ldns --with-liboqs-dir=/usr
sed -i 's@LDFLAGS=@LDFLAGS=-static -no-pie -s @g'  ./Makefile
sed -i 's@LIBEDIT=-ledit@LIBEDIT=-ledit -lncurses -ltinfo@g'  ./Makefile
make
make install

# HPN_SSH openssh
cd $WORKSPACE
git clone https://github.com/rapier1/hpn-ssh
cd hpn-ssh
cp hpnssh.1 ssh.1 && cp hpnssh_config.5 ssh_config.5
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/systemd-socket-activation.patch | patch -p1
curl -sL https://salsa.debian.org/ssh-team/openssh/-/raw/master/debian/patches/user-group-modes.patch | patch -p1
mv ssh.1 hpnssh.1 && mv ssh_config.5 hpnssh_config.5
autoreconf -f -i
./configure --prefix=/usr/local/hpnsshmm --sysconfdir=/etc/ssh --without-pam --with-privsep-path=/var/lib/sshd --with-pid-dir=/var/run --with-mantype=man --with-libedit --with-ldns
sed -i 's@LDFLAGS=@LDFLAGS=-static -no-pie -s @g'  ./Makefile
sed -i 's@LIBEDIT=-ledit@LIBEDIT=-ledit -lncurses -ltinfo@g'  ./Makefile
make
addgroup hpnsshd
adduser --disabled-password hpnsshd -G hpnsshd
make install


cd /usr/local
tar vcJf ./opensshmm.tar.xz opensshmm
tar vcJf ./liboqs_opensshmm.tar.xz liboqs_opensshmm
tar vcJf ./hpnsshmm.tar.xz hpnsshmm

mv ./[hlo]*sshmm.tar.xz /work/artifact/
