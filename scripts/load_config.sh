#!/usr/bin/env bash

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
