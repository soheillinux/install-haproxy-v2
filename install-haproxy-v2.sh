#!/bin/bash
#edited by soheillinux -- email-address: soheillinred@hotmail.com
clear
echo "INSTALLING HAPROXY V2 ON CENTOS"
echo ""
var=`id -u`
if [ $var -ne 0 ];then 
  echo "you must login with root user"
  exit 10;
fi

### downloding required packages
echo "downloading required packages"
yum -y update && yum -y install   make gcc gcc-c++ pcre-devel openssl-devel readline-devel systemd-devel zlib-devel wget curl tar

### installing lua 
echo "installing lua"
curl -R -O http://www.lua.org/ftp/lua-5.3.5.tar.gz
tar zvxf lua-5.3.5.tar.gz
cd lua-5.3.5/ && make linux test && make linux install && cd ..

### downloading openssl source code and install openssl
curl -R -O https://www.openssl.org/source/openssl-1.1.1c.tar.gz
tar xvzf openssl-1.1.1c.tar.gz
cd openssl-1.1.1c && ./config --prefix=/usr/local/openssl-1.1.1c shared
make && make install && cd ..

### download and install haproxy
wget http://www.haproxy.org/download/2.0/src/haproxy-2.0.7.tar.gz
tar xvzf haproxy-2.0.7.tar.gz
cd haproxy-2.0.7 && make -j $(nproc) TARGET=linux-glibc USE_OPENSSL=1 SSL_LIB=/usr/local/openssl-1.1.1c/lib SSL_INC=/usr/local/openssl-1.1.1c/include USE_ZLIB=1 USE_LUA=1 LUA_LIB=/usr/local/lib/ LUA_INC=/usr/local/include/ USE_PCRE=1 USE_SYSTEMD=1 EXTRA_OBJS="contrib/prometheus-exporter/service-prometheus.o" && make install && cd ..
cp /usr/local/sbin/haproxy /usr/sbin/haproxy
useradd -M -r -s /sbin/nologin haproxy

### create haproxy service in /etc
if [ -e /etc/systemd/system/haproxy.service ];then
  > /etc/systemd/system/haproxy.service
fi
while read -r line ;do echo $line >> /etc/systemd/system/haproxy.service ; done < haproxy.service

### finish haproxy installation
systemctl daemon-reload
mkdir -p /etc/haproxy
touch /etc/haproxy/haproxy.cfg
systemctl enable haproxy

### create haproxy config file
if [ -e /etc/haproxy/haproxy.cfg ];then 
  > /etc/haproxy/haproxy.cfg
fi
while read -r line ; do echo $line >> /etc/haproxy/haproxy.cfg ; done < haproxy.cfg

echo "NOTICE! your service wont come up. after doing your own configuration on haproxy.cfg you can use your service. for more information about your logs use both command systemctl status haproxy -l and journalctl -xe"
