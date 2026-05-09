#!/usr/bin/env bash

set -e

echo "Updating system..."
sudo apt-get update -y

echo "Installing base packages..."
sudo apt-get install -y python3 python3-pip python3-venv curl git

echo "Installing PM2..."
sudo npm install -g pm2 || true