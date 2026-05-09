#!/usr/bin/env bash
set -e

source /vagrant/scripts/common.sh

echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

echo "Configuring PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE DATABASE movies_db;
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
ALTER ROLE ${DB_USER} SET client_encoding TO 'utf8';
ALTER ROLE ${DB_USER} SET default_transaction_isolation TO 'read committed';
ALTER ROLE ${DB_USER} SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE movies_db TO ${DB_USER};
EOF

echo "Setting up app..."
cd /vagrant/srcs/inventory-app

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Starting app with PM2..."
pm2 start server.py --name inventory --interpreter python3
pm2 save