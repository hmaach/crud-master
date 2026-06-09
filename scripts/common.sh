#!/usr/bin/env bash

set -e

source /vagrant/scripts/load_config.sh

echo "Updating system..."
sudo apt-get update -y

echo "Installing base packages..."
sudo apt-get install -y python3 python3-pip python3-venv curl git python3-yaml

echo "Installing Node.js and PM2..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# Load config.yaml after Python + pyyaml are available
load_config
