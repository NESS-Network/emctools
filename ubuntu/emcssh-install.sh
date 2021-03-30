#!/bin/bash
# EMCSSH Installation Script for Ubuntu
# Deps: Emercoind

if [ `whoami` != 'root' ]; then echo "Run me as root"; exit 1; fi
if [ ! -x /usr/local/bin/emc ]; then echo "Emercoind not found"; exit 1; fi
if [ ! -f /var/lib/emc/.emercoin/emercoin.conf ]; then echo "Emercoind not configured"; exit 1; fi
getent passwd emc >/dev/null || { echo "User 'emc' not found"; exit 1; }

apt-get -y install wget make libcurl4-openssl-dev libjansson-dev

wget https://github.com/emercoin/emcssh/archive/refs/tags/0.0.4.tar.gz
tar xvzf 0.0.4.tar.gz
rm 0.0.4.tar.gz
cd emcssh-0.0.4
mv emcssh_config emcssh_config.orig

cat<<EOF >emcssh_config
emcurl                  https://emccoinrpc:`grep rpcpassword /var/lib/emc/.emercoin/emercoin.conf | sed 's/rpcpassword=//'`@127.0.0.1:6662/
ssl_check               0
verbose                 2
maxkeys                 4096
emcssh_keys             /usr/local/etc/emcssh_keys/\$U
recursion               10
EOF

make
make install
chmod 711 /usr/local/sbin/emcssh
chmod u+s /usr/local/sbin/emcssh
mkdir -p /usr/local/etc/emcssh_keys

cat<<EOF >>/etc/ssh/sshd_config

AuthorizedKeysCommand /usr/local/sbin/emcssh
AuthorizedKeysCommandUser root
EOF

rm -rf emcssh-0.0.4
service ssh restart
