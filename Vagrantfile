# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV_FILE = ".env"

def load_env(file)
  env = {}
  if File.exist?(file)
    File.readlines(file).each do |line|
      next if line.strip.empty? || line.start_with?("#")
      key, value = line.strip.split("=", 2)
      env[key] = value
    end
  end
  env
end

ENV_VARS = load_env(ENV_FILE)

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # -------- INVENTORY VM --------
  config.vm.define "inventory-vm" do |inv|
    inv.vm.hostname = "inventory"
    inv.vm.network "private_network", ip: "192.168.56.10"

    inv.vm.provision "shell", path: "scripts/inventory.sh", env: ENV_VARS
  end

  # -------- BILLING VM --------
  config.vm.define "billing-vm" do |bill|
    bill.vm.hostname = "billing"
    bill.vm.network "private_network", ip: "192.168.56.11"

    bill.vm.provision "shell", path: "scripts/billing.sh", env: ENV_VARS
  end

  # -------- GATEWAY VM --------
  config.vm.define "gateway-vm" do |gw|
    gw.vm.hostname = "gateway"
    gw.vm.network "private_network", ip: "192.168.56.12"

    gw.vm.provision "shell", path: "scripts/gateway.sh", env: ENV_VARS
  end
end