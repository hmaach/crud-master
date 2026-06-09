#!/usr/bin/env bash
set -e

source /vagrant/scripts/common.sh

echo "Installing PostgreSQL + RabbitMQ..."
sudo apt-get install -y postgresql postgresql-contrib rabbitmq-server

echo "Starting RabbitMQ..."
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

echo "Configuring RabbitMQ user..."
sudo rabbitmqctl add_user "${MQ_USER}" "${MQ_PASSWORD}"
sudo rabbitmqctl set_permissions -p / "${MQ_USER}" ".*" ".*" ".*"

echo "Configuring PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE DATABASE orders_db;
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE orders_db TO ${DB_USER};
\c orders_db
GRANT ALL ON SCHEMA public TO ${DB_USER};
EOF

export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/orders_db"
export RABBITMQ_URL="amqp://${MQ_USER}:${MQ_PASSWORD}@localhost:5672/"

echo "Setting up app..."
cd /vagrant/srcs/billing-app

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Starting consumer with PM2..."
pm2 start server.py --name billing_app --interpreter python3 \
  --env DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/orders_db" \
  --env RABBITMQ_URL="amqp://${MQ_USER}:${MQ_PASSWORD}@localhost:5672/"
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u vagrant --hp /home/vagrant
pm2 save