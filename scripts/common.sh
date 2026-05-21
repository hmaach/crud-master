#!/usr/bin/env bash

set -e

# Load config.yaml and export values as environment variables
# Uses Python (installed below) for YAML parsing
load_config() {
    local config_file="/vagrant/config.yaml"
    if [ -f "$config_file" ]; then
        echo "Loading configuration from config.yaml..."
        eval "$(python3 -c "
import yaml, sys
with open('$config_file') as f:
    data = yaml.safe_load(f)
for svc, info in data.get('services', {}).items():
    for key, val in info.items():
        if isinstance(val, str):
            print(f'export {svc.upper()}_{key.upper()}=\"{val}\"')
" 2>/dev/null)" || true
    fi
}

echo "Updating system..."
sudo apt-get update -y

echo "Installing base packages..."
sudo apt-get install -y python3 python3-pip python3-venv curl git python3-yaml

echo "Installing PM2..."
sudo npm install -g pm2 || true

# Load config.yaml after Python + pyyaml are available
load_config
