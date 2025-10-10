
#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# openssh
cd $WORKSPACE
hh=10.2p1
curl -s https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$hh.tar.gz | tar x --gzip
cd openssh-$hh
LDFLAGS="-static -no-pie -s" ./configure --prefix=/usr/local/opensshmm --sysconfdir=/usr/local/opensshmm/etc/ssh --without-pam --with-privsep-path=/usr/local/opensshmm/lib/sshd/ --with-pid-dir=/usr/local/opensshmm/run --with-mantype=man
make
make install

cd /usr/local
tar vcJf ./opensshmm.tar.xz opensshmm

mv ./opensshmm.tar.xz /work/artifact/
