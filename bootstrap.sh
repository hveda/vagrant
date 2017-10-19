#!/usr/bin/env bash

# update apt-get
sudo apt-get update

# install various dependencies
sudo apt-get -y install build-essential libreadline-gplv2-dev libncursesw5-dev \
	libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev sshpass \
	git-core sloccount


# Install Python
sudo apt-get -y install python3.6 python-pip python-dev libpq-dev
sudo pip install --upgrade pip
# @see https://pip.pypa.io/en/latest/reference/pip.html


# Install Hoaxbot Requirements
sudo pip install -qq -r /hoax-bot/requirements.txt

# Setup Python Config
APP_SETTINGS="config.ProductionConfig"
export APP_SETTINGS


# Install and Configuring PostgreSQL
echo "-------------------- installing postgres"
sudo apt-get -y install postgresql postgresql-contrib
# fix permissions
echo "-------------------- fixing listen_addresses on postgresql.conf"
sudo sed -i "s/#listen_address.*/listen_addresses '*'/" /etc/postgresql/*/main/postgresql.conf
echo "-------------------- fixing postgres pg_hba.conf file"
# replace the ipv4 host line with the above line
sudo cat >> /etc/postgresql/*/main/pg_hba.conf
# Accept all IPv4 connections - FOR DEVELOPMENT ONLY!!!
host    all         all         0.0.0.0/0             md5
EOF
echo "-------------------- creating postgres vagrant role with password vagrant"
# Create Role and login
sudo su postgres -c "psql -c \"CREATE ROLE vagrant SUPERUSER LOGIN PASSWORD 'vagrant'\" "
sudo /etc/init.d/postgresql restart


# Install SQLite3
sudo apt-get -y install sqlite3 libsqlite3-dev

# create folder for SQLite DB
cd /tmp
mkdir tmp
sudo chown www-data:www-data /tmp/tmp

# create DB tables, set folder and file permissions
cd /var/www/
python db_create_users.py
python db_create_posts.py
sudo chown www-data:www-data /tmp/tmp/sample.db
sudo chmod -R 777 /tmp/tmp



# Open port 80
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables-save

