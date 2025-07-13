# LOST Deploy

Deploying [LOST](https://lost.training/) to a private cloud using terraform and ansible.

## Requirements

Requirements for the development machine (the pc that sets the whole thing up)

- an environment for executing bash scripts
- [Terraform](https://developer.hashicorp.com/terraform) installed
- [Ansible](https://docs.ansible.com/) installed

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

## Remove the LOST deploment  

To remove the deployment from openstack, enter the following commands into your terminal:  

```bash
cd terraform
terraform destroy
```  

Confirm removing the deployment by typing "yes" into the prompt.
