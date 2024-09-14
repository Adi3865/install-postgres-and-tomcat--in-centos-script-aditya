## You can save this file name as ph_conf.sh     or any name 
-------------------------------------------------------------------------------------------------------------------


#!/bin/bash

# Define the directory and file variables
cd /root/ || { echo "Failed to change directory to /root/"; exit 1; }
DN=$(ls postgresql*.tar.gz)
if [ -z "$DN" ]; then
    echo "No PostgreSQL tarball found."
    exit 1
fi

# Extract the PostgreSQL tarball
tar -xvzf "$DN" || { echo "Failed to extract $DN"; exit 1; }

# Determine the extracted directory
CDN=$(ls | grep '^postgresql-' | head -n 1)
if [ -z "$CDN" ]; then
    echo "Failed to find the extracted PostgreSQL directory."
    exit 1
fi

# Prompt for username and password
read -p "Enter username: " username
read -s -p "Enter password: " password
echo

# Create the PostgreSQL user
sudo useradd -m "$username" || { echo "Failed to create user $username"; exit 1; }
echo "$username:$password" | sudo chpasswd || { echo "Failed to set password for $username"; exit 1; }

# Install necessary development packages
sudo yum install -y gcc flex bison readline-devel zlib-devel make cmake gcc-c++ sqlite-devel libtiff-devel libcurl-devel libxml2-devel || {
    echo "Failed to install required packages"; exit 1;
}

# Configure and install PostgreSQL
cd "$CDN" || { echo "Failed to change directory to $CDN"; exit 1; }
./configure --prefix=/usr/local/pgsql || { echo "Configuration failed"; exit 1; }
make || { echo "Make failed"; exit 1; }
sudo make install || { echo "Make install failed"; exit 1; }

# Setup PostgreSQL data directory
sudo mkdir -p /usr/local/pgsql/data || { echo "Failed to create data directory"; exit 1; }
sudo chown -R postgres:postgres /usr/local/pgsql || { echo "Failed to change ownership of /usr/local/pgsql"; exit 1; }

# Initialize the PostgreSQL database
sudo -u postgres /usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data || { echo "Failed to initialize the database"; exit 1; }

# Start PostgreSQL server
sudo -u postgres /usr/local/pgsql/bin/postmaster -D /usr/local/pgsql/data > /usr/local/pgsql/logfile 2>&1 & || {
    echo "Failed to start PostgreSQL server"; exit 1;
}

# Check PostgreSQL status
sudo -u postgres /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data status || { echo "PostgreSQL is not running"; exit 1; }

echo "PostgreSQL installation and setup completed successfully."












--------------------------------------------------------------------------------------------------------------------------
to run start status restart edit config file or change ip 


'''
systemctl status postgres 
systemctl start postgres 
systemctl stop postgres 
systemctl restart postgres 
'''



To view database 

su - postgres 
/usr/local/pgsql/15/bin/psql   ==  jab hme postgres server ka andar jana ho 
\l == foe all database show 
\c to connect the perticular database 


/usr/local/pgsql/15/bin/pg_ctl -D /usr/local/pgsql/15/data/ start     === start the postgres 
/usr/local/pgsql/15/bin/pg_ctl -D /usr/local/pgsql/15/data/ stop      ===  stop the postgres
/usr/local/pgsql/15/bin/pg_ctl -D /usr/local/pgsql/15/data/ status    ===  status the postgres






