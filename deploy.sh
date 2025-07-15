#!/bin/bash

# stop on errors
set -e

echo "▶️  Creating a new ubuntu VM using terraform"
cd terraform
terraform init
terraform apply
cd ..

HOST="$(cat ./values/floating_ip/floating_ip.txt )"
PORT=22

echo "Wait for ssh availability on $HOST:$PORT ..."

# Warte, bis Port offen ist
while ! nc -z "$HOST" "$PORT"; do
    echo "SSH not available yet. waiting..."
    sleep 1
done

echo "▶️  Give VM some more time (5s) to fully start up"
sleep 5

echo "▶️  Install Docker on new VM"
ansible-playbook -i ansible/inventory.yaml ansible/setup-docker.yaml

echo "▶️  Install + Start LOST on new VM"
ansible-playbook -i ansible/inventory.yaml ansible/deploy-lost.yaml

echo "✅  Installation finished"
echo access LOST on: http://$HOST

