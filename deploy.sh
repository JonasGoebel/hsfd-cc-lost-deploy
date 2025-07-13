#!/bin/bash

# stop on errors
set -e

echo "ℹ️ Creating a new ubuntu vm using terraform"
cd terraform
terraform init
terraform apply
cd ..

echo "Give vm some time (10s) to boot"
sleep 10

echo "ℹ️ Install Docker on new VM"
ansible-playbook -i ansible/inventory.yaml ansible/setup-docker.yaml

echo "ℹ️ Install + Start LOST on new VM"
ansible-playbook -i ansible/inventory.yaml ansible/deploy-lost.yaml
