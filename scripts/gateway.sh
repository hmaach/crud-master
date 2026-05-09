#!/usr/bin/env bash
set -e

source /vagrant/scripts/common.sh

echo "Setting up Gateway app..."
cd /vagrant/srcs/api-gateway-app

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Starting gateway with PM2..."
pm2 start server.py --name gateway --interpreter python3
pm2 save