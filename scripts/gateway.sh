#!/usr/bin/env bash
set -e

source /vagrant/scripts/common.sh

echo "Installing Node.js and PM2..."

sudo apt-get update -y
sudo apt-get install -y curl

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g pm2

echo "Setting up Gateway app..."
cd /vagrant/srcs/api-gateway-app

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

echo "Starting gateway with PM2..."
pm2 start server.py --name gateway --interpreter python3
pm2 save