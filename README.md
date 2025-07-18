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



## Scaling LOST

The current setup runs all LOST services (frontend, backend, database, and Traefik) in multiple docker containers inside a single VM. 
For higher loads or production deployments, you can scale in two ways:

1. Horizontal Scaling (more containers per service): 

- Add replicas for the backend service in compose.yaml:

        backend:
        image: l3pcv/lost-backend:${LOST_VERSION}
        deploy:
            replicas: 3

- Traefik automatically load-balances traffic across replicas. 
- For scaling across multiple VMs:
    - Extend the Terraform configuration to create additional instances.
    - Use Docker Swarm or Kubernetes for orchestration.

 2. Vertical Scaling (Increase VM resources):
 
 - Modify the OpenStack flavor in terraform/main.tf: flavor_name = "m1.large"
 - This increases CPU and memory of your VM to handle more concurrent users.

The scripts inside this repository are a proof of concept.
For real production environments, consider running a container orchestrator like Kubernetes on bare metal and apply horizontal scaling for better resiliency and load balancing.
