#!/usr/bin/env bash

set -e

source "$(dirname "$0")/load_config.sh"

echo "Updating system..."
sudo apt-get update -y

echo "Installing base packages..."
sudo apt-get install -y python3 python3-pip python3-venv curl git python3-yaml

echo "Installing PM2..."
sudo npm install -g pm2 || true

# Load config.yaml after Python + pyyaml are available
load_config
