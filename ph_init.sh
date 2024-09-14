#!/bin/bash/
cd /root/;DN=$(ls postgresql*);tar -xvzf $DN;CDN=$(ls $DN | cut -c 1-15);CD1=$(ls $DN | cut -c 12-13);read -p "Enter username: " username;read -s -p "Enter password: " password;sudo useradd -m "$username";echo "$username:$password" | sudo chpasswd;mkdir -p /usr/local/pgsql/$CD1;yum install gcc flex bison readline-devel zlib-devel make cmake -y;yum install gcc-c++ sqlite-devel libtiff-devel libcurl-devel libxml2-devel -y;cd "$CDN"; ./configure --prefix=/usr/local/pgsql/$CD1/;make world;make install-world;mkdir /usr/local/pgsql/$CD1/data;cd /usr/local/pgsql/$CD1/;chown -R postgres. data;su - postgres -c '/usr/local/pgsql/'$CD1'/bin/initdb -D /usr/local/pgsql/'$CD1'/data';su - postgres -c '/usr/local/pgsql/'$CD1'/bin/postmaster -D /usr/local/pgsql/'$CD1'/data >logfile 2>&1 &';su - postgres -c '/usr/local/pgsql/'$CD1'/bin/pg_ctl -D /usr/local/pgsql/'$CD1'/data status';