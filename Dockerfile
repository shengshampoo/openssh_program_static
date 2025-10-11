FROM alpine:latest

# https://mirrors.alpinelinux.org/
RUN sed -i 's@dl-cdn.alpinelinux.org@ftp.halifax.rwth-aachen.de@g' /etc/apk/repositories

RUN apk update
RUN apk upgrade

# required openssh 
RUN apk add --no-cache \
  gcc make linux-headers musl-dev zlib-dev zlib-static \
  python3-dev curl openssl-dev openssl-libs-static bash xz \
  libedit-dev libedit-static libedit \
  ncurses-static ncurses-dev readline-static readline-dev ldns-dev

RUN apk add --no-cache ldns-static --repository=http://ftp.halifax.rwth-aachen.de/alpine/edge/main/

ENV XZ_OPT=-e9
COPY build-static-openssh.sh build-static-openssh.sh
RUN chmod +x ./build-static-openssh.sh
RUN bash ./build-static-openssh.sh  
