#!/usr/bin/env bash
set -e

source /vagrant/scripts/common.sh

export INVENTORY_URL="http://${INVENTORY_HOST}:${INVENTORY_PORT}"
export RABBITMQ_URL="amqp://${MQ_USER}:${MQ_PASSWORD}@${BILLING_HOST}:${BILLING_PORT}/"

echo "Setting up Gateway app..."
cd /vagrant/srcs/api-gateway-app

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Starting gateway with PM2..."
pm2 start server.py --name gateway --interpreter python3 \
  --env INVENTORY_URL="http://${INVENTORY_HOST}:${INVENTORY_PORT}" \
  --env RABBITMQ_URL="amqp://${MQ_USER}:${MQ_PASSWORD}@${BILLING_HOST}:${BILLING_PORT}/"
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u vagrant --hp /home/vagrant
pm2 save