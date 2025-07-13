# LOST Deploy

Deploying [LOST](https://lost.training/) to a private cloud using terraform and ansible.

## Requirements

Requirements for the development machine (the pc that sets the whole thing up)

- [Terraform](https://developer.hashicorp.com/terraform) installed
- [Ansible](https://docs.ansible.com/) installed

## Quick Setup

1. Clone Repo / unpack zip file
2. run terraform script
3. run ansible playbook

### Start Terraform 
1. cd learn-terraform-docker-container
2. terraform init
3. terraform apply

## What it does

1. Terraform creates a vm on OpenStack (here on the private cloud of HS Fulda)
2. Terraform adds an SSH key on the newly created vm
3. Terraform hands the SSH key to the ansible playbook
4. The ansible playbook installs docker on the freshly created vm
5. The ansible playbook deploys the LOST application using docker compose
