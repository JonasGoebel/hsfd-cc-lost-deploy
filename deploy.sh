#!/bin/bash

# stop on errors
set -e

echo "▶️  Creating a new ubuntu VM using terraform"
cd terraform
terraform init
terraform apply
cd ..

echo "▶️  Give VM some time (30s) to boot"
sleep 30

echo "▶️  Install Docker on new VM"
ansible-playbook -i ansible/inventory.yaml ansible/setup-docker.yaml

echo "▶️  Install + Start LOST on new VM"
ansible-playbook -i ansible/inventory.yaml ansible/deploy-lost.yaml

echo "✅  Installation finished"
echo access LOST on: http://$(cat ./values/floating_ip/floating_ip.txt )
