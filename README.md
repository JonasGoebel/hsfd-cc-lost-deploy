# LOST Deploy

Automated deployment of [LOST](https://lost.training/) on a private cloud (OpenStack) using terraform and ansible.

## Requirements

Requirements for the development machine (the pc that sets the whole thing up)

- Linux / macOS (or Windows with WSL)
- an environment for executing bash scripts
- [Terraform](https://developer.hashicorp.com/terraform) installed
- [Ansible](https://docs.ansible.com/) installed
- Access to an OpenStack environment 


## Quick Setup

1. Clone Repo / unpack zip file
2. run deployment script:  

    ```bash
    bash deploy.sh
    ```

    Confirm the deployment by typing "yes" into the prompt.

3. The application should be accessible now at the link returned by the script.

## What the deployment script does

1. Terraform creates a vm on OpenStack (on the private cloud of HS Fulda).
2. Terraform adds an SSH key on the newly created vm.
3. Terraform stores the SSH key and the floating ip of the crated vm into files. These files are accessed by ansibles inventory.yaml (that specifies the connection to the vm).
4. The ansible playbook installs docker on the freshly created vm.
5. The ansible playbook deploys the LOST application using docker (compose).


## Components

### deploy.sh

The deploy.sh script automates the full deployment in three steps:

1. Initialize and runs terraform apply
2. Configure the Remote VM with Ansible
3. Output Access Information


### main.tf

The main.tf Terraform configuration is doing these steps:

1. Define Variables and OpenStack Provider
2. Generate SSH Keys
3. Create Network Resources
4. Create Security Groups and Rules
5. Launch VM Instance
6. Assign Floating IP
7. Prints floating IP and SSH private key after terraform apply


### compose.yaml

The compose.yaml defines the LOST application stack using Traefik

How it works:
- Traefik is the entry point, routing requests to frontend and backend
- Interacts with MySQL for data storage
- Environment variables in .env define DB credentials and LOST version


### Ansible

This folder contains all Ansible configurations required to set up and manage the LOST application:

- inventory.yaml: Defines the remote host (VM) details and SSH access.
- setup-docker.yaml: Installs Docker and Docker Compose on the VM.
- deploy-lost.yaml: Deploys the LOST application by copying required files.
- undeploy-lost.yaml: Removes the LOST Docker stack and cleans up related resources on the VM.


## Remove the LOST deploment  

To remove the deployment from openstack, enter the following commands into your terminal:  

```bash
cd terraform
terraform destroy
```  

Confirm removing the deployment by typing "yes" into the prompt.
