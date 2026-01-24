
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
./configure --prefix=/usr/local/opensshmm --sysconfdir=/usr/local/opensshmm/etc/ssh --without-pam --with-privsep-path=/usr/local/opensshmm/lib/sshd/ --with-pid-dir=/usr/local/opensshmm/run --with-mantype=man --with-libedit --with-ldns
sed -i 's@LDFLAGS=@LDFLAGS=-static -no-pie -s @g'  ./Makefile
sed -i 's@LIBEDIT=-ledit@LIBEDIT=-ledit -lncurses -ltinfo@g'  ./Makefile
make
make install

cd /usr/local
tar vcJf ./opensshmm.tar.xz opensshmm

mv ./opensshmm.tar.xz /work/artifact/
