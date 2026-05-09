#!/usr/bin/env bash
set -e

source /vagrant/scripts/common.sh

echo "Installing PostgreSQL + RabbitMQ..."
sudo apt-get install -y postgresql postgresql-contrib rabbitmq-server

echo "Starting RabbitMQ..."
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

echo "Configuring PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE DATABASE billing_db;
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE billing_db TO ${DB_USER};
EOF

echo "Setting up app..."
cd /vagrant/srcs/billing-app

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Starting consumer with PM2..."
pm2 start server.py --name billing --interpreter python3
pm2 save